import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studybunnies/authentication/forgetpassword.dart';
import 'package:studybunnies/studentmodels/countries.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;
  String? _selectedCountry;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // No need to initialize controllers here; they are already initialized
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }

  Future<String?> _getUserId() async {
    return await _secureStorage.read(key: 'userID');
  }

  Future<void> _updateUserData(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'username': _nameController.text,
        'contactnumber': _contactNumberController.text,
        'password': _passwordController.text,
        'country': _selectedCountry,
        'profile_img': _pickedImagePath != null ? File(_pickedImagePath!).path : null,
      });
      print('User data updated successfully');
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<String?>(
        future: _getUserId(),
        builder: (context, userIdSnapshot) {
          if (userIdSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userIdSnapshot.hasData || userIdSnapshot.data == null) {
            return Center(child: Text('User ID not found'));
          }

          String userId = userIdSnapshot.data!;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('No data available'));
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;

              // Initialize controllers with current data
              _nameController.text = userData['username'];
              _contactNumberController.text = userData['contactnumber'];
              _passwordController.text = userData['password'];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 7.w, top: 3.h),
                            width: 10.w,
                            height: 10.h,
                            child: Icon(Icons.arrow_back, size: 20.sp),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(top: 3.h, right: 8.w),
                              child: Text(
                                'My Profile',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            backgroundImage: _pickedImagePath != null
                                ? FileImage(File(_pickedImagePath!))
                                    as ImageProvider
                                : NetworkImage(userData['profile_img'] ??
                                    'default_image_url'), // Replace with default image URL if needed
                            radius: 12.w,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 0.w, right: 0.w),
                                child: IconButton(
                                  icon: Icon(Icons.camera_alt,
                                      size: 4.5.w, color: Colors.white),
                                  onPressed: _pickImage,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "User ID: ${userData['userID']}",
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle long user ID
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Name',
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextFormField(
                            controller: _contactNumberController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Contact Number',
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextFormField(
                            initialValue: userData['email'],
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'E-mail',
                            ),
                            enabled: false,
                          ),
                          SizedBox(height: 2.h),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Country',
                            ),
                            value: _selectedCountry ?? userData['country'],
                            items: countries
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCountry = newValue;
                              });
                            },
                          ),
                          SizedBox(height: 2.h),
                          PasswordField(password: userData['password'], enabled: false), // Set enabled to false
                          SizedBox(height: 2.h),
                          TextFormField(
                            initialValue: userData['role'],
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Role',
                            ),
                            enabled: false,
                          ),
                          SizedBox(height: 5.h),
                          ElevatedButton(
                            onPressed: () async {
                              print('Save Changes pressed');
                              await _updateUserData(userId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Changes saved successfully'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(double.infinity,
                                  50),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          ElevatedButton(
                            onPressed: () {
                              print('Reset Password pressed');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Forgetpassword(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(double.infinity,
                                  50),
                            ),
                            child: const Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final String password;
  final bool enabled; // Add this property

  PasswordField({required this.password, this.enabled = true}); // Add default value

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.password);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscureText,
          enabled: false, // Always disabled
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: 'Password',
          ),
        ),
        Positioned(
          right: 0,
          child: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ],
    );
  }
}
