import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: mainappbar("Timetable", "This section includes the timetable for various classes.", context),
      bottomNavigationBar: navbar(0),
      drawer: adminDrawer(context, 1),
      body: Center(child:Text("Page1"),),
    );
  }
}