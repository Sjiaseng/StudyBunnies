import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/adminscreens/giftcatalogue.dart';
import 'package:studybunnies/adminscreens/users.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';

class Timetablelist extends StatefulWidget {
  const Timetablelist({super.key});

  @override
  State<Timetablelist> createState() => _TimetablelistState();
}

class _TimetablelistState extends State<Timetablelist> {
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
              child: const Giftlist(),
              )
            ); 
          }
          // Swiping in left direction.
          if (details.delta.dx < -25) {
            Navigator.push(
              context, PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),  
              child: const Userlist(),
              )
            ); 
          }
        },
        child: Scaffold(
      appBar: mainappbar("Timetable", "This section includes the timetable for various classes.", context),
      bottomNavigationBar: navbar(0),
      drawer: adminDrawer(context, 1),
      body: Center(child:Text("Page1"),),
      ),
    );
  }
}