import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For controlling system UI overlay styles
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentscreens/classes.dart';
import 'package:studybunnies/studentscreens/timetable.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

// Defining the StudentDashboard class which is a StatelessWidget
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Setting the system UI overlay style (status bar color and brightness)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Set status bar color to black
      statusBarBrightness: Brightness.dark, // Set status bar text/icons to dark mode
    ));
    // Returning the main UI for the student dashboard
    return GestureDetector(
      // Detecting swipe gestures on the screen
      onPanUpdate: (details) {
        // Swiping in right direction (go to Timetable).
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
        // Swiping in left direction (go to Classes).
        if (details.delta.dx < -25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const Classlist(),
            ),
          );
        }
      },
      // Main scaffold structure of the student dashboard
      // Provides the overall structure of the screen, including the app bar, drawer, body content, and bottom navigation bar.
      child: Scaffold(
        // App bar at the top of the screen
        appBar: mainappbar("Home", "This is students dashboard.", context),
        // Drawer (side menu) for the student dashboard
        drawer: StudentDrawer(drawercurrentindex: 0, userID: 'userID'),
        // Main body content of the screen
        body: const Center(
          child: Text('Student Main Page'),
        ),
        bottomNavigationBar: navbar(2),
      ),
    );
  }
}
