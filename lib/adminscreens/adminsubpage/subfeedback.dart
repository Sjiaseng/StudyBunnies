import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Subfeedback extends StatefulWidget {
  const Subfeedback({super.key});

  @override
  State<Subfeedback> createState() => _SubfeedbackState();
}

class _SubfeedbackState extends State<Subfeedback> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 7.w, top: 3.h),
                    width: 10.w,
                    height: 10.h,
                    child: Icon(Icons.arrow_back, size: 20.sp),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: 3.h, right: 8.w),
                      child: Text(
                        'View Feedback',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  Container(
                    height: 70.h, // Set the fixed height for the container
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(217, 217, 217, 1),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(3.w),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                              children: [
                                const Align(
                                  alignment: Alignment.topRight,
                                  child: Icon(Icons.star),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 3.w, top: 0.h),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: const AssetImage('images/profile.webp'),
                                        radius: 7.w,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 3.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 50.w,
                                              child: Text(
                                                'Username',
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10.sp,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 0.5.h), // Push the role text down slightly
                                              child: Text(
                                                'Role: Student',
                                                textAlign: TextAlign.left,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10.sp,
                                                  overflow: TextOverflow.fade,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Feedback Title Goes Here...',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Feedback Content Goes Here',
                                  style: TextStyle(
                                    fontSize: 10.sp
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 3.w,
                          bottom: 1.5.h,
                          child: Text(
                            'Date: 19/11/2024',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ElevatedButton(
                    onPressed: () {
                      print('Logout pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.red, width: 2), // Add border here
                      ),
                      minimumSize: const Size(double.infinity, 50), // Ensures the button takes full width
                    ),
                    child: const Text(
                      'Delete Feedback',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
