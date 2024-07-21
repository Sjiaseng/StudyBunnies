import 'package:flutter/material.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class Points extends StatefulWidget {
  const Points({super.key});

  @override
  State<Points> createState() => _PointsState();
}

class _PointsState extends State<Points> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar("Points", "This section consists of student points.", context),
      drawer: studentDrawer(context, 4),
      bottomNavigationBar: inactivenavbar(),
      body: const Center(child:Text("Student Points"),),
    );
  }
}
