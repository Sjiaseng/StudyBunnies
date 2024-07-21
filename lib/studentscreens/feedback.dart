import 'package:flutter/material.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class Feedbacklist extends StatefulWidget {
  const Feedbacklist({super.key});

  @override
  State<Feedbacklist> createState() => _FeedbacklistState();
}

class _FeedbacklistState extends State<Feedbacklist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar("Feedback", "This section consists of feedback retrieved from teachers and students.", context),
      drawer: studentDrawer(context, 6),
      bottomNavigationBar: inactivenavbar(),
      body: const Center(child:Text("Student Feedback"),),
    );
  }
}