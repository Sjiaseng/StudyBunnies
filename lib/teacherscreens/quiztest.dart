import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/teacherscreens/addquiz.dart';
import 'package:studybunnies/teacherscreens/addtest.dart';
import 'package:studybunnies/teacherscreens/editquiz.dart';
import 'package:studybunnies/teacherscreens/edittest.dart';
import 'package:studybunnies/teacherscreens/result.dart';
import 'package:studybunnies/teacherscreens/submission.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizTest extends StatefulWidget {
  final String classID;
  final String className;

  const QuizTest({super.key, required this.className, required this.classID});

  @override
  // ignore: library_private_types_in_public_api
  _QuizTestState createState() => _QuizTestState();
}

class _QuizTestState extends State<QuizTest> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredQuizTest = [];
  List<Map<String, String>> quizTests = [];
  String? loggedInUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuizTests();
    getCurrentUser().then((_) {
      _searchController.addListener(_filterQuizTest);
      fetchQuizTests();
    });
  }

  void _filterQuizTest() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredQuizTest = query.isEmpty
          ? List.from(quizTests)
          : quizTests
              .where((quizTest) =>
                  quizTest['title']!.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterQuizTest);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchQuizTests() async {
    if (loggedInUserId == null) return;

    try {
      final QuerySnapshot assessmentSnapshot = await FirebaseFirestore.instance
          .collection('assessments')
          .where('classID', isEqualTo: widget.classID)
          .get();
      List<Map<String, String>> fetchedQuizTests = [];
      for (var assessmentDoc in assessmentSnapshot.docs) {
        String type = assessmentDoc['type'];
        String assessmentID = assessmentDoc['assessmentID'];
        //String classID = assessmentDoc['classID'] ?? '';

        // Fetch the title based on the type
        String title = '';
        if (type == 'quiz') {
          DocumentSnapshot quizDoc = await FirebaseFirestore.instance
              .collection('quiz')
              .doc(assessmentID)
              .get();
          title = quizDoc.exists ? quizDoc['quizTitle'] : 'Title not found';
        } else if (type == 'test') {
          DocumentSnapshot testDoc = await FirebaseFirestore.instance
              .collection('test')
              .doc(assessmentID)
              .get();
          title = testDoc.exists ? testDoc['testTitle'] : 'Title not found';
        }

        fetchedQuizTests.add({
          'title': title,
          'type': type,
          'assessmentID': assessmentID,
        });
      }

      setState(() {
        quizTests = fetchedQuizTests;
        _filteredQuizTest = fetchedQuizTests;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors
      print("Error fetching quiz/tests: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      loggedInUserId = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: mainappbar(
        "Quiz & Test",
        "This is the Quiz & Test screen for ${widget.className}.",
        context,
        showBackIcon: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.className,
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search quizzes and tests...',
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Displaying quizzes and tests
                    ..._filteredQuizTest.map((item) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: item['type'] == 'quiz'
                                  ? const Color.fromARGB(255, 243, 230, 176)
                                  : const Color.fromARGB(255, 204, 230, 225),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    item['title']!,
                                    style: TextStyle(
                                      color:
                                          const Color.fromRGBO(61, 47, 34, 1),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _QuizTestButton(
                                      label: 'Edit',
                                      onPressed: () {
                                        // Navigate to Edit page based on type
                                        if (item['type'] == 'quiz') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditQuiz(
                                                classID: widget.classID,
                                                className: widget.className,
                                                quizID: item['assessmentID']!,
                                                quizTitle: item['title']!,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditTest(
                                                classID: widget.classID,
                                                className: widget.className,
                                                testID: item['assessmentID']!,
                                                testTitle: item['title']!,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    _QuizTestButton(
                                      label: item['type'] == 'test'
                                          ? 'Submissions'
                                          : 'Results',
                                      onPressed: () {
                                        // Navigate to Result or Submission page based on type
                                        if (item['type'] == 'quiz') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Result(
                                                assessmentID:
                                                    item['assessmentID']!,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Submission(
                                                //className: widget.className,
                                                assessmentID:
                                                    item['assessmentID']!,
                                                //testTitle: item['title']!,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: const Color.fromRGBO(113, 118, 121, 1),
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            labelBackgroundColor: const Color.fromARGB(255, 204, 230, 225),
            backgroundColor: const Color.fromARGB(255, 204, 230, 225),
            foregroundColor: const Color.fromRGBO(61, 47, 34, 1),
            child: const Icon(Icons.assignment),
            label: 'Add New Test',
            labelStyle: TextStyle(
              color: const Color.fromRGBO(61, 47, 34, 1),
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
            onTap: () {
              // Navigate to Add New Test page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddTest(
                          className: widget.className,
                          classID: widget.classID,
                        )),
              );
            },
          ),
          SpeedDialChild(
            labelBackgroundColor: const Color.fromARGB(255, 243, 230, 176),
            backgroundColor: const Color.fromARGB(255, 243, 230, 176),
            foregroundColor: const Color.fromRGBO(61, 47, 34, 1),
            child: const Icon(Icons.quiz),
            label: 'Add New Quiz',
            labelStyle: TextStyle(
              color: const Color.fromRGBO(61, 47, 34, 1),
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
            onTap: () {
              // Navigate to Add New Quiz page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddQuiz(
                          className: widget.className,
                          classID: widget.classID,
                        )),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: navbar(2),
    );
  }
}

class _QuizTestButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuizTestButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(172, 130, 103, 1),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(label, style: TextStyle(fontSize: 11.sp)),
    );
  }
}
