import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/adminscreens/classes.dart';
import 'package:studybunnies/adminscreens/timetable.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';

class Giftlist extends StatefulWidget {
  const Giftlist({super.key});

  @override
  State<Giftlist> createState() => _GiftlistState();
}

class _GiftlistState extends State<Giftlist> {
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
              child: const Classlist(),
              )
            ); 
          }
          // Swiping in left direction.
          if (details.delta.dx < -25) {
            Navigator.push(
              context, PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),  
              child: const Timetablelist(),
              )
            ); 
          }
        },
        child: Scaffold(
      appBar: mainappbar("Gift Catalogue", "This section includes the list of gifts that can be redeemed by the students.", context),
      drawer: adminDrawer(context, 4),
      bottomNavigationBar: navbar(4),
      body: Center(child:Text("Page4"),),
      ),
    );
  }
}