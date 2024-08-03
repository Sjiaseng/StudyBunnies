import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/adminscreens/adminsubpage/adduser.dart';
import 'package:studybunnies/adminscreens/dashboard.dart';
import 'package:studybunnies/adminscreens/timetable.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:sizer/sizer.dart';


class Classinner extends StatefulWidget {
  final String classID;
  const Classinner({required this.classID, super.key});

  @override
  State<Classinner> createState() => _ClassinnerState();
}

class _ClassinnerState extends State<Classinner> {
  List<bool> selectedFilters = [true, false, false, false];

  TextEditingController mycontroller = TextEditingController();

  void focusButton(int index) {
    setState(() {
      for (int buttonIndex = 0; buttonIndex < selectedFilters.length; buttonIndex++) {
        if (buttonIndex == index) {
          selectedFilters[buttonIndex] = true;
        } else {
          selectedFilters[buttonIndex] = false;
        }
      }
    });
  }

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
          ),
        );
      }
      // Swiping in left direction.
      if (details.delta.dx < -25) {
        Navigator.push(
          context, PageTransition(
            type: PageTransitionType.rightToLeft,
            duration: const Duration(milliseconds: 305),
            child: const AdminDashboard(),
          ),
        );
      }
    },
    child: Scaffold(
      appBar: subappbar("Class Name Here", context),
      bottomNavigationBar: navbar(3),
      drawer: adminDrawer(context, 3),
      body: Padding(
        padding: EdgeInsets.only(left: 5.w, top: 1.5.h, right: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ToggleButtons(
              textStyle: const TextStyle(fontFamily: 'Roboto'),
              constraints: BoxConstraints(minWidth: 2.w, minHeight: 3.h),
              isSelected: selectedFilters,
              borderRadius: BorderRadius.circular(2.w),
              onPressed: focusButton,
              selectedColor: Colors.black,
              fillColor: Colors.grey,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    'All',
                    style: TextStyle(
                      fontWeight: selectedFilters[0] ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    'Students',
                    style: TextStyle(
                      fontWeight: selectedFilters[1] ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    'Teachers',
                    style: TextStyle(
                      fontWeight: selectedFilters[2] ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    'Admins',
                    style: TextStyle(
                      fontWeight: selectedFilters[3] ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 1.h), 

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        Navigator.push(
          context, PageTransition(
          type: PageTransitionType.rightToLeft,
            duration: const Duration(milliseconds: 305),  
            child: const Adduser(),
          ),
        ); 
          // Add your action here
        },
        backgroundColor: const Color.fromARGB(255, 100, 30, 30), // RGB(100, 30, 30)
        shape: const CircleBorder(), // Ensures the shape is round
        child: const Icon(Icons.add, color: Colors.white),
      ),
    ),
  );
}
}