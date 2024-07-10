import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/adminscreens/classes.dart';
import 'package:studybunnies/adminscreens/users.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
//import 'package:studybunnies/main.dart';


class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarBrightness: Brightness.dark, 
    ));

    return GestureDetector(
        onPanUpdate: (details) {
          // Swiping in right direction.
          if (details.delta.dx > 25) {
            Navigator.push(
              context, PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),  
              child: const Userlist(),
              )
            ); 
          }
          // Swiping in left direction.
          if (details.delta.dx < -25) {
            Navigator.push(
              context, PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),  
              child: const Classlist(),
              )
            ); 
          }
        },
        child: Scaffold(
      appBar: mainappbar("Home", "This is admins' dashboard.", context),
      drawer: adminDrawer(context, 0),
      body: const Center(
        child: Text('Main Page'),
      ),
      bottomNavigationBar: navbar(2),
      ),
    );
  }
}

