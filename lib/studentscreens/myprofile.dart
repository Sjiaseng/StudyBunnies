import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: (){Navigator.pop(context);},
        child: SizedBox(
          width: 10.w,
          height: 10.0.h,
          child: Icon(Icons.arrow_back),
        ), 
      ),
    );
  }
}