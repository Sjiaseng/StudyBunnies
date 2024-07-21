import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentscreens/giftcatalogue.dart';
import 'package:studybunnies/studentscreens/notes.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

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
              child: const Noteslist(),
              )
            ); 
          }
        },
        child: Scaffold(
      appBar: mainappbar("Timetable", "This section includes the timetable for various classes.", context),
      bottomNavigationBar: navbar(0),
      drawer: studentDrawer(context, 1),
      body: Center(child:Text("Student Timetable"),),
      ),
    );
  }
}