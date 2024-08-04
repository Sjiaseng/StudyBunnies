import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: (){Navigator.pop(context);},
        child: SizedBox(
          width: 10.w,
          height: 10.0.h,
          child: const Icon(Icons.arrow_back),
        ), 
      ),
    );
  }
}