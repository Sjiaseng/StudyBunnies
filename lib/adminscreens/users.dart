import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/adminscreens/dashboard.dart';
import 'package:studybunnies/adminscreens/timetable.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:sizer/sizer.dart';


class Userlist extends StatefulWidget {
  const Userlist({super.key});

  @override
  State<Userlist> createState() => _UserlistState();
}

class _UserlistState extends State<Userlist> {
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
      appBar: mainappbar("Users", "This page contains all information for the users registered in StudyBunnies", context),
      bottomNavigationBar: navbar(1),
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

            Container( 
              padding: EdgeInsets.all(1.w),
              width: 90.w,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey),
            ),
              child:Row(
                  children: [
                    SizedBox(width: 2.0.w),
                    const Icon(Icons.search),
                    SizedBox(width: 2.0.w),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        // Add your controller and onChanged callback here
                        controller: mycontroller,
                        onChanged: (value) {
                          // Implement your search logic here
                        },
                      ),
                    ),
                  ],
                ),
            ),

            SizedBox(height: 2.h),

            Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(3.w),
                      onTap: () {
                        print('Tapped on User ${index + 1}');
                      },
                      child: Container(
                        width: 90.w,
                        padding: EdgeInsets.all(2.w),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: const AssetImage('images/profile.webp'),
                              radius: 7.w,
                            ),

                            SizedBox(width: 5.w),

                            SizedBox(
                              width: 50.w,
                              child: Text(
                                'User ${index + 1}',
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontFamily: 'Roboto',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                              const Spacer(),

                              const Icon(Icons.keyboard_arrow_right_outlined),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          


          ],
        ),
      ),
    ),
  );
}
}