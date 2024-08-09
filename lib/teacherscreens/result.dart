import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'package:studybunnies/teacherwidgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Result extends StatefulWidget {
  final String assessmentID;

  const Result({super.key, required this.assessmentID});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  String className = '';
  String quizTitle = '';
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResults();
    _searchController.addListener(_filterStudents);
  }

  Future<void> fetchResults() async {
    try {
      // Fetch quiz title using assessmentID
      DocumentSnapshot quizDoc = await FirebaseFirestore.instance
          .collection('quiz')
          .doc(widget.assessmentID)
          .get();

      if (quizDoc.exists) {
        quizTitle = quizDoc.exists ? quizDoc['quizTitle'] : 'Title not found';
      }

      // Fetch classID using assessmentID
      final assessmentDoc = await FirebaseFirestore.instance
          .collection('assessments')
          .doc(widget.assessmentID)
          .get();

      if (assessmentDoc.exists) {
        final classID = assessmentDoc.data()?['classID'];

        // Fetch classname using classID
        if (classID != null) {
          final classDoc = await FirebaseFirestore.instance
              .collection('classes')
              .doc(classID)
              .get();

          if (classDoc.exists) {
            className = classDoc.data()?['classname'] ?? 'Class Name Not Found';
          }
        }

        // Fetch students' scores using assessmentID
        final scoresQuery = await FirebaseFirestore.instance
            .collection('studentQuizAnswer')
            .where('quizID', isEqualTo: widget.assessmentID)
            .get();

        for (var scoreDoc in scoresQuery.docs) {
          final studentID = scoreDoc.data()['studentID'];

          // Fetch username using studentID
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(studentID)
              .get();

          if (userDoc.exists) {
            students.add({
              'username': userDoc.data()?['username'] ?? 'Unknown User',
              'profile_img': userDoc.data()?['profile_img'] ??
                  'images/default_profile.jpg', // Default image
              'score': scoreDoc.data()['score'] ?? 0,
            });
          }
        }

        // Initialize filtered students
        _filteredStudents = List.from(students);

        // Refresh the UI after fetching all data
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle errors here, like showing an error message
      print("Error fetching results: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = query.isEmpty
          ? List.from(students)
          : students
              .where((student) =>
                  student['username']!.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStudents);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    return GestureDetector(
      child: Scaffold(
        appBar: mainappbar("Results", "This is the results screen.", context,
            showBackIcon: true),
        drawer: teacherDrawer(context, 2, drawercurrentindex: 2),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      className,
                      style: TextStyle(
                        color: const Color.fromRGBO(61, 47, 34, 1),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      quizTitle,
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
              Container(
                margin: const EdgeInsets.only(bottom: 15.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search students...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const CircularProgressIndicator()
                  : _filteredStudents.isEmpty
                      ? const Text('No results found.')
                      : Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            thickness: 6.0,
                            radius: const Radius.circular(8.0),
                            child: ListView.builder(
                              itemCount: _filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = _filteredStudents[index];
                                return Container(
                                  width: 90.w,
                                  padding: EdgeInsets.all(2.w),
                                  margin: EdgeInsets.only(bottom: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: student[
                                                        'profile_img'] !=
                                                    null &&
                                                student['profile_img']!
                                                    .isNotEmpty
                                            ? NetworkImage(
                                                student['profile_img']!)
                                            : const AssetImage(
                                                    'images/default_profile.jpg')
                                                as ImageProvider,
                                        radius: 7.w,
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Text(
                                          student['username']!,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontFamily: 'Roboto',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${student['score']}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromRGBO(
                                              61, 47, 34, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
            ],
          ),
        ),
        bottomNavigationBar: navbar(2),
      ),
    );
  }
}
