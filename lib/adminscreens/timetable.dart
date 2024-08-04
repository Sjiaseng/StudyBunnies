import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminscreens/adminsubpage/addtimetable.dart';
import 'package:studybunnies/adminscreens/giftcatalogue.dart';
import 'package:studybunnies/adminscreens/users.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:studybunnies/adminwidgets/timetable.dart';
import 'package:studybunnies/authentication/session.dart';

class Timetablelist extends StatefulWidget {
  const Timetablelist({super.key});

  @override
  State<Timetablelist> createState() => _TimetablelistState();
}

class _TimetablelistState extends State<Timetablelist> {
  final Session session = Session();
  String? userId;
  String? userName;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    userId = await session.getUserId();
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId!).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['username'];
          profileImage = userDoc['profileImage'];
        });
      }
    }
  }
  List<String> items = ['Option 1', 'Option 2', 'Option 3'];
  String? selectedItem = 'Option 1';

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((String item) {
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    selectedItem = item;
                  });
                  Navigator.pop(context); // Close the bottom sheet
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Swiping in right direction.
        if (details.delta.dx > 25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: const Giftlist(),
            ),
          );
        }
        // Swiping in left direction.
        if (details.delta.dx < -25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const Userlist(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar(
          "Timetable",
          "This section includes the timetable for various classes.",
          context,
        ),
        bottomNavigationBar: navbar(0),
        drawer: const AdminDrawer(initialIndex: 1),
        body: Padding(
          padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40.w,
                    child: ElevatedButton(
                      onPressed: _showOptionsBottomSheet,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedItem ?? 'Select an Option', style: TextStyle(
                            color: Colors.black,
                          ),),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Container(
                    width: 40.w,
                    child: ElevatedButton(
                      onPressed: _showOptionsBottomSheet,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedItem ?? 'Select an Option', style: TextStyle(
                            color: Colors.black,
                          ),),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 2.h),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Timetableheader("Monday, 27/6/2024"),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Timetablecontent(context,"Course Title", "Mohammad Ali", "Venue", "2:30", "3:20"),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Timetablecontent(context, "Course Title", "Mohammad Ali", "Venue", "2:30", "3:20"),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Timetablecontent(context, "Course Title", "Mohammad Ali", "Venue", "2:30", "3:20"),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Timetablecontent(context, "Course Title", "Mohammad Ali", "Venue", "2:30", "3:20"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        Navigator.push(
          context, PageTransition(
          type: PageTransitionType.rightToLeft,
            duration: const Duration(milliseconds: 305),  
            child: const Addtimetable(),
          ),
        ); 
          // Add your action here
        },
        backgroundColor: const Color.fromARGB(255, 100, 30, 30), 
        shape: const CircleBorder(), 
        child: const Icon(Icons.add, color: Colors.white),
      ),
      ),
    );
  }
}
