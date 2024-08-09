import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTest extends StatefulWidget {
  final String classID;
  final String className;

  const AddTest({super.key, required this.className, required this.classID});

  @override
  // ignore: library_private_types_in_public_api
  _AddTestState createState() => _AddTestState();
}

class _AddTestState extends State<AddTest> {
  String? loggedInUserId;
  final TextEditingController _testTitleController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [
    {
      'question': TextEditingController(),
    },
  ];
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'question': TextEditingController(),
      });
      _currentQuestionIndex = _questions.length - 1;
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      if (_currentQuestionIndex >= _questions.length) {
        _currentQuestionIndex = _questions.length - 1;
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _addQuestion();
    }
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      loggedInUserId = user?.uid;
    });
  }

  void _saveTest() async {
    // Ensure loggedInUserId is set
    getCurrentUser();

    if (loggedInUserId == null) {
      showCustomSnackbar(context, 'User not logged in!');
      return;
    }

    String testTitle = _testTitleController.text.trim();

    if (testTitle.isEmpty) {
      showCustomSnackbar(context, 'Please fill in the test title.');
      return;
    }
    bool hasInvalidQuestion = false;
    String invalidQuestionMessage = '';

    for (var question in _questions) {
      String questionText = question['question'].text.trim();

      if (questionText.isEmpty) {
        invalidQuestionMessage = 'Question text cannot be empty.';
        hasInvalidQuestion = true;
        break;
      }
    }
    if (hasInvalidQuestion) {
      showCustomSnackbar(context, invalidQuestionMessage);
      return;
    }

    try {
      // Generate a new document ID for the test
      String testID = FirebaseFirestore.instance.collection('test').doc().id;

      // Create the test data map
      Map<String, dynamic> testData = {
        'audio': '-',
        'testID': testID,
        'generationDate': Timestamp.now(),
        'testTitle': _testTitleController.text,
        'classID': widget.classID,
      };

      // Create the assessment data map
      Map<String, dynamic> assessmentData = {
        'assessmentID': testID,
        'classID': widget.classID,
        'generationDate': Timestamp.now(),
        'type': 'test',
        'userID': loggedInUserId,
      };

      // Save the test data to Firestore
      await FirebaseFirestore.instance
          .collection('test')
          .doc(testID)
          .set(testData);

      // Save the assessment data to Firestore
      await FirebaseFirestore.instance
          .collection('assessments')
          .doc(testID)
          .set(assessmentData);

      // Save questions
      for (var question in _questions) {
        // Generate a new document ID for each question
        String questionID =
            FirebaseFirestore.instance.collection('testquestion').doc().id;

        // Only save questions that have a non-empty title
        if (question['question'].text.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('testquestion')
              .doc(questionID)
              .set({
            'testID': testID,
            'questionID': questionID,
            'question': question['question'].text,
          });
        }
      }

      // After saving, show the custom snackbar
      showCustomSnackbar(context, 'Test created successfully!');
    } catch (e) {
      // Handle any errors that occur during the save operation
      showCustomSnackbar(context, 'Error creating test: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: mainappbar(
        "Add New Test",
        "This is the Add New Test screen for ${widget.className}.",
        context,
        showBackIcon: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.className,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _testTitleController,
              decoration: InputDecoration(
                hintText: 'Enter test title...',
                hintStyle:
                    const TextStyle(color: Color.fromRGBO(113, 118, 121, 1)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Question'),
                            content: const Text(
                                'Are you sure you want to delete this question?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteQuestion(_currentQuestionIndex);
                                  Navigator.of(context)
                                      .pop(); // Close the dialog after deletion
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.green),
                      onPressed: _addQuestion,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextField(
                        maxLines: 14,
                        controller: _questions[_currentQuestionIndex]
                            ['question'],
                        decoration: InputDecoration(
                          hintText: 'Enter question...',
                          hintStyle: const TextStyle(
                              color: Color.fromRGBO(113, 118, 121, 1)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 12.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTest,
        backgroundColor: const Color.fromRGBO(101, 143, 172, 1),
        icon: const Icon(Icons.save_sharp, color: Colors.white),
        label: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
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
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
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
