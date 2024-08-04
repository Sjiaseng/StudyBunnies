import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/timetable.dart';
import 'package:studybunnies/studentscreens/notes.dart';
import 'package:studybunnies/studentscreens/classes.dart';
import 'package:studybunnies/studentscreens/giftcatalogue.dart';

// This function navigates to different screens based on the index provided.
void navigateToPage(int index, BuildContext context) {
  switch (index) {
    case 0:
    // Navigate to the Timetable screen with a fade transition.
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 505),
          child: const Timetablelist(),
        ),
      );
      break;
    case 1:
    // Navigate to the Notes screen with a fade transition.
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 505),
          child: const Noteslist(classID: '', className: '',),
        ),
      );
      break;
    case 2:
    // Navigate to the Home (Dashboard) screen with a fade transition.
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 505),
          child: const StudentDashboard(),
        ),
      );
      break;
    case 3:
    // Navigate to the Classes screen with a fade transition.
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 505),
          child: const Classlist(),
        ),
      );
      break;
    case 4:
    // Navigate to the Gift Catalogue screen with a fade transition.
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 505),
          child: const Giftlist(),
        ),
      );
      break;
  }
}

// This function creates a bottom navigation bar for active screens.
Widget navbar(int currentIndex) {
  return Sizer(
    builder: (context, orientation, deviceType) {
      return BottomNavigationBar(
        items: [
          // Define navigation items with icons and labels.
          _buildNavItem(Icons.table_chart_outlined, 'Timetable', currentIndex == 0, () => navigateToPage(0, context)),
          _buildNavItem(Icons.note_outlined, 'Notes', currentIndex == 1, () => navigateToPage(1, context)),
          _buildNavItem(Icons.home_outlined, 'Home', currentIndex == 2, () => navigateToPage(2, context)),
          _buildNavItem(Icons.class_outlined, 'Classes', currentIndex == 3, () => navigateToPage(3, context)),
          _buildNavItem(Icons.card_giftcard, 'Gift', currentIndex == 4, () => navigateToPage(4, context)),
        ],
        // Set the current active index of the navigation bar.
        currentIndex: currentIndex,
        // Define styles for unselected items.
        unselectedItemColor: const Color.fromRGBO(239, 238, 233, 1),
        unselectedFontSize: 9.5.sp,
        unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto', color: Color.fromRGBO(239, 238, 233, 1)),
        // Define styles for selected items.
        selectedItemColor: const Color.fromRGBO(195, 154, 28, 1),
        selectedFontSize: 10.sp,
        selectedIconTheme: const IconThemeData(
          color: Color.fromRGBO(195, 154, 28, 1),
        ),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
         // Set background color of the navigation bar.
        backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
        // Define size of icons in the navigation bar.
        iconSize: 3.2.h,
        // Ensure navigation bar items are fixed in size.
        type: BottomNavigationBarType.fixed,
      );
    },
  );
}

// This function builds a navigation bar item with an icon, label, selection state, and onTap callback.
BottomNavigationBarItem _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
  return BottomNavigationBarItem(
    // Define the icon for the navigation item.
    icon: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 7.0, top: 5.0),
        width: isSelected ? 18.w : 18.w,
        height: isSelected ? 4.7.h : 4.7.h,
        // Apply styling and background color based on selection state.
        decoration: isSelected
            ? BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(100),
                color: const Color.fromRGBO(195, 154, 28, 0.3),
              )
            : null,
        child: Icon(icon),
      ),
    ),
    // Define the label for the navigation item.
    label: label,
  );
}

// This function builds an inactive navigation bar item with an icon, label, and onTap callback.
BottomNavigationBarItem _buildNavItem2(IconData icon, String label, VoidCallback onTap) {
  return BottomNavigationBarItem(
    // Define the icon for the navigation item.
    icon: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 7.0, top: 5.0),
        width: 18.w,
        height: 4.8.h,
        // Define styling and background color for the inactive state.
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(100),
          color: Colors.transparent,
        ),
        child: Icon(icon),
      ),
    ),
    // Define the label for the navigation item.
    label: label,
  );
}

// This function creates a bottom navigation bar for inactive screens.
Widget inactivenavbar() {
  return Sizer(
    builder: (context, orientation, deviceType) {
      return BottomNavigationBar(
        // Define navigation items with icons and labels.
        items: [
          _buildNavItem2(Icons.table_chart_outlined, 'Timetable', () => navigateToPage(0, context)),
          _buildNavItem2(Icons.note_outlined, 'Notes', () => navigateToPage(1, context)),
          _buildNavItem2(Icons.home_outlined, 'Home', () => navigateToPage(2, context)),
          _buildNavItem2(Icons.class_outlined, 'Classes', () => navigateToPage(3, context)),
          _buildNavItem2(Icons.card_giftcard, 'Gift', () => navigateToPage(4, context)),
        ],
        // Define styles for unselected items.
        unselectedItemColor: const Color.fromRGBO(239, 238, 233, 1),
        unselectedFontSize: 9.5.sp,
        unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto', color: Color.fromRGBO(239, 238, 233, 1)),
        // Define background color of the navigation bar.
        backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
       // Define styles for selected items (same as unselected for inactive state).
        selectedItemColor: const Color.fromRGBO(239, 238, 233, 1),
        selectedFontSize: 9.5.sp,
        selectedLabelStyle: const TextStyle(fontFamily: 'Roboto', color: Color.fromRGBO(239, 238, 233, 1)),
        // Define size of icons in the navigation bar.
        iconSize: 3.2.h,
        // Ensure navigation bar items are fixed in size.
        type: BottomNavigationBarType.fixed,
      );
    },
  );
}
