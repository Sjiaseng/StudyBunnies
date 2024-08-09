import 'package:flutter/material.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'package:studybunnies/teacherwidgets/drawer.dart';
import 'package:studybunnies/teacherscreens/point.dart';
import 'package:studybunnies/teacherscreens/progress.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  List<Map<String, String>> studentUserIDs = [];
  List<Map<String, String>> _filteredStudents = [];
  String? loggedInUserId;
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      loggedInUserId = user?.uid;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStudents);
    _fetchStudents();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStudents);
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = query.isEmpty
          ? List.from(studentUserIDs)
          : studentUserIDs
              .where((student) =>
                  student['username']!.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> _fetchStudents() async {
    try {
      // Fetch classes where the lecturer is the current user
      QuerySnapshot classesSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('lecturer', arrayContains: loggedInUserId)
          .get();

      // Collect userIDs of all students across all classes
      for (var classDoc in classesSnapshot.docs) {
        List<String> students = List<String>.from(classDoc['student']);
        for (var studentId in students) {
          if (!studentUserIDs
              .any((student) => student['userID'] == studentId)) {
            // Fetch username using studentId directly from the users collection
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(studentId)
                .get();

            if (userDoc.exists) {
              Map<String, dynamic>? userData =
                  userDoc.data() as Map<String, dynamic>?;

              studentUserIDs.add({
                'userID': studentId,
                'username': userData?['username'] ?? 'Unknown User',
                'profile_img': userData?['profile_img'] ??
                    'images/default_profile.jpg', // Default image
              });
            } else {
              studentUserIDs.add({
                'userID': studentId,
                'username': 'Unknown User',
                'profile_img': 'images/default_profile.jpg', // Default image
              });
            }
          }
        }
      }

      // Initialize filtered students
      setState(() {
        _filteredStudents = List.from(studentUserIDs);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching students: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: mainappbar("Student List",
            "This page contains the list of students.", context),
        bottomNavigationBar: navbar(3),
        drawer: teacherDrawer(
          context,
          3,
          drawercurrentindex: 3,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
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
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredStudents.isEmpty
                      ? const Center(child: Text('No students found.'))
                      : Expanded(
                          child: Scrollbar(
                            thumbVisibility: true, // Always show the scrollbar
                            thickness: 6.0,
                            radius: const Radius.circular(8.0),
                            child: ListView.builder(
                              itemCount: _filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = _filteredStudents[index];
                                return Container(
                                  width: 90.w,
                                  padding: EdgeInsets.all(2.w),
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
                                        radius:
                                            22, // Adjust the radius as needed
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Text(
                                          student['username'] ?? 'Unknown',
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontFamily: 'Roboto',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          _StudentProgressButton(
                                            label: 'Progress',
                                            studentName: student['username'] ??
                                                'Unknown',
                                            studentId: student['userID']!,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Progress(
                                                    studentName:
                                                        student['username'] ??
                                                            'Unknown',
                                                    studentId:
                                                        student['userID']!,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          _StudentPointButton(
                                            label: 'Points',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Point(
                                                    studentName:
                                                        student['username']!,
                                                    studentId:
                                                        student['userID']!,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
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
      ),
    );
  }
}

class _StudentPointButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _StudentPointButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(172, 130, 103, 1), // Button color
        padding: const EdgeInsets.symmetric(
            horizontal: 6.0, vertical: 5.0), // Adjust padding as needed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Adjust button radius
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14.0, // Adjust button text font size
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StudentProgressButton extends StatelessWidget {
  final String label;
  final String studentName;
  final String studentId;
  final VoidCallback onPressed;

  const _StudentProgressButton({
    super.key,
    required this.label,
    required this.studentName,
    required this.studentId,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(172, 130, 103, 1), // Button color
        padding: const EdgeInsets.symmetric(
            horizontal: 6.0, vertical: 5.0), // Adjust padding as needed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Adjust button radius
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14.0, // Adjust button text font size
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
