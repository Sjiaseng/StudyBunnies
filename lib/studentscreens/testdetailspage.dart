import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestDetailsPage extends StatelessWidget {
  final String userID;
  final String classID;
  final String testID;

  const TestDetailsPage({
    Key? key,
    required this.userID,
    required this.classID,
    required this.testID,
  }) : super(key: key);

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

  Future<List<Map<String, dynamic>>> _getTestQuestions() async {
    try {
      // Fetch questions
      QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
          .collection('testquestion')
          .where('testID', isEqualTo: testID)
          .get();

      List<Map<String, dynamic>> questions = questionSnapshot.docs
          .map((doc) => {
                'questionID': doc.id,
                'question': doc['question'],
              })
          .toList();

      return questions;
    } catch (e) {
      throw Exception('Failed to load test questions: $e');
    }
  }

  void _submitAnswers(BuildContext context, List<Map<String, String>> answers) async {
    final submissionDate = DateTime.now();

    try {
      // Create a unique ID for the submission document
      final studentTestAnsID = FirebaseFirestore.instance
          .collection('studentTestAnswer')
          .doc()
          .id;

      // Format the answers to include questionID and testAnswer
      List<Map<String, dynamic>> formattedAnswers = answers.map((answer) {
        return {
          'questionID': answer['questionID'],
          'testAnswer': answer['answer'],
        };
      }).toList();

      // Set the document with the formatted answers and additional fields
      await FirebaseFirestore.instance
          .collection('studentTestAnswer')
          .doc(studentTestAnsID)
          .set({
        'studentID': userID,
        'studentTestAnsID': studentTestAnsID,
        'testID': testID,
        'submission': 'submitted',
        'submissionDate': submissionDate,
        'studentAnswer': formattedAnswers,
      });

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit answers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Details'),
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
                        fontSize: 30,
                      ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  testTitle,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                ),
                const SizedBox(height: 24.0),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getTestQuestions(),
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

                      final questions = snapshot.data!;
                      List<TextEditingController> _controllers = List.generate(
                        questions.length,
                        (index) => TextEditingController(),
                      );

                      return ListView.builder(
                        itemCount: questions.length + 1, // +1 for the submit button
                        itemBuilder: (context, index) {
                          if (index == questions.length) {
                            // Submit button
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Color.fromRGBO(100, 30, 30, 1), // Text color
                                    minimumSize: const Size(double.infinity, 50), // Full width of card
                                  ),
                                  onPressed: () {
                                    List<Map<String, String>> answers = [];
                                    for (int i = 0; i < questions.length; i++) {
                                      answers.add({
                                        'questionID': questions[i]['questionID'],
                                        'answer': _controllers[i].text,
                                      });
                                    }
                                    _submitAnswers(context, answers);
                                  },
                                  child: const Text('Submit All Answers'),
                                ),
                              ),
                            );
                          }

                          final question = questions[index];
                          final questionID = question['questionID'];
                          final questionText = question['question'];

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    questionText,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 8.0),
                                  TextField(
                                    controller: _controllers[index],
                                    decoration: const InputDecoration(
                                      labelText: 'Your Answer',
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
