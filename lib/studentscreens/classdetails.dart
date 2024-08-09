import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/authentication/session.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/timetable.dart';
import 'package:studybunnies/studentscreens/viewnotes.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentscreens/quizreview.dart';
import 'package:studybunnies/studentscreens/testreview.dart';
import 'package:studybunnies/studentscreens/quizdetailspage.dart';
import 'package:studybunnies/studentscreens/testdetailspage.dart';

class Classdetails extends StatefulWidget {
  final String className;
  final String classID;
  final String userID;

  const Classdetails({
    super.key,
    required this.className,
    required this.classID,
    required this.userID,
  });

  @override
  State<Classdetails> createState() => _ClassdetailsState();
}

class _ClassdetailsState extends State<Classdetails> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _notes = [];
  List<Map<String, String>> _filteredNotes = [];
  List<Map<String, String>> _quizzes = [];
  List<Map<String, String>> _filteredQuizzes = [];
  List<Map<String, String>> _tests = [];
  List<Map<String, String>> _filteredTests = [];
  String? _userID;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterData);
    _fetchNotes();
    _fetchQuizzes();
    _fetchTests();
    _fetchUserID();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterData);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserID() async {
    final session = Session();
    final userID = await session.getUserId();
    setState(() {
      _userID = userID;
    });
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = query.isEmpty
          ? List.from(_notes)
          : _notes
              .where((note) => note['noteTitle']!.toLowerCase().contains(query))
              .toList();
      _filteredQuizzes = query.isEmpty
          ? List.from(_quizzes)
          : _quizzes
              .where((quiz) => quiz['quizTitle']!.toLowerCase().contains(query))
              .toList();
      _filteredTests = query.isEmpty
          ? List.from(_tests)
          : _tests
              .where((test) => test['testTitle']!.toLowerCase().contains(query))
              .toList();
    });
  }

 // Fetch Notes by classID
  Future<void> _fetchNotes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('classID', isEqualTo: widget.classID)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No notes found for classID ${widget.classID}');
      } else {
        setState(() {
          _notes = snapshot.docs.map((doc) {
            final noteTitle = doc['noteTitle'] as String;
            final noteID = doc.id;
            return {'noteTitle': noteTitle, 'noteID': noteID};
          }).toList();
          _filteredNotes = List.from(_notes);
        });
      }
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

// Fetch Quizzes by classID
  Future<void> _fetchQuizzes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quiz')
          .where('classID', isEqualTo: widget.classID)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No quizzes found for classID ${widget.classID}');
      } else {
        setState(() {
          _quizzes = snapshot.docs.map((doc) {
            final quizTitle = doc['quizTitle'] as String;
            final quizID = doc.id;
            return {'quizTitle': quizTitle, 'quizID': quizID};
          }).toList();
          _filteredQuizzes = List.from(_quizzes);
        });
      }
    } catch (e) {
      print('Error fetching quizzes: $e');
    }
  }

// Fetch Tests by classID
  Future<void> _fetchTests() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('test')
          .where('classID', isEqualTo: widget.classID)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No tests found for classID ${widget.classID}');
      } else {
        setState(() {
          _tests = snapshot.docs.map((doc) {
            final testTitle = doc['testTitle'] as String;
            final testID = doc.id;
            return {'testTitle': testTitle, 'testID': testID};
          }).toList();
          _filteredTests = List.from(_tests);
        });
      }
    } catch (e) {
      print('Error fetching tests: $e');
    }
  }

// Function to pass data when navigate to Quiz Details Page
  void _navigateToQuizDetails(String quizID) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        duration: const Duration(milliseconds: 305),
        child: QuizDetailsPage(
          userID: _userID!,
          classID: widget.classID,
          quizID: quizID,
        ),
      ),
    );
  }

// Function to pass data when navigate to Quiz Review Page
  void _navigateToQuizReview(String quizID) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        duration: const Duration(milliseconds: 305),
        child: QuizReview(
          userID: _userID!,
          classID: widget.classID,
          quizID: quizID,
        ),
      ),
    );
  }

