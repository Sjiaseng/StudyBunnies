import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

  // Fetches and returns the class name and test title.
  Future<Map<String, dynamic>> _getClassAndTestDetails() async {
    try {
      // Fetch class name
      DocumentSnapshot classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classID)
          .get();

      if (!classDoc.exists) {
        throw Exception('Class not found');
      }

      String className = classDoc['classname'];

      // Fetch test title
      DocumentSnapshot testDoc = await FirebaseFirestore.instance
          .collection('test')
          .doc(testID)
          .get();

      if (!testDoc.exists) {
        throw Exception('Test not found');
      }

      String testTitle = testDoc['testTitle'];

      return {
        'className': className,
        'testTitle': testTitle,
      };
    } catch (e) {
      throw Exception('Failed to load test details: $e');
    }
  }

  // Fetches and returns the list of questions and the student's answers.
  Future<List<Map<String, dynamic>>> _getTestQuestionsAndAnswers() async {
    try {
      // Fetch questions
      QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
          .collection('testquestion')
          .where('testID', isEqualTo: testID)
          .get();

      // Fetch student's answers
      QuerySnapshot answerSnapshot = await FirebaseFirestore.instance
          .collection('studentTestAnswer')
          .where('studentID', isEqualTo: userID)
          .where('testID', isEqualTo: testID)
          .get();

      if (answerSnapshot.docs.isEmpty) {
        return []; // Return an empty list to indicate no attempt
      }

      List<Map<String, dynamic>> questionsAndAnswers = [];

      // Extract the student answers from the first document (assuming one document per test per student)
      var studentAnswers = answerSnapshot.docs.first['studentAnswer'] as List;

      for (var questionDoc in questionSnapshot.docs) {
        String questionID = questionDoc.id;
        String question = questionDoc['question'];
        String studentAnswer = '';

        // Find the matching answer for the current question
        for (var answer in studentAnswers) {
          if (answer['questionID'] == questionID) {
            studentAnswer = answer['testAnswer'];
            break;
          }
        }

        questionsAndAnswers.add({
          'questionID': questionID,
          'question': question,
          'studentAnswer': studentAnswer,
        });
      }

      return questionsAndAnswers;
    } catch (e) {
      // Return an empty list to handle any exceptions
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Review'),
        backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getClassAndTestDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final className = snapshot.data!['className'];
          final testTitle = snapshot.data!['testTitle'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                        fontSize: 30,
                      ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  testTitle,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                        fontSize: 25,
                      ),
                ),
                const SizedBox(height: 24.0),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getTestQuestionsAndAnswers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Check if no attempt was made
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No attempt has been made. \nPlease make an attempt before checking your answers.',
                            style: TextStyle(
                              color: Colors.red, 
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Times New Roman'
                              ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final questionsAndAnswers = snapshot.data!;

                      return ListView.builder(
                        itemCount: questionsAndAnswers.length,
                        itemBuilder: (context, index) {
                          final item = questionsAndAnswers[index];
                          final questionText = item['question'];
                          final studentAnswer = item['studentAnswer'];

                          return Card(
                            color: Color.fromRGBO(211, 211, 211, 1),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    questionText,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Times New Roman',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Your Answer: \n$studentAnswer',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Times New Roman',
                                        fontSize: 17,
                                      ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
