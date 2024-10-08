import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/authentication/logoutscreen.dart';
import 'package:studybunnies/teacherscreens/myprofile.dart';

AppBar mainappbar(String title, String helpmsg, BuildContext context,
    {bool showBackIcon = false, bool showProfileIcon = true}) {
  return AppBar(
    backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color.fromRGBO(239, 238, 233, 1)),
        ),
        SizedBox(width: 2.w),
        Tooltip(
          message: helpmsg,
          child: Padding(
            padding: EdgeInsets.only(top: 0.5.h),
            child: Icon(
              Icons.help_outline,
              size: 1.5.h,
              color: const Color.fromRGBO(239, 238, 233, 1),
            ),
          ),
        ),
      ],
    ),
    actions: showProfileIcon
        ? [
            IconButton(
              icon: Icon(
                Icons.person_pin,
                size: 3.0.h,
                color: const Color.fromRGBO(239, 238, 233, 1),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.topToBottom,
                    duration: const Duration(milliseconds: 305),
                    child: const MyProfile(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                size: 3.0.h,
                color: const Color.fromRGBO(239, 238, 233, 1),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.topToBottom,
                        duration: const Duration(milliseconds: 305),
                        child: const Logoutscreen()));
              },
            ),
          ]
        : null,
    leading: showBackIcon
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        : Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Color.fromRGBO(239, 238, 233, 1),
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
  );
}
