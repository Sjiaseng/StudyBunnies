import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminscreens/classes.dart';
import 'package:studybunnies/adminscreens/users.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:studybunnies/adminwidgets/summarycontainer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

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
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: const Userlist(),
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
              child: const Classlist(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar("Home", "This is admins' dashboard.", context),
        bottomNavigationBar: navbar(2),
        drawer: adminDrawer(context, 0),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 7.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: const AssetImage('images/profile.webp'),
                      radius: 10.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Text(
                              'Myname',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: 'Roboto',
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50.w,
                            child: Text(
                              'MyID',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontFamily: 'Roboto',
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              Padding(
                padding: EdgeInsets.only(left: 5.w),
                child: Text(
                  "Summary",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 15.sp,
                  ),
                ),
              ),

              SizedBox(height: 5.w),

              Padding(
                padding: EdgeInsets.only(left: 3.w, right: 2.w),
                child: Row(
                  children: [
                    SummaryContainer('Total Students', Colors.amber, '100'),
                    SizedBox(width: 5.w),
                    SummaryContainer('Total Teachers', Colors.blue, '50'),
                  ],
                ),
              ),

              SizedBox(height: 4.w),

              Padding(
                padding: EdgeInsets.only(left: 3.w, right: 2.w),
                child: Row(
                  children: [
                    SummaryContainer('Total Admins', Colors.green, '10'),
                    SizedBox(width: 5.w),
                    SummaryContainer('Total Classes', Colors.orange, '20'),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              Padding(
                padding: EdgeInsets.only(left: 5.w),
                child: Text(
                  "Latest Feedback",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 15.sp,
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              SizedBox(
                height: 26.2.h,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.only(left: 4.w, right: 4.w),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 1.5.h),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(3.w),
                          highlightColor: Colors.grey,
                          onTap: () {
                            print('Tapped on Feedback');
                          },
                          child: Container(
                            height: 15.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
                              borderRadius: BorderRadius.circular(3.w),
                              color: const Color.fromRGBO(217, 217, 217, 1),
                            ),
                            padding: EdgeInsets.only(left: 3.w, top: 1.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Feedback Title $index",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: const Color.fromRGBO(116, 116, 116, 1),
                                  ),
                                ),
                                SizedBox(height: 2.w),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 12.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      "Username",
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        overflow: TextOverflow.ellipsis,
                                        color: const Color.fromRGBO(116, 116, 116, 1),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 1.h),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: 12.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      "Date",
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        overflow: TextOverflow.ellipsis,
                                        color: const Color.fromRGBO(116, 116, 116, 1),
                                      ),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: EdgeInsets.only(right: 3.w, top: 1.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'View More',
                                        style: TextStyle(
                                          color: Color.fromRGBO(116, 116, 116, 1),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 10.sp,
                                        color: const Color.fromRGBO(116, 116, 116, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
