import 'package:flutter/material.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class QuizTestList extends StatefulWidget {
  const QuizTestList({super.key});

  @override
  State<QuizTestList> createState() => _QuizTestListPageState();
}

class _QuizTestListPageState extends State<QuizTestList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar(
        "Quizzes & Tests",
        "This section consists of student quizzes and tests.",
        context
      ),
      drawer: StudentDrawer(drawercurrentindex: 3, userID: 'userID'),// Adjust the index for the Quiz/Test page
      bottomNavigationBar: inactivenavbar(),
      body: const Center(child: Text("Student Quizzes & Tests")),
    );
  }
}
