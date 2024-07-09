import 'package:flutter/material.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';

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
      drawer: adminDrawer(context, 5),
      bottomNavigationBar: inactivenavbar(),
    );
  }
}