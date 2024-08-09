import 'dart:async';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:studybunnies/teacherscreens/dashboard.dart';
import 'package:studybunnies/teacherscreens/myprofile.dart';
import 'package:studybunnies/teacherscreens/timetablelist.dart';
import 'package:studybunnies/teacherscreens/classes.dart';
import 'package:studybunnies/teacherscreens/studentlist.dart';
import 'package:studybunnies/teacherscreens/feedback.dart';
import 'package:studybunnies/teacherscreens/faq.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybunnies/authentication/logoutscreen.dart';

class teacherDrawer extends StatefulWidget {
  final int drawercurrentindex;

  teacherDrawer(BuildContext context, int i,
      {required this.drawercurrentindex});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<teacherDrawer> {
  String? loggedInUserId;
  String username = '';
  ImageProvider profileImg = const AssetImage('images/profile.webp');
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      loggedInUserId = user?.uid;
    });
    if (loggedInUserId != null) {
      await fetchUserDetails();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(loggedInUserId)
          .get();
      setState(() {
        username = userDoc['username'] ?? 'Unknown User';
        String? imageUrl = userDoc['profile_img'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          profileImg = NetworkImage(imageUrl);
        }
      });
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy (E)').format(DateTime.now());
    TextStyle selectedStyle = TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: const Color.fromRGBO(195, 154, 29, 1));
    TextStyle normalStyle = TextStyle(
        fontSize: 12.sp, color: const Color.fromRGBO(239, 238, 233, 1));
    Color selectedIconColor = const Color.fromRGBO(195, 154, 29, 1);
    Color unselectedIconColor = const Color.fromRGBO(239, 238, 233, 1);
    Color selectedContainerColor = Colors.yellow.withOpacity(0.2);
    Color unselectedContainerColor = Colors.transparent;

    return Drawer(
      backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color.fromRGBO(239, 238, 233, 1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          isLoading
              ? CircularProgressIndicator()
              : Container(
                  padding: EdgeInsets.all(9.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 0.w, right: 35.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                              ),
                              child: CircleAvatar(
                                backgroundImage: profileImg,
                                radius: 14.w,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  color: widget.drawercurrentindex == 0
                      ? selectedContainerColor
                      : unselectedContainerColor,
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: widget.drawercurrentindex == 0
                                ? selectedIconColor
                                : unselectedIconColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Home',
                            style: widget.drawercurrentindex == 0
                                ? selectedStyle
                                : normalStyle,
                          ),
                        ],
                      ),
                    ),
                    selected: widget.drawercurrentindex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      Timer(const Duration(milliseconds: 205), () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const TeacherDashboard(),
                          ),
                        );
                      });
                    },
                  ),
                ),
                Container(
                  color: widget.drawercurrentindex == 6
                      ? selectedContainerColor
                      : unselectedContainerColor,
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            color: widget.drawercurrentindex == 6
                                ? selectedIconColor
                                : unselectedIconColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'My Profile',
                            style: widget.drawercurrentindex == 6
                                ? selectedStyle
                                : normalStyle,
                          ),
                        ],
                      ),
                    ),
                    selected: widget.drawercurrentindex == 6,
                    onTap: () {
                      Navigator.pop(context);
                      Timer(const Duration(milliseconds: 205), () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const MyProfile(),
                          ),
                        );
                      });
                    },
                  ),
                ),
                Container(
                  color: widget.drawercurrentindex == 1
                      ? selectedContainerColor
                      : unselectedContainerColor,
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.table_chart,
                            color: widget.drawercurrentindex == 1
                                ? selectedIconColor
                                : unselectedIconColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Timetable',
                            style: widget.drawercurrentindex == 1
                                ? selectedStyle
                                : normalStyle,
                          ),
                        ],
                      ),
                    ),
                    selected: widget.drawercurrentindex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      Timer(const Duration(milliseconds: 205), () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const TimetableList(),
                          ),
                        );
                      });
                    },
                  ),
                ),
                Container(
                  color: widget.drawercurrentindex == 2
                      ? selectedContainerColor
                      : unselectedContainerColor,
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school,
                            color: widget.drawercurrentindex == 2
                                ? selectedIconColor
                                : unselectedIconColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Classes',
                            style: widget.drawercurrentindex == 2
                                ? selectedStyle
                                : normalStyle,
                          ),
                        ],
                      ),
                    ),
                    selected: widget.drawercurrentindex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      Timer(const Duration(milliseconds: 205), () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const Classes(),
                          ),
                        );
                      });
                    },
                  ),
                ),
                Container(
                  color: widget.drawercurrentindex == 3
                      ? selectedContainerColor
                      : unselectedContainerColor,
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: widget.drawercurrentindex == 3
                                ? selectedIconColor
                                : unselectedIconColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Student List',
                            style: widget.drawercurrentindex == 3
                                ? selectedStyle
                                : normalStyle,
                          ),
                        ],
                      ),
                    ),
                    selected: widget.drawercurrentindex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      Timer(const Duration(milliseconds: 205), () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const StudentList(),
                          ),
                        );
                      });
                    },
                  ),
                ),
                Container(
                  color: widget.drawercurrentindex == 4
                      ? selectedContainerColor
                      : unselectedContainerColor,
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.feedback,
                            color: widget.drawercurrentindex == 4
                                ? selectedIconColor
                                : unselectedIconColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Feedback',
                            style: widget.drawercurrentindex == 4
                                ? selectedStyle
                                : normalStyle,
                          ),
                        ],
                      ),
                    ),
                    selected: widget.drawercurrentindex == 4,
                    onTap: () {
                      Navigator.pop(context);
                      Timer(const Duration(milliseconds: 205), () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const TeacherFeedback(),
                          ),
                        );
                      });
                    },
                  ),
                ),
                Container(
                  color: widget.drawercurrentindex == 5
                      ? selectedContainerColor
                      : unselectedContainerColor,
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: widget.drawercurrentindex == 5
                                ? selectedIconColor
                                : unselectedIconColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'FAQ',
                            style: widget.drawercurrentindex == 5
                                ? selectedStyle
                                : normalStyle,
                          ),
                        ],
                      ),
                    ),
                    selected: widget.drawercurrentindex == 5,
                    onTap: () {
                      Navigator.pop(context);
                      Timer(const Duration(milliseconds: 205), () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const Faq(),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(
              color: Color.fromRGBO(239, 238, 233, 1), thickness: 1.0),
          Container(
            color: unselectedContainerColor,
            child: ListTile(
              title: Padding(
                padding: EdgeInsets.only(left: 5.w),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout,
                      color: Color.fromRGBO(239, 238, 233, 1),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(239, 238, 233, 1),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                // Handle logout logic
                Navigator.pop(context);
                Timer(const Duration(milliseconds: 205), () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      duration: const Duration(milliseconds: 205),
                      child: const Logoutscreen(),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
