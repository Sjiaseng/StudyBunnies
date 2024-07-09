import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Faqpage extends StatefulWidget {
  const Faqpage({super.key});

  @override
  State<Faqpage> createState() => _FaqpageState();
}

class _FaqpageState extends State<Faqpage> {
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