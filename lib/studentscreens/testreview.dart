import 'package:flutter/material.dart';

class TestReview extends StatelessWidget {
  final String userID;
  final String classID;
  final String testID;

  const TestReview({
    Key? key,
    required this.userID,
    required this.classID,
    required this.testID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Review'),
        backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Details',
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
              'Test ID: $testID',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
