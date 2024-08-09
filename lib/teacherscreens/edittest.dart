import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/snackbar.dart';

class EditTest extends StatefulWidget {
  final String classID;
  final String className;
  final String testID;
  final String testTitle;

  const EditTest({
    super.key,
    required this.classID,
    required this.className,
    required this.testID,
    required this.testTitle,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditTestState createState() => _EditTestState();
}

class _EditTestState extends State<EditTest> {
  final TextEditingController _testTitleController = TextEditingController();
  List<Map<String, dynamic>> existingTestQuestions = [];

  int _currentQuestionIndex = 0;
  String? loggedInUserId;

  @override
  void initState() {
    super.initState();
    _fetchTestData();
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
      existingTestQuestions = existingTestQuestions.map((q) {
        return {
          'questionID': q['questionID'],
          'question':
              TextEditingController(text: q['question'] as String? ?? ''),
        };
      }).toList();
    });
  }

  Future<void> _fetchTestData() async {
    try {
      DocumentSnapshot testSnapshot = await FirebaseFirestore.instance
          .collection('test')
          .doc(widget.testID)
          .get();

      if (testSnapshot.exists) {
        _testTitleController.text = testSnapshot["testTitle"];

        QuerySnapshot questionsSnapshot = await FirebaseFirestore.instance
            .collection('testquestion')
            .where('testID', isEqualTo: widget.testID)
            .get();

        List<Map<String, dynamic>> fetchedQuestions =
            questionsSnapshot.docs.map((doc) {
          return {
            'questionID': doc.id,
            'question': doc['question'] ?? '',
          };
        }).toList();

        setState(() {
          existingTestQuestions = fetchedQuestions;
          _updateExistingQuestions();
        });
      }
    } catch (e) {
      print('Error fetching quiz data: $e');
    }
  }

  @override
  void dispose() {
    _testTitleController.dispose();
    for (var question in existingTestQuestions) {
      question['question'].dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      existingTestQuestions.add({
        'questionID': null,
        'question': TextEditingController(),
      });
      _currentQuestionIndex = existingTestQuestions.length - 1;
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      existingTestQuestions[index]['question'].dispose();
      existingTestQuestions.removeAt(index);
      if (_currentQuestionIndex >= existingTestQuestions.length) {
        _currentQuestionIndex = existingTestQuestions.length - 1;
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
      if (_currentQuestionIndex < existingTestQuestions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _addQuestion();
      }
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

    try {
      // Update existing test or create a new one
      final testRef =
          FirebaseFirestore.instance.collection('test').doc(widget.testID);

      Map<String, dynamic> testData = {
        'audio': '-',
        'testTitle': _testTitleController.text,
        'classID': widget.classID,
        'generationDate': Timestamp.now(),
        'testID': widget.testID,
      };

      await testRef.set(testData, SetOptions(merge: true));

      Map<String, dynamic> assessmentData = {
        'assessmentID': widget.testID,
        'classID': widget.classID,
        'generationDate': Timestamp.now(),
        'type': 'test',
        'userID': loggedInUserId,
      };

      await FirebaseFirestore.instance
          .collection('assessments')
          .doc(widget.testID)
          .set(assessmentData, SetOptions(merge: true));

      // Update existing questions and add new ones
      final questionsCollection =
          FirebaseFirestore.instance.collection('testquestion');
      //final existingQuestionIDs = existingTestQuestions.where((q) => q['questionID'] != null).map((q) => q['questionID'] as String).toSet();

      // Get all current question IDs from Firestore
      final currentQuestions = await questionsCollection
          .where('testID', isEqualTo: widget.testID)
          .get();
      final currentQuestionIDs =
          currentQuestions.docs.map((doc) => doc.id).toSet();

      // Remove old questions that are no longer in the list
      final toRemoveIDs = currentQuestionIDs.difference(existingTestQuestions
          .where((q) => q['questionID'] != null)
          .map((q) => q['questionID'] as String)
          .toSet());
      for (String id in toRemoveIDs) {
        await questionsCollection.doc(id).delete();
      }

      // Add or update questions
      for (var question in existingTestQuestions) {
        String questionID = question['questionID'] ??
            FirebaseFirestore.instance.collection('testquestion').doc().id;

        if (question['question'].text.isNotEmpty) {
          await questionsCollection.doc(questionID).set({
            'testID': widget.testID,
            'questionID': questionID,
            'question': question['question'].text,
          });
        }
      }

      // ignore: use_build_context_synchronously
      showCustomSnackbar(context, 'Test updated successfully!');
    } catch (e) {
      print('Error updating test: $e');
      // ignore: use_build_context_synchronously
      showCustomSnackbar(context, 'Error updating test: $e');
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
        "Edit Test",
        "This is the Edit Test screen for ${widget.className}.",
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
                    if (existingTestQuestions.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextField(
                          maxLines: 10,
                          controller:
                              existingTestQuestions[_currentQuestionIndex]
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
