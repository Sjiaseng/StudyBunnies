import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: mainappbar("Users", "This page contains all information for the users registered in StudyBunnies", context),
      bottomNavigationBar: navbar(1),
      drawer: adminDrawer(context, 3),
      body: Center(child:Text("Page2"),),
    );
  }
}