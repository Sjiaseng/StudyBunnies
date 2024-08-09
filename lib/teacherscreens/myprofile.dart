import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/snackbar.dart';
import 'package:studybunnies/teachermodels/countries.dart';
import 'package:studybunnies/authentication/session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;
  String? _selectedCountry;
  String? _selectedRole;
  final _formKey = GlobalKey<FormState>();
  String? userId; // Add userId to the state

  bool _obscurePassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Session session = Session(); // Initialize Session instance

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on init
  }

  Future<void> _fetchUserData() async {
    try {
      // Get the user ID from the session
      userId = await session.getUserId();
      if (userId == null) {
        print('User ID is null.');
        return;
      }

      // Fetch user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId!)
          .get();
      if (!userDoc.exists) {
        print('User document does not exist.');
        return;
      }

      // Update state with fetched data
      setState(() {
        _nameController.text = userDoc.get('username');
        _contactNumberController.text = userDoc.get('contactnumber');
        _emailController.text = userDoc.get('email');
        _passwordController.text =
            userDoc.get('password'); // Consider allowing password updates
        _selectedCountry = userDoc.get('country');
        _selectedRole = userDoc.get('role');
        _pickedImagePath = userDoc.get('profile_img');
        _obscurePassword = true;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
      print('Picked image path: ${pickedFile.path}');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  bool _isProfilePictureAdded() {
    return _pickedImagePath != null && _pickedImagePath!.isNotEmpty;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final usersCollection = FirebaseFirestore.instance.collection('users');

      try {
        String profileImageUrl = '';

        if (_pickedImagePath != null && !_pickedImagePath!.startsWith('http')) {
          File file = File(_pickedImagePath!);

          if (!file.existsSync()) {
            throw Exception('File does not exist at path: ${file.path}');
          }

          TaskSnapshot snapshot = await FirebaseStorage.instance
              .ref('profile_images/$userId')
              .putFile(file);
          profileImageUrl = await snapshot.ref.getDownloadURL();
        } else {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId!)
              .get();
          if (userDoc.exists) {
            final data = userDoc.data()!;
            profileImageUrl = data['profile_img'] ?? '';
          }
        }

        DocumentReference docRef = usersCollection.doc(userId!);
        await docRef.update({
          'username': _nameController.text,
          'contactnumber': _contactNumberController.text,
          'country': _selectedCountry,
          'role': _selectedRole,
          'email': _emailController.text,
          'password': _passwordController.text,
          'profile_img': profileImageUrl,
        });

        if (mounted) {
          showCustomSnackbar(
            context,
            'Saved Changes!',
          );
        }
      } catch (e) {
        print('Error during form submission: $e');
        if (mounted) {
          showCustomSnackbar(
            context,
            'Fail to Save. Please Retry!',
          );
        }
      }
    } else {
      if (!_isProfilePictureAdded()) {
        showCustomSnackbar(
          context,
          'Please Include a Profile Picture!',
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar(
        "My Profile",
        "This page contains your profile information.",
        context,
        showBackIcon: true,
        showProfileIcon: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 55.0),
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 6.0,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            _pickedImagePath != null && _pickedImagePath != ""
                                ? (_pickedImagePath!.contains('http')
                                    ? NetworkImage(_pickedImagePath!)
                                    : FileImage(File(_pickedImagePath!))
                                        as ImageProvider)
                                : const AssetImage('images/profile.webp'),
                        radius: 14.w,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(100, 30, 30, 1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt,
                                size: 4.5.w, color: Colors.white),
                            onPressed: _pickImage,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          enabled: true,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            labelStyle:
                                TextStyle(color: Color.fromRGBO(61, 47, 34, 1)),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(61, 47, 34, 1),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter a Name';
                            } else if (value.length <= 2) {
                              return 'Name must be at least 3 Characters Long';
                            } else if (RegExp(r'[^\p{L}\s/]', unicode: true)
                                .hasMatch(value)) {
                              return 'Name Contains Invalid Characters';
                            } else if (RegExp(r'\d').hasMatch(value)) {
                              return 'Name Should Not Contain Numbers';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          controller: _contactNumberController,
                          enabled: true,
                          decoration: const InputDecoration(
                            labelText: 'Contact Number',
                            labelStyle:
                                TextStyle(color: Color.fromRGBO(61, 47, 34, 1)),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(61, 47, 34, 1),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter a Contact Number';
                            } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'Please Enter a Valid Contact Number (Digits Only)';
                            } else if (value.length < 7 || value.length > 15) {
                              return 'Please Enter a Contact Number between 7 and 15 Digits';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          controller: _emailController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle:
                                TextStyle(color: Color.fromRGBO(61, 47, 34, 1)),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(61, 47, 34, 1),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter an Email Address';
                            } else if (!RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(value)) {
                              return 'Please Enter a Valid Email Address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          controller: _passwordController,
                          enabled: false,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                                color: Color.fromRGBO(61, 47, 34, 1)),
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(61, 47, 34, 1),
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color.fromRGBO(61, 47, 34, 1),
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter a Password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 Characters Long';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.h),
                        DropdownSearch<String>(
                          items: countries, // Use your countries list
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Select Country',
                              labelStyle: TextStyle(
                                  color: Color.fromRGBO(61, 47, 34, 1)),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(61, 47, 34, 1),
                                ),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedCountry = value;
                            });
                          },
                          selectedItem: _selectedCountry,
                          enabled: true, // Enable dropdown
                        ),
                        SizedBox(height: 2.h),
                        DropdownSearch<String>(
                          items: const ['Teacher'],
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Select Role',
                              labelStyle: TextStyle(
                                  color: Color.fromRGBO(61, 47, 34, 1)),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(61, 47, 34, 1),
                                ),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                          selectedItem: _selectedRole,
                          enabled: true, // Enable dropdown
                        ),
                        SizedBox(height: 5.h),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h, horizontal: 23.w),
                            backgroundColor:
                                const Color.fromRGBO(195, 154, 28, 1),
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
