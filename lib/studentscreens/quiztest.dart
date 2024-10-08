import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:studybunnies/studentwidgets/drawer.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentscreens/quizreview.dart';
import 'package:studybunnies/studentscreens/testreview.dart';
import 'package:studybunnies/studentscreens/quizdetailspage.dart';
import 'package:studybunnies/studentscreens/testdetailspage.dart'; 





class QuizTestList extends StatefulWidget {
  const QuizTestList({super.key});

  @override
  State<QuizTestList> createState() => _QuizTestListState();
}

class _QuizTestListState extends State<QuizTestList> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late Future<Map<String, Map<String, List<String>>>> _futureData;
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<String>> _quizzesByClass = {};
  Map<String, List<String>> _testsByClass = {};
  Map<String, List<String>> _filteredQuizzesByClass = {};
  Map<String, List<String>> _filteredTestsByClass = {};

  late String quizID;
  late String quizTitle;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSearchResults);
    _futureData = _fetchUserIDAndData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSearchResults);
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, Map<String, List<String>>>> _fetchUserIDAndData() async {
    final userID = await storage.read(key: 'userID');

    if (userID == null) {
      return {'quizzes': {}, 'tests': {}};
    }

    try {
      final classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('student', arrayContains: userID)
          .get();

      if (classSnapshot.docs.isEmpty) {
        return {'quizzes': {}, 'tests': {}};
      } else {
        final classData = classSnapshot.docs;
        final classIDs = classData.map((doc) => doc.id).toList();
        final classNames = classData.fold<Map<String, String>>(
          {},
          (map, doc) {
            map[doc.id] = doc['classname'] as String;
            return map;
          },
        );

        final quizzesByClass = <String, List<String>>{};
        final testsByClass = <String, List<String>>{};

        for (var classID in classIDs) {
          final quizzesFuture = FirebaseFirestore.instance
              .collection('quiz')
              .where('classID', isEqualTo: classID)
              .get()
              .then((snapshot) {
            return snapshot.docs
                .map((doc) => doc['quizTitle'] as String)
                .toList();
          });

          final testsFuture = FirebaseFirestore.instance
              .collection('test')
              .where('classID', isEqualTo: classID)
              .get()
              .then((snapshot) {
            return snapshot.docs
                .map((doc) => doc['testTitle'] as String)
                .toList();
          });

          final quizzes = await quizzesFuture;
          final tests = await testsFuture;

          quizzesByClass[classNames[classID] ?? classID] = quizzes;
          testsByClass[classNames[classID] ?? classID] = tests;
        }

        return {'quizzes': quizzesByClass, 'tests': testsByClass};
      }
    } catch (e) {
      print('Error fetching data: $e');
      return {'quizzes': {}, 'tests': {}};
    }
  }

  void _filterSearchResults() {
    final query = _searchController.text.toLowerCase();

    print("Search Query: $query");

    setState(() {
      // Filter quizzes
      _filteredQuizzesByClass = _quizzesByClass.map((className, quizzes) {
        final filteredQuizzes = quizzes
            .where((quiz) => quiz.toLowerCase().contains(query))
            .toList();
        print("Filtered Quizzes for $className: $filteredQuizzes");
        return MapEntry(className, filteredQuizzes);
      });

      // Filter tests
      _filteredTestsByClass = _testsByClass.map((className, tests) {
        final filteredTests =
            tests.where((test) => test.toLowerCase().contains(query)).toList();
        print("Filtered Tests for $className: $filteredTests");
        return MapEntry(className, filteredTests);
      });
    });
  }