// Function to pass data when navigate to Test Details Page
  void _navigateToTestDetails(String testID) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        duration: const Duration(milliseconds: 305),
        child: TestDetailsPage(
          userID: _userID!,
          classID: widget.classID,
          testID: testID,
        ),
      ),
    );
  }

// Function to pass data when navigate to Test Review Page
  void _navigateToTestReview(String testID) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        duration: const Duration(milliseconds: 305),
        child: TestReview(
          userID: _userID!,
          classID: widget.classID,
          testID: testID,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: const Timetablelist(),
            ),
          );
        }
        if (details.delta.dx < -25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const StudentDashboard(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar(
          widget.className,
          "This page contains all information for the notes section",
          context,
        ),
        bottomNavigationBar: navbar(1),
        drawer: StudentDrawer(
          drawercurrentindex: 2,
          userID: _userID ?? 'guest',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  hintText: 'Search Notes, Quizzes, and Tests',
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      )),
                ),
              ),
              const SizedBox(height: 16.0),
              // Notes Section
              const Center(
                child: Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: _filteredNotes.map((noteData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(217, 217, 217, 1),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: const Color.fromRGBO(195, 172, 151, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  noteData['noteTitle']!,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromRGBO(61, 12, 2, 1),
                                    fontFamily: 'Times New Roman',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          duration:
                                              const Duration(milliseconds: 305),
                                          child: ViewNotes(
                                            noteTitle: noteData['noteTitle']!,
                                            classID: widget.classID,
                                            className: widget.className,
                                            noteID: noteData['noteID']!,
                                            userID: _userID ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Times New Roman',
                                        color: Colors.brown,
                                      ),
                                      foregroundColor: Colors.black,
                                      backgroundColor:
                                          const Color.fromRGBO(152, 118, 84, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                          color:
                                              Color.fromRGBO(152, 118, 84, 1),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: const Text('View'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              // Quizzes Section
              const Center(
                child: Text(
                  'Quizzes',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: _filteredQuizzes.map((quizData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(217, 217, 217, 1),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: const Color.fromRGBO(
                            195, 172, 151, 1), // Card color
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  quizData['quizTitle']!,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromRGBO(
                                        61, 12, 2, 1), // Quiz Title Color
                                    fontFamily: 'Times New Roman',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _navigateToQuizDetails(
                                          quizData['quizID']!);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Times New Roman',
                                      ),
                                      foregroundColor: Colors.black,
                                      backgroundColor: const Color.fromRGBO(131,
                                          105, 83, 1), // Attempt Button Color
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                          color: Color.fromRGBO(131, 105, 83,
                                              1), // Attempt Border Color
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Attempt'),
                                  ),
                                  const SizedBox(width: 8.0),
                                  TextButton(
                                    onPressed: () {
                                      _navigateToQuizReview(
                                          quizData['quizID']!);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Times New Roman',
                                      ),
                                      foregroundColor: Colors.black,
                                      backgroundColor: const Color.fromRGBO(152,118, 84, 1), // Review Button Color
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                          color: Color.fromRGBO(152, 118, 84,1), // Review Border Color
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Review'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              // Tests Section
              const Center(
                child: Text(
                  'Tests',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: _filteredTests.map((testData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(217, 217, 217, 1),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: const Color.fromRGBO(195, 172, 151, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  testData['testTitle']!,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromRGBO(61, 12, 2, 1),
                                    fontFamily: 'Times New Roman',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _navigateToTestDetails(
                                          testData['testID']!);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Times New Roman',
                                      ),
                                      foregroundColor: Colors.black,
                                      backgroundColor:
                                          const Color.fromRGBO(131, 105, 83, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                          color:
                                              Color.fromRGBO(131, 105, 83, 1),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Attempt'),
                                  ),
                                  const SizedBox(width: 8.0),
                                  TextButton(
                                    onPressed: () {
                                      _navigateToTestReview(
                                          testData['testID']!);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Times New Roman',
                                      ),
                                      foregroundColor: Colors.black,
                                      backgroundColor:
                                          const Color.fromRGBO(152, 118, 84, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                          color:
                                              Color.fromRGBO(152, 118, 84, 1),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Review'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
