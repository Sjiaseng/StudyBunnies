import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class QuizTestList extends StatefulWidget {
  const QuizTestList({super.key});

  @override
  State<QuizTestList> createState() => _QuizTestListState();
}

class _QuizTestListState extends State<QuizTestList> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  late Future<Map<String, List<String>>> _futureData;
  final TextEditingController _searchController = TextEditingController();
  List<String> _quizzes = [];
  List<String> _tests = [];
  List<String> _filteredQuizzes = [];
  List<String> _filteredTests = [];
  // String _debugMessage = ''; // Commented out the debug message variable

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

  Future<Map<String, List<String>>> _fetchUserIDAndData() async {
    final userID = await storage.read(key: 'userID');

    if (userID == null) {
      // Commented out debug message
      // setState(() {
      //   _debugMessage = 'User ID is null';
      // });
      return {'quizzes': [], 'tests': []};
    }

    try {
      // Commented out debug message
      // setState(() {
      //   _debugMessage = 'Fetching classID for userID: $userID';
      // });

      final classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('student', arrayContains: userID)
          .get();

      if (classSnapshot.docs.isEmpty) {
        // Commented out debug message
        // setState(() {
        //   _debugMessage = 'No classes found for userID $userID';
        // });
        return {'quizzes': [], 'tests': []};
      } else {
        final classID = classSnapshot.docs.first.id;
        // Commented out debug message
        // setState(() {
        //   _debugMessage = 'ClassID found: $classID';
        // });

        final quizzesFuture = FirebaseFirestore.instance
            .collection('quiz')
            .where('classID', isEqualTo: classID)
            .get()
            .then((snapshot) => snapshot.docs.map((doc) => doc['quizTitle'] as String).toList());

        final testsFuture = FirebaseFirestore.instance
            .collection('test')
            .where('classID', isEqualTo: classID)
            .get()
            .then((snapshot) => snapshot.docs.map((doc) => doc['testTitle'] as String).toList());

        final quizzes = await quizzesFuture;
        final tests = await testsFuture;

        setState(() {
          _quizzes = quizzes;
          _tests = tests;
          _filteredQuizzes = quizzes;
          _filteredTests = tests;
          // Commented out debug message
          // _debugMessage = 'Quizzes and tests fetched successfully';
        });

        return {'quizzes': quizzes, 'tests': tests};
      }
    } catch (e) {
      // Commented out debug message
      // setState(() {
      //   _debugMessage = 'Error fetching data: $e';
      // });
      return {'quizzes': [], 'tests': []};
    }
  }

  void _filterSearchResults() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredQuizzes = _quizzes.where((quiz) => quiz.toLowerCase().contains(query)).toList();
      _filteredTests = _tests.where((test) => test.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar(
        "Quizzes & Tests",
        "This section consists of student quizzes and tests.",
        context,
      ),
      drawer: StudentDrawer(drawercurrentindex: 3, userID: 'userID'),
      bottomNavigationBar: navbar(3),
      body: FutureBuilder<Map<String, List<String>>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Commented out debug message
            // setState(() {
            //   _debugMessage = 'Error: ${snapshot.error}';
            // });
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            // Commented out debug message
            // setState(() {
            //   _debugMessage = 'No data available';
            // });
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            final quizzes = data['quizzes']!;
            final tests = data['tests']!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Quizzes & Tests',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Center(
                    child: Text(
                      'Quizzes',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    children: _filteredQuizzes.map((quiz) {
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
                            color: const Color.fromRGBO(241, 241, 241, 1),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      quiz,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Implement onTap functionality
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.grey,
                                        ),
                                        child: const Text('Attempt'),
                                      ),
                                      const SizedBox(width: 8.0), // Space between buttons
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Implement onTap functionality
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.grey, // You can choose a different color
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
                  const SizedBox(height: 32.0),
                  const Center(
                    child: Text(
                      'Tests',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    children: _filteredTests.map((test) {
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
                            color: const Color.fromRGBO(241, 241, 241, 1),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      test,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Implement onTap functionality
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.grey,
                                        ),
                                        child: const Text('Attempt'),
                                      ),
                                      const SizedBox(width: 8.0), // Space between buttons
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Implement onTap functionality
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.grey, // You can choose a different color
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
            );
          }
        },
      ),
    );
  }
}
