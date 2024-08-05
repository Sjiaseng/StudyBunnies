import 'package:flutter/material.dart';

class QuizReview extends StatelessWidget {
  final String userID;
  final String classID;
  final String quizID;

  const QuizReview({
    Key? key,
    required this.userID,
    required this.classID,
    required this.quizID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Review'),
        backgroundColor: Color.fromRGBO(100, 30, 30, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            Text(
              'User ID: $userID',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Class ID: $classID',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Quiz ID: $quizID',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
