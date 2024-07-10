import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/adminscreens/dashboard.dart';
import 'package:studybunnies/adminscreens/timetable.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';

class Userlist extends StatefulWidget {
  const Userlist({super.key});

  @override
  State<Userlist> createState() => _UserlistState();
}

class _UserlistState extends State<Userlist> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          // Swiping in right direction.
          if (details.delta.dx > 25) {
            Navigator.push(
              context, PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),  
              child: const Timetablelist(),
              )
            ); 
          }
          // Swiping in left direction.
          if (details.delta.dx < -25) {
            Navigator.push(
              context, PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),  
              child: const AdminDashboard(),
              )
            ); 
          }
        },
      child:Scaffold(
      appBar: mainappbar("Users", "This page contains all information for the users registered in StudyBunnies", context),
      bottomNavigationBar: navbar(1),
      drawer: adminDrawer(context, 3),
      body:  const Center(child: Text("Page2")),
      ),
    );
  }
}