import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'package:studybunnies/teacherwidgets/snackbar.dart';

class Point extends StatefulWidget {
  final String studentName;
  final String studentId;

  Point({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<Point> createState() => _PointState();
}

class _PointState extends State<Point> {
  final TextEditingController _pointEditingController = TextEditingController();
  ImageProvider profileImg = const AssetImage('images/profile.webp');
  List<String> studentClasses = [];
  int updatedPoints = 0;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
    _fetchPoints();
  }

  Future<void> _fetchPoints() async {
    try {
      DocumentSnapshot pointsSnapshot = await FirebaseFirestore.instance
          .collection('points')
          .doc(widget.studentId)
          .get();

      if (pointsSnapshot.exists) {
        setState(() {
          int points = pointsSnapshot['points'];
          _pointEditingController.text = points.toString();
        });
      }
    } catch (e) {
      showCustomSnackbar(context, 'Error fetching points: $e');
    }
  }

  Future<void> fetchStudentData() async {
    try {
      // Fetch all classes
      final classesSnapshot =
          await FirebaseFirestore.instance.collection('classes').get();
      List<String> fetchedClasses = [];

      // Fetch classes where the student is enrolled
      for (var classDoc in classesSnapshot.docs) {
        List<dynamic> studentList = classDoc['student'] ?? [];
        if (studentList.contains(widget.studentId)) {
          fetchedClasses.add(classDoc['classname']);
        }
      }

      // Fetch student details
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .get();

      setState(() {
        // Set the profile image
        String? imageUrl = userDoc['profile_img'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          profileImg = NetworkImage(imageUrl);
        }

        studentClasses = fetchedClasses;
      });
    } catch (e) {
      showCustomSnackbar(context, 'Error fetching student data: $e');
    }
  }

  Future<void> _saveUpdatedPoints() async {
    try {
      await FirebaseFirestore.instance
          .collection('points')
          .doc(widget.studentId)
          .update({
        'points': int.parse(_pointEditingController.text),
      });
      showCustomSnackbar(
          context, 'Points updated to ${_pointEditingController.text}');
    } catch (e) {
      showCustomSnackbar(context, 'Error updating points: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar(
          "Student Point", "This page contains the student's points.", context,
          showBackIcon: true, showProfileIcon: false),
      bottomNavigationBar: navbar(3),
      backgroundColor: const Color.fromRGBO(239, 238, 233, 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 2.h),
              SizedBox(height: 2.h),
              Center(
                child: CircleAvatar(
                  backgroundImage: profileImg,
                  radius: 10.w,
                ),
              ),
              SizedBox(height: 2.h),
              Center(
                child: Text(
                  widget.studentName,
                  style: TextStyle(
                    color: const Color.fromRGBO(61, 47, 34, 1),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(213, 208, 176, 1),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //SizedBox(height: 1.h),
                    Text(
                      "Classes:",
                      style: TextStyle(
                        color: const Color.fromRGBO(61, 47, 34, 1),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    for (var studentClass in studentClasses)
                      Text(
                        "• $studentClass",
                        style: TextStyle(
                          color: const Color.fromRGBO(61, 47, 34, 1),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    SizedBox(height: 3.h),
                    Text(
                      "Original Points: ${_pointEditingController.text}",
                      style: TextStyle(
                        color: const Color.fromRGBO(61, 47, 34, 1),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          "Update Points: ",
                          style: TextStyle(
                            color: const Color.fromRGBO(61, 47, 34, 1),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 25.w,
                          child: TextField(
                            controller: _pointEditingController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                updatedPoints = int.parse(value);
                              } else {
                                updatedPoints = 0;
                              }
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(
                              color: const Color.fromRGBO(61, 47, 34, 1),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _saveUpdatedPoints();
                          setState(() {
                            // update the displayed points after saving
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(101, 143, 172, 1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