// function to retrieve the userID, classID and testID and pass it to TestDetailsPage
  Future<void> _navigateToTestDetails(
      String className, String testTitle) async {
    final userID = await storage.read(key: 'userID') ?? '';

    try {
      // Fetch classID from className
      final classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('classname', isEqualTo: className)
          .get();

      if (classSnapshot.docs.isEmpty) {
        // Handle case where no class is found
        print('Class not found');
        return;
      }

      final classID = classSnapshot.docs.first.id;

      // Fetch testID from classID and testTitle
      final testSnapshot = await FirebaseFirestore.instance
          .collection('test')
          .where('classID', isEqualTo: classID)
          .where('testTitle', isEqualTo: testTitle)
          .get();

      if (testSnapshot.docs.isEmpty) {
        // Handle case where no test is found
        print('Test not found');
        return;
      }

      final testID = testSnapshot.docs.first.id;

      // Navigate to TestDetailsPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestDetailsPage(
            userID: userID,
            classID: classID,
            testID: testID,
          ),
        ),
      );
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

// function to retrieve the userID, classID and testID and pass it to TestReviewPage
  Future<void> _navigateToTestReview(String className, String testTitle) async {
    final userID = await storage.read(key: 'userID') ?? '';

    try {
      // Fetch classID from className
      final classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('classname', isEqualTo: className)
          .get();

      if (classSnapshot.docs.isEmpty) {
        // Handle case where no class is found
        print('Class not found');
        return;
      }

      final classID = classSnapshot.docs.first.id;

      // Fetch testID from classID and testTitle
      final testSnapshot = await FirebaseFirestore.instance
          .collection('test')
          .where('classID', isEqualTo: classID)
          .where('testTitle', isEqualTo: testTitle)
          .get();

      if (testSnapshot.docs.isEmpty) {
        // Handle case where no test is found
        print('Test not found');
        return;
      }

      final testID = testSnapshot.docs.first.id;

      // Navigate to TestDetailsPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestReview(
            userID: userID,
            classID: classID,
            testID: testID,
          ),
        ),
      );
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

// function to retrieve the userID, classID and quizID and pass it to QuizDetailsPage
  Future<void> _navigateToQuizDetails(
      String className, String quizTitle) async {
    final userID = await storage.read(key: 'userID') ?? '';

    try {
      // Fetch classID from className
      final classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('classname', isEqualTo: className)
          .get();

      if (classSnapshot.docs.isEmpty) {
        // Handle case where no class is found
        print('Class not found');
        return;
      }

      final classID = classSnapshot.docs.first.id;

      // Fetch quizID from classID and quizTitle
      final quizSnapshot = await FirebaseFirestore.instance
          .collection('quiz')
          .where('classID', isEqualTo: classID)
          .where('quizTitle', isEqualTo: quizTitle)
          .get();

      if (quizSnapshot.docs.isEmpty) {
        // Handle case where no quiz is found
        print('Quiz not found');
        return;
      }

      final quizID = quizSnapshot.docs.first.id;

      // Navigate to QuizDetailsPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizDetailsPage(
            userID: userID,
            classID: classID,
            quizID: quizID,
          ),
        ),
      );
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

