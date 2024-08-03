import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studybunnies/adminwidgets/IncrementDecrement.dart';

class Addclass extends StatefulWidget {
  const Addclass({super.key});

  @override
  State<Addclass> createState() => _AddclassState();
}

class _AddclassState extends State<Addclass> {
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
      print('Picked image path: ${pickedFile.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                        'Adding Class',
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
                  Container(
                    width: 38.w, 
                    height: 38.w, 
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), 
                      image: DecorationImage(
                        image: _pickedImagePath != null
                            ? FileImage(File(_pickedImagePath!))
                            : const AssetImage('images/profile.webp') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                        padding: const EdgeInsets.all(0.0),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, size: 4.5.w, color: Colors.white),
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
                "Class: Auto Generated",
                style: TextStyle(
                  fontSize: 8.sp,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis, // Handle long user ID
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Class Name',
                    ),
                  ),
                  SizedBox(height: 5.h),
                  const TextField(
                    maxLines: 7, 
                    scrollPhysics: BouncingScrollPhysics(), 
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(
                        fontSize: 16.0,
                      ),
                      contentPadding: EdgeInsets.only(left: 12.0, top: 12.0), 
                    ),
                  ),
                  SizedBox(height: 6.h),

                  ElevatedButton(
                    onPressed: () {
                      print('Save Changes pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 50), // Ensures the button takes full width
                    ),
                    child: const Text(
                      'Add Class',
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
      ),
    );
  }
}
