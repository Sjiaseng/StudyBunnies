import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditQuiz extends StatefulWidget {
  final String classID;
  final String className;
  final String quizID;
  final String quizTitle;

  const EditQuiz({
    super.key,
    required this.classID,
    required this.className,
    required this.quizID,
    required this.quizTitle,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditQuizState createState() => _EditQuizState();
}

class _EditQuizState extends State<EditQuiz> {
  final TextEditingController _quizTitleController = TextEditingController();
  List<Map<String, dynamic>> existingQuizQuestions = [];
  int _currentQuestionIndex = 0;
  String? loggedInUserId;

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
    getCurrentUser();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      loggedInUserId = user?.uid;
    });
  }

  void _updateExistingQuestions() {
    setState(() {
      existingQuizQuestions = existingQuizQuestions.map((q) {
        return {
          'questionID': q['questionID'],
          'question':
              TextEditingController(text: q['question'] as String? ?? ''),
          'choices': (q['choices'] as List<dynamic>?)?.map((choice) {
                return TextEditingController(text: choice as String);
              }).toList() ??
              [],
          'correctOption': q['correctOption'] as int,
        };
      }).toList();
    });
  }

  Future<void> _fetchQuizData() async {
    try {
      // Fetch data from Firestore
      DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance
          .collection('quiz')
          .doc(widget.quizID)
          .get();

      // Ensure the data is cast correctly
      if (quizSnapshot.exists) {
        Map<String, dynamic> quizData =
            quizSnapshot.data() as Map<String, dynamic>;
        _quizTitleController.text = quizData['quizTitle'] ?? '';

        QuerySnapshot questionsSnapshot = await FirebaseFirestore.instance
            .collection('quizquestion')
            .where('quizID', isEqualTo: widget.quizID)
            .get();

        List<Map<String, dynamic>> fetchedQuestions =
            questionsSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          return {
            'questionID': doc.id,
            'question': data['question'] as String? ?? '',
            'choices': (data['choices'] as List<dynamic>? ?? [])
                .map((choice) => choice as String)
                .toList(),
            'correctOption': data['correctOption'] as int,
          };
        }).toList();

        setState(() {
          existingQuizQuestions = fetchedQuestions;
          _updateExistingQuestions(); // Update with TextEditingControllers
        });
      }
    } catch (e) {
      print('Error fetching quiz data: $e');
    }
  }

  @override
  void dispose() {
    _quizTitleController.dispose();
    existingQuizQuestions.forEach((question) {
      question['question'].dispose();
      question['choices'].forEach((option) {
        option.dispose();
      });
    });
    super.dispose();
  }

  void _addOption(int questionIndex) {
    setState(() {
      existingQuizQuestions[questionIndex]['choices']
          .add(TextEditingController());
    });
  }

  void _deleteOption(int questionIndex, int optionIndex) {
    setState(() {
      existingQuizQuestions[questionIndex]['choices'].removeAt(optionIndex);
      if (existingQuizQuestions[questionIndex]['correctOption'] ==
          optionIndex) {
        existingQuizQuestions[questionIndex]['correctOption'] = 0;
      } else if (existingQuizQuestions[questionIndex]['correctOption'] >
          optionIndex) {
        existingQuizQuestions[questionIndex]['correctOption']--;
      }
    });
  }

  void _addQuestion() {
    setState(() {
      existingQuizQuestions.add({
        'questionID': null, // New questions won't have an ID until saved
        'question': TextEditingController(),
        'choices': [TextEditingController()],
        'correctOption': 0,
      });
      _currentQuestionIndex = existingQuizQuestions.length - 1;
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      existingQuizQuestions.removeAt(index);
      if (_currentQuestionIndex >= existingQuizQuestions.length) {
        _currentQuestionIndex = existingQuizQuestions.length - 1;
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
    setState(() {
      if (_currentQuestionIndex < existingQuizQuestions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _addQuestion();
      }
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
    try {
      // Update existing quiz or create a new one
      final quizRef =
          FirebaseFirestore.instance.collection('quiz').doc(widget.quizID);

      Map<String, dynamic> quizData = {
        'audio': '-',
        'quizTitle': _quizTitleController.text,
        'classID': widget.classID,
        'generationDate': Timestamp.now(),
        'quizID': widget.quizID,
      };

      await quizRef.set(quizData, SetOptions(merge: true));

      Map<String, dynamic> assessmentData = {
        'assessmentID': widget.quizID,
        'classID': widget.classID,
        'generationDate': Timestamp.now(),
        'type': 'quiz',
        'userID': loggedInUserId,

        /// why constantly get null
      };

      await FirebaseFirestore.instance
          .collection('assessments')
          .doc(widget.quizID)
          .set(assessmentData, SetOptions(merge: true));

      // Update existing questions and add new ones
      final questionsCollection =
          FirebaseFirestore.instance.collection('quizquestion');
      //final existingQuestionIDs = existingQuizQuestions.where((q) => q['questionID'] != null).map((q) => q['questionID'] as String).toSet();

      // Get all current question IDs from Firestore
      final currentQuestions = await questionsCollection
          .where('quizID', isEqualTo: widget.quizID)
          .get();
      final currentQuestionIDs =
          currentQuestions.docs.map((doc) => doc.id).toSet();

      // Remove old questions that are no longer in the list
      final toRemoveIDs = currentQuestionIDs.difference(existingQuizQuestions
          .where((q) => q['questionID'] != null)
          .map((q) => q['questionID'] as String)
          .toSet());
      for (String id in toRemoveIDs) {
        await questionsCollection.doc(id).delete();
      }

      // Add or update questions
      for (var question in existingQuizQuestions) {
        String questionID = question['questionID'] ??
            FirebaseFirestore.instance.collection('quizquestion').doc().id;

        if (question['question'].text.isNotEmpty) {
          await questionsCollection.doc(questionID).set({
            'quizID': widget.quizID,
            'questionID': questionID,
            'question': question['question'].text,
            'choices': question['choices']
                .map((controller) => controller.text)
                .toList(),
            'correctOption': question['correctOption'],
          });
        }
      }

      // ignore: use_build_context_synchronously
      showCustomSnackbar(context, 'Quiz updated successfully!');
    } catch (e) {
      print('Error updating quiz: $e');
      // ignore: use_build_context_synchronously
      showCustomSnackbar(context, 'Error updating quiz: $e');
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
        "Edit Quiz",
        "This is the Edit Quiz screen for ${widget.className}.",
        context,
        showBackIcon: true,
        showProfileIcon: false,
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
                    if (existingQuizQuestions
                        .isNotEmpty) // Ensure there are questions to display
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
                              controller:
                                  existingQuizQuestions[_currentQuestionIndex]
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
                            ...existingQuizQuestions[_currentQuestionIndex]
                                    ['choices']
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
                                      groupValue: existingQuizQuestions[
                                              _currentQuestionIndex]
                                          ['correctOption'],
                                      onChanged: (value) {
                                        setState(() {
                                          existingQuizQuestions[
                                                  _currentQuestionIndex]
                                              ['correctOption'] = value!;
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
                      )
                    else
                      const Text('No questions available.'),
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
              'Question ${_currentQuestionIndex + 1} of ${existingQuizQuestions.length}',
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
