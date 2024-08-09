import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';

class Progress extends StatefulWidget {
  final String studentName; // Receive student name
  final String studentId; // Receive student ID

  const Progress({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  List<Map<String, dynamic>> progressData = [];
  int completedQuizzes = 0;
  int completedTests = 0;
  int totalQuizzes = 0;
  int totalTests = 0;
  int totalCompleted = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProgressData();
  }

  Future<void> fetchProgressData() async {
    try {
      List<Map<String, dynamic>> quizData = await _fetchQuizData();
      List<Map<String, dynamic>> testData = await _fetchTestData();

      // Fetch total counts for quizzes and tests
      totalQuizzes = await _fetchTotalQuizzes();
      totalTests = await _fetchTotalTests();

      setState(() {
        progressData = [...quizData, ...testData];
        completedQuizzes = quizData.length;
        completedTests = testData.length;
        totalCompleted = completedQuizzes + completedTests;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching progress data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchQuizData() async {
    List<Map<String, dynamic>> data = [];
    QuerySnapshot quizAnswersSnapshot = await FirebaseFirestore.instance
        .collection('studentQuizAnswer')
        .where('studentID', isEqualTo: widget.studentId)
        .get();

    for (var doc in quizAnswersSnapshot.docs) {
      String quizID = doc['quizID'];
      int score = doc['score'];
      DocumentSnapshot quizSnapshot =
          await FirebaseFirestore.instance.collection('quiz').doc(quizID).get();
      String quizTitle = quizSnapshot['quizTitle'];
      String classID = quizSnapshot['classID'];
      DocumentSnapshot classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classID)
          .get();
      String className = classSnapshot['classname'];

      data.add({
        'class': className,
        'assessment': quizTitle,
        'score': score.toString(),
      });
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> _fetchTestData() async {
    List<Map<String, dynamic>> data = [];
    QuerySnapshot testAnswersSnapshot = await FirebaseFirestore.instance
        .collection('studentTestAnswer')
        .where('studentID', isEqualTo: widget.studentId)
        .get();

    for (var doc in testAnswersSnapshot.docs) {
      String testID = doc['testID'];
      String score = 'N/A';
      DocumentSnapshot testSnapshot =
          await FirebaseFirestore.instance.collection('test').doc(testID).get();
      String testTitle = testSnapshot['testTitle'];
      String classID = testSnapshot['classID'];
      DocumentSnapshot classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classID)
          .get();
      String className = classSnapshot['classname'];

      data.add({
        'class': className,
        'assessment': testTitle,
        'score': score,
      });
    }
    return data;
  }

  Future<int> _fetchTotalQuizzes() async {
    QuerySnapshot quizSnapshot =
        await FirebaseFirestore.instance.collection('quiz').get();
    return quizSnapshot.docs.length;
  }

  Future<int> _fetchTotalTests() async {
    QuerySnapshot testSnapshot =
        await FirebaseFirestore.instance.collection('test').get();
    return testSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    double percentage = totalQuizzes + totalTests > 0
        ? (totalCompleted / (totalQuizzes + totalTests)) * 100
        : 0;

    final data = [
      charts.Series<Map<String, dynamic>, String>(
        id: 'Quiz & Test Progress',
        domainFn: (Map<String, dynamic> row, _) => row['label'],
        measureFn: (Map<String, dynamic> row, _) => row['value'],
        data: [
          {'label': 'Completed', 'value': totalCompleted},
          {
            'label': 'Pending',
            'value': (totalQuizzes + totalTests) - totalCompleted
          },
        ],
      ),
    ];

    return Scaffold(
      appBar: mainappbar(
        "Student Progress",
        "This page contains the student's progress.",
        context,
        showBackIcon: true,
        showProfileIcon: true,
      ),
      bottomNavigationBar: navbar(3),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.studentName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color.fromRGBO(61, 47, 34, 1),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 45.w,
                        height: 25.h,
                        child: Card(
                          color: const Color.fromRGBO(243, 230, 176, 1),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    "Quiz & Test Done",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromRGBO(61, 47, 34, 1),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                SizedBox(
                                  height: 115,
                                  child: charts.PieChart(data, animate: true),
                                ),
                                Text(
                                  "${percentage.toStringAsFixed(1)}%",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: const Color.fromRGBO(61, 47, 34, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minWidth: constraints.maxWidth),
                            child: Scrollbar(
                              thumbVisibility: true,
                              thickness: 12.0,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DataTable(
                                    columnSpacing: 20.0,
                                    columns: [
                                      DataColumn(
                                          label: Text("Class",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromRGBO(
                                                      61, 47, 34, 1)))),
                                      DataColumn(
                                          label: Text("Quiz & Test",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromRGBO(
                                                      61, 47, 34, 1)))),
                                      DataColumn(
                                          label: Text("Score",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromRGBO(
                                                      61, 47, 34, 1)))),
                                    ],
                                    rows: progressData.map((data) {
                                      return DataRow(
                                        cells: [
                                          DataCell(FittedBox(
                                              child: Text(
                                                  data['class'] ?? 'N/A',
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          61, 47, 34, 1))))),
                                          DataCell(FittedBox(
                                              child: Text(
                                                  data['assessment'] ?? 'N/A',
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          61, 47, 34, 1))))),
                                          DataCell(FittedBox(
                                              child: Text(
                                                  data['score'] ?? 'N/A',
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          61, 47, 34, 1))))),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
