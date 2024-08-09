import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/teacherscreens/viewsubmission.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'package:studybunnies/teacherwidgets/drawer.dart';

class Submission extends StatefulWidget {
  final String assessmentID;

  const Submission({super.key, required this.assessmentID});

  @override
  State<Submission> createState() => _SubmissionState();
}

class _SubmissionState extends State<Submission> {
  List<Map<String, String?>> students = [];
  List<Map<String, String?>> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  String? className;
  String? testTitle;
  String? classID;
  String? testID;

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
    _searchController.addListener(_filterStudents);
  }

  Future<void> fetchSubmissions() async {
    try {
      // Step 1: Get test title from "test" collection
      DocumentSnapshot testDoc = await FirebaseFirestore.instance
          .collection('test')
          .doc(widget.assessmentID)
          .get();

      if (testDoc.exists) {
        testTitle = testDoc['testTitle'] ?? 'Title not found';
        testID = testDoc['testID'] ?? 'Test id not found';
      } else {
        print("Test document not found");
      }

      // Step 2: Get class ID from "assessments" collection
      final assessmentDoc = await FirebaseFirestore.instance
          .collection('assessments')
          .doc(widget.assessmentID)
          .get();

      if (assessmentDoc.exists) {
        final classID = assessmentDoc.data()?['classID'];

        // Step 3: Get class name from "classes" collection
        if (classID != null) {
          final classDoc = await FirebaseFirestore.instance
              .collection('classes')
              .doc(classID)
              .get();

          if (classDoc.exists) {
            className = classDoc.data()?['classname'] ?? 'Class Name Not Found';
          } else {
            print("Class document not found");
          }
        } else {
          print("Class ID is null");
        }

        // Step 4: Get student IDs from "studentTestAnswer" collection
        final studentQuery = await FirebaseFirestore.instance
            .collection('studentTestAnswer')
            .where('testID', isEqualTo: widget.assessmentID)
            .get();

        // Step 5: Get usernames for each studentID
        for (var studentDoc in studentQuery.docs) {
          final studentID = studentDoc.data()['studentID'];

          if (studentID != null) {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(studentID)
                .get();
            if (userDoc.exists) {
              students.add({
                'username': userDoc.data()?['username'] ?? 'Unknown User',
                'profile_img': userDoc.data()?['profile_img'] ??
                    'images/default_profile.jpg', // Default image
              });
            } else {
              print("User document not found for studentID: $studentID");
            }
          } else {
            print("StudentID is null");
          }
        }

        // Initialize filtered students
        _filteredStudents = List.from(students);

        // Refresh the UI
        setState(() {
          isLoading = false;
        });
      } else {
        print("Assessment document not found");
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
        appBar: mainappbar(
            "Submissions", "This is the submissions screen.", context,
            showBackIcon: true),
        drawer: teacherDrawer(
          context,
          2,
          drawercurrentindex: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      className ?? 'Loading...',
                      style: TextStyle(
                        color: const Color.fromRGBO(61, 47, 34, 1),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      testTitle ?? 'Loading...',
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
                      ? const Text('No submissions found.')
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
                                          student['username']!, // Fallback text
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontFamily: 'Roboto',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Handle view submission button press
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewSubmission(
                                                studentID:
                                                    student['studentID'] ??
                                                        'N/A',
                                                classID: classID ?? 'N/A',
                                                className: className ?? 'N/A',
                                                testID: testID ?? 'N/A',
                                                testTitle: testTitle ?? 'N/A',
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                              172, 130, 103, 1),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 5.0),
                                        ),
                                        child: const Text(
                                          'View',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
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