// function to retrieve the userID, classID and quizID and pass it to QuizReviewPage
  Future<void> _navigateToQuizReview(String className, String quizTitle) async {
    final userID = await storage.read(key: 'userID') ?? '';

    try {
      // Fetch classID from className
      final classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('classname', isEqualTo: className)
          .get();

      if (classSnapshot.docs.isEmpty) {
        // Handle case where no class is found
        print('Class not found');
        return;
      }

      final classID = classSnapshot.docs.first.id;

      // Fetch quizID from classID and quizTitle
      final quizSnapshot = await FirebaseFirestore.instance
          .collection('quiz')
          .where('classID', isEqualTo: classID)
          .where('quizTitle', isEqualTo: quizTitle)
          .get();

      if (quizSnapshot.docs.isEmpty) {
        // Handle case where no quiz is found
        print('Quiz not found');
        return;
      }

      final quizID = quizSnapshot.docs.first.id;

      // Navigate to QuizReviewPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizReview(
            userID: userID,
            classID: classID,
            quizID: quizID,
          ),
        ),
      );
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar(
        "Quiz/Test",
        "This section consists of student quizzes and tests.",
        context,
      ),
      drawer: StudentDrawer(drawercurrentindex: 3, userID: 'userID'),
      bottomNavigationBar: inactivenavbar(),
      body: FutureBuilder<Map<String, Map<String, List<String>>>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            final quizzesByClass = data['quizzes']!;
            final testsByClass = data['tests']!;

            if (_quizzesByClass != quizzesByClass ||
                _testsByClass != testsByClass) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _quizzesByClass = quizzesByClass;
                  _testsByClass = testsByClass;
                  _filteredQuizzesByClass = _quizzesByClass;
                  _filteredTestsByClass = _testsByClass;
                  _filterSearchResults();
                });
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      hintText: 'Search Quizzes & Tests',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                            color: Colors.black), // Border color when focused
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Quizzes Section
                  if (_filteredQuizzesByClass.isNotEmpty) ...[
                    const Center(
                      child: Text(
                        'Quizzes',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    for (var className in _filteredQuizzesByClass.keys)
                      if (_filteredQuizzesByClass[className]!.isNotEmpty) ...[
                        Text(
                          className,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Georgia'
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Column(
                          children:
                              _filteredQuizzesByClass[className]!.map((quiz) {
                            final quizTitle = quiz;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        const Color.fromRGBO(217, 217, 217, 1),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Card(
                                  color: const Color.fromRGBO(195, 172, 151, 1),
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  elevation: 4,
                                  child: ListTile(
                                    title: Text(
                                      quizTitle,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Times New Roman',
                                        fontWeight:FontWeight.bold,
                                        color: Color.fromRGBO(61, 12, 2, 1), 
                                        ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _navigateToQuizDetails(
                                                className, quizTitle);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors
                                                .black, // Button text color
                                            backgroundColor: const Color.fromRGBO(131,105,83,1), // Attempt Button Color
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0)),
                                            minimumSize: const Size(40, 40),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                          ),
                                          child: const Text(
                                            'Attempt',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontFamily: 'Times New Roman',
                                              fontWeight: FontWeight.bold,
                                              ),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            _navigateToQuizReview(
                                                className, quizTitle);
                                            print(
                                                'New button pressed for $quizTitle');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black,
                                            backgroundColor: const Color.fromRGBO(152,118,84,1),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0)),
                                            minimumSize: const Size(40, 40),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                          ),
                                          child: const Text(
                                            'Review',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontFamily: "Times New Roman",
                                              fontWeight: FontWeight.bold,
                                              ),
                                          ),
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
                      ],
                  ],
                  // Tests Section
                  if (_filteredTestsByClass.isNotEmpty) ...[
                    const Center(
                      child: Text(
                        'Tests',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia'
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    for (var className in _filteredTestsByClass.keys)
                      if (_filteredTestsByClass[className]!.isNotEmpty) ...[
                        Text(
                          className,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Times New Roman',
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Column(
                          children:
                              _filteredTestsByClass[className]!.map((test) {
                            final testTitle = test;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        const Color.fromRGBO(217, 217, 217, 1),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Card(
                                  color: const Color.fromRGBO(195, 172, 151, 1),
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  elevation: 4,
                                  child: ListTile(
                                    title: Text(
                                      testTitle,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: "Times New Roman",
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(61, 12, 2, 1), // Quiz Title Color
                                      ),
                                      
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _navigateToTestDetails(
                                                className, testTitle);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors
                                                .black, // Button text color
                                            backgroundColor: const Color.fromRGBO(131,105,83,1), // Attempt Button Color
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0)),
                                            minimumSize: const Size(40, 40),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                          ),
                                          child: const Text(
                                            'Attempt',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontFamily: 'Times New Roman',
                                              fontWeight: FontWeight.bold,
                                              ),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            _navigateToTestReview(
                                                className, testTitle);
                                            print(
                                                'New button pressed for $testTitle');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black,
                                            backgroundColor: const Color.fromRGBO(152,118,84,1),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0)),
                                            minimumSize: const Size(40, 40),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                          ),
                                          child: const Text(
                                            'Review',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontFamily: "Times New Roman",
                                              fontWeight: FontWeight.bold,
                                              ),
                                          ),
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
                      ],
                  ],
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
