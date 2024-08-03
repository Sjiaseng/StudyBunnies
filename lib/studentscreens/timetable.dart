import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart'; // For animated page transitions
import 'package:sizer/sizer.dart'; // For responsive UI
import 'package:studybunnies/studentscreens/giftcatalogue.dart';
import 'package:studybunnies/studentscreens/notes.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';
import 'package:studybunnies/studentwidgets/timetable.dart';

// Main widget for the timetable list screen
class Timetablelist extends StatefulWidget {
  const Timetablelist({super.key});

  @override
  State<Timetablelist> createState() => _TimetablelistState();
}

// State for Timetablelist widget
class _TimetablelistState extends State<Timetablelist> {
  List<String> items = ['Option 1', 'Option 2', 'Option 3'];
  String? selectedItem1 = 'Option 1';
  String? selectedItem2 = 'Option 1';

  void _showOptionsBottomSheet(Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min, // Minimum size based on content
          children: items.map((String item) {
            return ListTile(
              title: Text(item),
              onTap: () {
                onSelected(item); // Pass selected item to callback function
                Navigator.pop(context); // Close the bottom sheet
              },
            );
          }).toList(),
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
              child: const Noteslist(),
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
              child: const Giftlist(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar(
          "Timetable", // Title of the app bar
          "This section includes the timetable for various classes.", // Subtitle
          context,
        ),
        bottomNavigationBar: navbar(0), // Bottom navigation bar
        drawer: studentDrawer(context, 1), // Navigation drawer
        body: Padding(
          padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the buttons
                children: [
                  // First dropdown button
                  SizedBox(
                    width: 40.w, // Width set to 40% of the screen width
                    child: ElevatedButton(
                      onPressed: () => _showOptionsBottomSheet((String item) {
                        setState(() {
                          selectedItem1 = item; // Update selected item
                        });
                      }),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // Rounded corners
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedItem1 ??
                                'Select an Option', // Display selected item
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const Icon(
                              Icons.arrow_drop_down), // Dropdown arrow icon
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w), // Spacer between the two dropdowns
                  SizedBox(
                    width: 40.w,
                    child: ElevatedButton(
                      onPressed: () => _showOptionsBottomSheet((String item) {
                        setState(() {
                          selectedItem2 = item; // Update selected item
                        });
                      }),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedItem2 ?? 'Select an Option', // Display selected item
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                // Expanded to fill available space
                child: Padding(
                  padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 2.h),
                  child: SingleChildScrollView(
                    // Scrollable column for timetable content
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Example timetable entries
                        Align(
                          alignment: Alignment.centerLeft,
                          child: timetableHeader("Monday, 27/6/2024"),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: timetableContent(context, "Course Title",
                              "Mohammad Ali", "Venue", "2:30", "3:20"),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: timetableContent(context, "Course Title",
                              "Mohammad Ali", "Venue", "2:30", "3:20"),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: timetableContent(context, "Course Title",
                              "Mohammad Ali", "Venue", "2:30", "3:20"),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: timetableContent(context, "Course Title",
                              "Mohammad Ali", "Venue", "2:30", "3:20"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
