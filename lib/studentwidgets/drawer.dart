import 'dart:async'; // for using timer
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart'; // for page transition animation
import 'package:sizer/sizer.dart'; // for responsive sizing
import 'package:intl/intl.dart'; // for formating data
import 'package:studybunnies/authentication/logoutscreen.dart';
import 'package:studybunnies/studentscreens/classes.dart';
import 'package:studybunnies/studentscreens/faq.dart';
import 'package:studybunnies/studentscreens/feedback.dart';
import 'package:studybunnies/studentscreens/giftcatalogue.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/notes.dart';
import 'package:studybunnies/studentscreens/points.dart';
import 'package:studybunnies/studentscreens/timetable.dart';

// This function creates a drawer (a side menu) for students
Widget studentDrawer(BuildContext context, int drawercurrentindex) {
  // Get the current date and format it to a string like "dd-MM-yyyy (E)"
  String formattedDate = DateFormat('dd-MM-yyyy (E)').format(DateTime.now());
  // Define text styles and colors for selected and normal (unselected) items
  TextStyle selectedStyle = TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
      color: const Color.fromRGBO(195, 154, 29, 1));
  TextStyle normalStyle = TextStyle(fontSize: 12.sp, color: Colors.white);
  Color selectedIconColor = const Color.fromRGBO(195, 154, 29, 1);
  Color unselectedIconColor = Colors.white;
  Color selectedContainerColor = Colors.yellow.withOpacity(0.2);
  Color unselectedContainerColor = Colors.transparent;
  // Return a Drawer widget that contains a ListView of items
  return Drawer(
    backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
    child: ListView(
      padding: EdgeInsets.zero, // No padding around the ListView
      children: <Widget>[
        // The top part of the drawer with the date and user info
        Container(
          padding: EdgeInsets.all(4.w), // Padding around the container
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align items to the start (left)
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    left: 2.w), // Padding to the left of the date
                child: Text(
                  formattedDate, // Display the formatted date
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(
                height: 7.h, // Space between date and user icon
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 7.w), // Padding to the left of the user icon
                child: Container(
                  width: 20.w, // Width of the user icon container
                  height: 20.w, // Height of the user icon container
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Make the container a circle
                    color: Colors.grey[300],
                  ),
                  child: Icon(
                    Icons.person, // Display a person icon
                    size: 10.w,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 2.h), // Space between user icon and name
              Padding(
                padding: EdgeInsets.only(
                    left: 7.w), // Padding to the left of the user name
                child: Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 7.w), // Padding to the left of the user ID
                child: Text(
                  'ID: 123456789',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: 'Roboto',
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        // The rest of the drawer with navigation items
        Column(
          children: [
            // Home item
            Container(
              color: drawercurrentindex == 0
                  ? selectedContainerColor
                  : unselectedContainerColor,
              child: ListTile(
                title: Padding(
                  padding:
                      EdgeInsets.only(left: 5.w), // Add padding to the text
                  child: Row(
                    children: [
                      Icon(
                        Icons.home,
                        color: drawercurrentindex == 0
                            ? selectedIconColor
                            : unselectedIconColor,
                      ),
                      const SizedBox(width: 10), // Space between icon and text
                      Text(
                        'Home',
                        style: drawercurrentindex ==
                                0 // Mark as selected if current index is 0
                            ? selectedStyle
                            : normalStyle,
                      ),
                    ],
                  ),
                ),
                selected: drawercurrentindex == 0,
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const StudentDashboard()));
                  });
                },
              ),
            ),
            // Timetable
            Container(
              color: drawercurrentindex == 1
                  ? selectedContainerColor
                  : unselectedContainerColor,
              child: ListTile(
                title: Padding(
                  padding:
                      EdgeInsets.only(left: 5.w), // Add padding to the text
                  child: Row(
                    children: [
                      Icon(
                        Icons.table_chart,
                        color: drawercurrentindex == 1
                            ? selectedIconColor
                            : unselectedIconColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Timetable',
                        style: drawercurrentindex == 1
                            ? selectedStyle
                            : normalStyle,
                      ),
                    ],
                  ),
                ),
                selected: drawercurrentindex == 1,
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const Timetablelist()));
                  });
                },
              ),
            ),
            // Notes
            Container(
              color: drawercurrentindex == 2
                  ? selectedContainerColor
                  : unselectedContainerColor,
              child: ListTile(
                title: Padding(
                  padding:
                      EdgeInsets.only(left: 5.w), // Add padding to the text
                  child: Row(
                    children: [
                      Icon(
                        Icons.notes,
                        color: drawercurrentindex == 2
                            ? selectedIconColor
                            : unselectedIconColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Notes',
                        style: drawercurrentindex == 2
                            ? selectedStyle
                            : normalStyle,
                      ),
                    ],
                  ),
                ),
                selected: drawercurrentindex == 2,
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const Noteslist()));
                  });
                },
              ),
            ),
            // Classes
            Container(
              color: drawercurrentindex == 3
                  ? selectedContainerColor
                  : unselectedContainerColor,
              child: ListTile(
                title: Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.class_,
                        color: drawercurrentindex == 3
                            ? selectedIconColor
                            : unselectedIconColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Classes',
                        style: drawercurrentindex == 3
                            ? selectedStyle
                            : normalStyle,
                      ),
                    ],
                  ),
                ),
                selected: drawercurrentindex == 3,
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const Classlist()));
                  });
                },
              ),
            ),
            // Points
            Container(
              color: drawercurrentindex == 4
                  ? selectedContainerColor
                  : unselectedContainerColor,
              child: ListTile(
                title: Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.point_of_sale,
                        color: drawercurrentindex == 4
                            ? selectedIconColor
                            : unselectedIconColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Points',
                        style: drawercurrentindex == 4
                            ? selectedStyle
                            : normalStyle,
                      ),
                    ],
                  ),
                ),
                selected: drawercurrentindex == 4,
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const Points()));
                  });
                },
              ),
            ),
            // Gift Catalogue
            Container(
              color: drawercurrentindex == 5
                  ? selectedContainerColor
                  : unselectedContainerColor,
              child: ListTile(
                title: Padding(
                  padding:
                      EdgeInsets.only(left: 5.w), // Add padding to the text
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        color: drawercurrentindex == 5
                            ? selectedIconColor
                            : unselectedIconColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Gift Catalogue',
                        style: drawercurrentindex == 5
                            ? selectedStyle
                            : normalStyle,
                      ),
                    ],
                  ),
                ),
                selected: drawercurrentindex == 5,
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const Giftlist()));
                  });
                },
              ),
            ),
            // Feedback
            Container(
              color: drawercurrentindex == 6
                  ? selectedContainerColor
                  : unselectedContainerColor,
              child: ListTile(
                title: Padding(
                  padding:
                      EdgeInsets.only(left: 5.w), // Add padding to the text
                  child: Row(
                    children: [
                      Icon(
                        Icons.autorenew_rounded,
                        color: drawercurrentindex == 6
                            ? selectedIconColor
                            : unselectedIconColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Feedback',
                        style: drawercurrentindex == 6
                            ? selectedStyle
                            : normalStyle,
                      ),
                    ],
                  ),
                ),
                selected: drawercurrentindex == 6,
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const Feedbacklist()));
                  });
                },
              ),
            ),
            // FAQ item
            Container(
              color: drawercurrentindex == 7
                  ? selectedContainerColor
                  : unselectedContainerColor,
              child: ListTile(
                title: Padding(
                  padding:
                      EdgeInsets.only(left: 5.w), // Add padding to the text
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: drawercurrentindex == 7
                            ? selectedIconColor
                            : unselectedIconColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'FAQ',
                        style: drawercurrentindex == 7
                            ? selectedStyle
                            : normalStyle,
                      ),
                    ],
                  ),
                ),
                selected: drawercurrentindex == 7,
                onTap: () {
                  // Navigate to FAQ page
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const Faqpage()));
                  });
                },
              ),
            ),
            // Logout
            Container(
              color: drawercurrentindex == 8
                  ? selectedContainerColor
                  : unselectedContainerColor,
              child: ListTile(
                title: Padding(
                  padding:
                      EdgeInsets.only(left: 5.w), // Add padding to the text
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_outlined,
                        color: drawercurrentindex == 8
                            ? selectedIconColor
                            : unselectedIconColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: drawercurrentindex == 7
                            ? selectedStyle
                            : normalStyle,
                      ),
                    ],
                  ),
                ),
                selected: drawercurrentindex == 8,
                onTap: () {
                  // Navigate to Logout page
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 205),
                            child: const Logoutscreen()));
                  });
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
