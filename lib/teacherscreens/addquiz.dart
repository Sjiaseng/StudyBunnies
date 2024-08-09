import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddQuiz extends StatefulWidget {
  final String classID;
  final String className;

  const AddQuiz({super.key, required this.className, required this.classID});

  @override
  // ignore: library_private_types_in_public_api
  _AddQuizState createState() => _AddQuizState();
}

class _AddQuizState extends State<AddQuiz> {
  String? loggedInUserId;
  final TextEditingController _quizTitleController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [
    {
      'question': TextEditingController(),
      'options': [TextEditingController(), TextEditingController()],
      'correctOptionIndex': 0,
    },
  ];
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void _addOption(int questionIndex) {
    setState(() {
      _questions[questionIndex]['options'].add(TextEditingController());
    });
  }

  void _deleteOption(int questionIndex, int optionIndex) {
    setState(() {
      _questions[questionIndex]['options'].removeAt(optionIndex);
      if (_questions[questionIndex]['correctOptionIndex'] == optionIndex) {
        _questions[questionIndex]['correctOptionIndex'] = 0;
      } else if (_questions[questionIndex]['correctOptionIndex'] >
          optionIndex) {
        _questions[questionIndex]['correctOptionIndex']--;
      }
    });
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'question': TextEditingController(),
        'options': [TextEditingController()],
        'correctOptionIndex': 0,
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

  void _saveQuiz() async {
    // Ensure loggedInUserId is set
    getCurrentUser();

    if (loggedInUserId == null) {
      showCustomSnackbar(context, 'User not logged in!');
      return;
    }

    String quizTitle = _quizTitleController.text.trim();

    if (quizTitle.isEmpty) {
      showCustomSnackbar(context, 'Please fill in the quiz title.');
      return;
    }
    bool hasInvalidQuestion = false;
    String invalidQuestionMessage = '';

    // Check if each question has at least one non-empty option
    for (var question in _questions) {
      String questionText = question['question'].text.trim();
      List<TextEditingController> options = question['options'];

      if (questionText.isEmpty) {
        invalidQuestionMessage = 'Question text cannot be empty.';
        hasInvalidQuestion = true;
        break;
      }

      // Check if there are any non-empty options
      bool hasNonEmptyOption =
          options.any((controller) => controller.text.trim().isNotEmpty);

      if (!hasNonEmptyOption) {
        invalidQuestionMessage =
            'At least one option must be provided for each question.';
        hasInvalidQuestion = true;
        break;
      }
    }

    if (hasInvalidQuestion) {
      showCustomSnackbar(context, invalidQuestionMessage);
      return;
    }

    try {
      // Generate a new document ID for the quiz
      String quizID = FirebaseFirestore.instance.collection('quiz').doc().id;

      // Create the quiz data map
      Map<String, dynamic> quizData = {
        'audio': '-',
        'quizID': quizID,
        'generationDate': Timestamp.now(),
        'quizTitle': _quizTitleController.text,
        'classID': widget.classID,
      };

      // Create the assessment data map
      Map<String, dynamic> assessmentData = {
        'assessmentID': quizID,
        'classID': widget.classID,
        'generationDate': Timestamp.now(),
        'type': 'quiz',
        'userID': loggedInUserId,
      };

      // Save the quiz data to Firestore
      await FirebaseFirestore.instance
          .collection('quiz')
          .doc(quizID)
          .set(quizData);

      // Save the assessment data to Firestore
      await FirebaseFirestore.instance
          .collection('assessments')
          .doc(quizID)
          .set(assessmentData);

      // Save questions and options
      for (var question in _questions) {
        // Generate a new document ID for each question
        String questionID =
            FirebaseFirestore.instance.collection('quizquestion').doc().id;

        // Only save questions that have a non-empty title
        if (question['question'].text.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('quizquestion')
              .doc(questionID)
              .set({
            'quizID': quizID, // Reference the newly created quiz
            'questionID': questionID, // Reference the newly created question
            'question': question['question'].text,
            'choices': question['options']
                .map((controller) => controller.text)
                .toList(),
            'correctOption': question['correctOptionIndex'],
          });
        }
      }

      // After saving, show the custom snackbar
      showCustomSnackbar(context, 'Quiz created successfully!');

    } catch (e) {
      // Handle any errors that occur during the save operation
      showCustomSnackbar(context, 'Error creating quiz: $e');
    }
  }

  @override
  void dispose() {
    _quizTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: mainappbar(
        "Add New Quiz",
        "This is the Add New Quiz screen for ${widget.className}.",
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
              controller: _quizTitleController,
              decoration: InputDecoration(
                hintText: 'Enter quiz title...',
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
                        if (_questions.length > 1) {
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
                        }
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
                      child: Column(
                        children: [
                          TextField(
                            maxLines: 4,
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
                          const SizedBox(height: 10),
                          ..._questions[_currentQuestionIndex]['options']
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            TextEditingController optionController =
                                entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: index,
                                    groupValue:
                                        _questions[_currentQuestionIndex]
                                            ['correctOptionIndex'],
                                    onChanged: (value) {
                                      setState(() {
                                        _questions[_currentQuestionIndex]
                                            ['correctOptionIndex'] = value!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: optionController,
                                      decoration: InputDecoration(
                                        labelText: 'Option ${index + 1}',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 15.0,
                                          horizontal: 12.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteOption(
                                          _currentQuestionIndex, index);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          TextButton(
                            onPressed: () {
                              _addOption(_currentQuestionIndex);
                            },
                            child: const Text('+ Add New Option'),
                          ),
                        ],
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
        onPressed: _saveQuiz,
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
