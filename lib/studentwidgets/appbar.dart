import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/studentscreens/myprofile.dart';

// This function creates the main app bar used throughout the app.
AppBar mainappbar(String title, String helpmsg, BuildContext context) {
  return AppBar(
    // Set the background color of the app bar.
    backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Display the title text.
        Text(
          title,
          style: const TextStyle(color: Color.fromRGBO(239, 238, 233, 1)),
        ),
        // Add spacing between title and help icon.
        SizedBox(width: 2.w),
        // Add a help icon with a tooltip.
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
    // Configure the actions (icons on the right) for the app bar.
    actions: [
      // Add an icon button to navigate to the user profile page.
      IconButton(
        icon: Icon(
          Icons.person_pin,
          size: 3.0.h,
          color: const Color.fromRGBO(239, 238, 233, 1),
        ),
        // When pressed, navigate to the user profile page with a transition effect.
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
    ],
     // Configure the leading widget (icon on the left) for navigation drawer.
    leading: Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color.fromRGBO(239, 238, 233, 1),
          ),
          onPressed: () {
            // When the menu icon is pressed, open the navigation drawer.
            Scaffold.of(context).openDrawer();
          },
        );
      },
    ),
  );
}

// This function creates a sub app bar used for secondary screens.
AppBar subappbar(String title, BuildContext context) {
  return AppBar(
    // Set the background color of the sub app bar.
    backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
    // Configure the title section of the sub app bar.
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color.fromRGBO(239, 238, 233, 1)),
        ),
        // Add spacing between title and leading icon.
        SizedBox(width: 2.w),
      ],
    ),
    // Configure the actions (icons on the right) for the sub app bar.
    actions: [
      // Add an icon button to navigate to the user profile page.
      IconButton(
        icon: Icon(
          Icons.person_pin,
          size: 3.0.h,
          color: const Color.fromRGBO(239, 238, 233, 1),
        ),
        onPressed: () {
          // When pressed, navigate to the user profile page with a transition effect.
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
    ],
    // Configure the leading widget (back arrow) to pop the current screen.
    leading: GestureDetector(
      // When tapped, pop (close) the current screen and return to the previous one.
      onTap: () {
        Navigator.pop(context);
      },
      child: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
    ),
  );
}
