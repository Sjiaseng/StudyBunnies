import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewSubmission extends StatefulWidget {
  final String studentID;
  final String classID;
  final String className;
  final String testID;
  final String testTitle;

  const ViewSubmission({
    super.key,
    required this.studentID,
    required this.classID,
    required this.className,
    required this.testTitle,
    required this.testID,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ViewSubmissionState createState() => _ViewSubmissionState();
}

class _ViewSubmissionState extends State<ViewSubmission> {
  List<Map<String, dynamic>> existingTestQuestions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  String? _studentName;

  @override
  void initState() {
    super.initState();
    fetchStudentAnswers();
  }

  Future<void> fetchStudentAnswers() async {
    try {
      final studentQuery = await FirebaseFirestore.instance
          .collection('studentTestAnswer')
          .where('testID', isEqualTo: widget.testID)
          .get();

      if (studentQuery.docs.isNotEmpty) {
        // Clear existing questions before adding new ones
        existingTestQuestions.clear();

        for (var studentDoc in studentQuery.docs) {
          final studentAnswers =
              studentDoc.data()['studentAnswer'] as List<dynamic>? ?? [];

          if (studentAnswers.isNotEmpty) {
            String studentID = studentDoc.data()['studentID'] as String;

            // Fetch the student username from the 'users' collection
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(studentID)
                .get();

            String studentName =
                userDoc.exists ? userDoc.get('username') : 'Unknown Student';

            // Prepare to fetch questions from the testquestion collection
            List<Future<DocumentSnapshot>> questionFutures = [];
            Set<String> questionIDs = {}; // Use a set to avoid duplicates

            for (var answer in studentAnswers) {
              String questionID = answer['questionID'];
              if (!questionIDs.contains(questionID)) {
                questionIDs.add(questionID);
                questionFutures.add(FirebaseFirestore.instance
                    .collection('testquestion')
                    .doc(questionID)
                    .get());
              }
            }

            List<DocumentSnapshot> questionSnapshots =
                await Future.wait(questionFutures);

            // Create a map of question snapshots for easy access
            Map<String, DocumentSnapshot> questionMap = {
              for (var snapshot in questionSnapshots) snapshot.id: snapshot
            };

            // Process the fetched questions and student answers
            for (var answer in studentAnswers) {
              String questionID = answer['questionID'];
              String testAnswer = answer['testAnswer'];

              DocumentSnapshot? questionSnapshot = questionMap[questionID];

              if (questionSnapshot != null && questionSnapshot.exists) {
                String question = questionSnapshot.get('question');
                existingTestQuestions.add({
                  'question': question,
                  'studentAnswer': testAnswer,
                });
                print('Added question: $question with answer: $testAnswer');
              } else {
                existingTestQuestions.add({
                  'question': 'Question not found',
                  'studentAnswer': testAnswer,
                });
                print('Question with ID $questionID not found.');
              }
            }

            // Store or display the studentName wherever needed
            setState(() {
              _studentName = studentName;
            });
          } else {
            print('No student answers in document.');
          }
        }
      } else {
        print('No student answers found.');
      }
    } catch (error) {
      print('Error fetching student answers: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < existingTestQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    final Map<String, dynamic> currentQuestionData =
        existingTestQuestions.isNotEmpty
            ? existingTestQuestions[_currentQuestionIndex]
            : {'question': '', 'studentAnswer': ''};

    final String currentQuestion = currentQuestionData['question'] ?? '';
    final String currentAnswer = currentQuestionData['studentAnswer'] ?? '';

    return Scaffold(
      appBar: mainappbar(
        "View Submissions",
        "This is the View Submissions screen for ${widget.className}'s ${widget.testTitle} test.",
        context,
        showBackIcon: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.className,
                          style: TextStyle(
                            color: const Color.fromRGBO(61, 47, 34, 1),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.testTitle,
                          style: TextStyle(
                            color: const Color.fromRGBO(61, 47, 34, 1),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _studentName ??
                              'Loading...', // Display the student name
                          style: TextStyle(
                            color: const Color.fromRGBO(61, 47, 34, 1),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Question ${_currentQuestionIndex + 1}',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Center the children horizontally
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 204, 230, 225),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              currentQuestion,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(
                                20.0), // Adjust padding here
                            margin: const EdgeInsets.symmetric(
                                vertical: 20.0), // Adjust margin here
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: Colors.black, // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                            child: Text(
                              currentAnswer,
                              style: TextStyle(
                                fontSize: 15.sp, // Adjust font size here
                                color: Colors.black,
                              ),
                              maxLines: 20, // You can still set maxLines
                              overflow: TextOverflow
                                  .ellipsis, // Handle overflow with ellipsis
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(195, 154, 28, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 35.0,
              ),
              onPressed: _previousQuestion,
            ),
            Text(
              'Question ${_currentQuestionIndex + 1} of ${existingTestQuestions.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 35.0,
              ),
              onPressed: _nextQuestion,
            ),
          ],
        ),
      ),
    );
  }
}
