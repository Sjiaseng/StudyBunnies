import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart'; // For animated page transitions
import 'package:sizer/sizer.dart'; // For responsive UI
import 'package:studybunnies/authentication/session.dart';
import 'package:studybunnies/studentscreens/giftcatalogue.dart';
import 'package:studybunnies/studentscreens/notes.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore integration

// Main widget for the timetable list screen
class Timetablelist extends StatefulWidget {
  const Timetablelist({super.key});

  @override
  State<Timetablelist> createState() => _TimetablelistState();
}

// State for Timetablelist widget
class _TimetablelistState extends State<Timetablelist> {
  List<Widget> _timetableEntries = [];
  String? selectedItem1 = 'Option 1';
  String? selectedItem2 = 'Option 1';
  String? _userID;

  final Session _session = Session(); // Create a Session instance

  @override
  void initState() {
    super.initState();
    _fetchUserId(); // Fetch user ID when the widget is initialized
  }

  Future<void> _fetchUserId() async {
    String? userId = await _session.getUserId();
    setState(() {
      _userID = userId; // Update the state with the fetched user ID
      if (_userID != null) {
        _fetchTimetableEntries(
            _userID!); // Fetch timetable entries if userID is available
      }
    });
  }

  Future<void> _fetchTimetableEntries(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch classes where userID is in the students array
    QuerySnapshot classesSnapshot = await firestore
        .collection('classes')
        .where('student',
            arrayContains: userId) // Correct the field name to 'student'
        .get();

    List<Widget> timetableEntries = [];
    for (var classDoc in classesSnapshot.docs) {
      String classId = classDoc.id;

      // Fetch timetable details using classID
      QuerySnapshot timetableSnapshot = await firestore
          .collection('timetables')
          .where('classID', isEqualTo: classId)
          .get();

      for (var timetableDoc in timetableSnapshot.docs) {
        if (timetableDoc.exists) {
          Map<String, dynamic>? timetableData =
              timetableDoc.data() as Map<String, dynamic>?;

          String courseName = timetableData?['coursename'] ?? 'Unknown Course';
          String teacherId = timetableData?['teacherID'] ?? 'Unknown Teacher';
          String venue = timetableData?['venue'] ?? 'Unknown Venue';
          String duration = timetableData?['duration'] ?? 'Unknown Duration';
          String classID = timetableData?['classID'] ?? 'Unknown ClassID';
          DateTime classTime =
              (timetableData?['classtime'] as Timestamp).toDate();

          // Fetch teacher details using teacherID
          DocumentSnapshot teacherDoc =
              await firestore.collection('users').doc(teacherId).get();

          if (teacherDoc.exists) {
            Map<String, dynamic>? teacherData =
                teacherDoc.data() as Map<String, dynamic>?;

            String teacherName = teacherData?['username'] ?? 'Unknown';

            timetableEntries.add(
              Align(
                alignment: Alignment.centerLeft,
                child: timetableContent(
                  context,
                  courseName,
                  teacherName,
                  venue,
                  duration,
                  classID,
                  classTime,
                ),
              ),
            );
          }
        }
      }
    }

    setState(() {
      _timetableEntries = timetableEntries;
    });
  }

  void _showOptionsBottomSheet(Function(String) onSelected) {
    final List<String> items = [
      'Option 1',
      'Option 2',
      'Option 3'
    ]; // Define your options here

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
              child: Notelist(),
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
        drawer: StudentDrawer(
            drawercurrentindex: 1,
            userID: _userID ?? 'Guest'), // Pass userID to drawer
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
                            selectedItem2 ??
                                'Select an Option', // Display selected item
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
                      children: _timetableEntries.isNotEmpty
                          ? _timetableEntries
                          : [
                              Center(
                                child: Text(
                                  'No timetable entries available',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
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

// implementation of timetableContent function
Widget timetableContent(
  BuildContext context,
  String courseName,
  String teacherName,
  String venue,
  String duration,
  String classID,
  DateTime classTime,
) {
  final screenWidth = MediaQuery.of(context).size.width;

  return Container(
    width: screenWidth * 0.9, // Card width to be 90% of the screen width
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    padding: const EdgeInsets.all(16.0), // Padding inside the card
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: Colors.white, // Card color
      border: Border.all(
        color: Colors.grey, // Border color
        width: 1.0, // Border width
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              bottom: 8.0), // Padding below the class time text
          child: Text(
            'Class Time: ${classTime.toLocal()}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.only(
              bottom: 8.0), // Padding below the course name
          child: Text(courseName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.only(
              bottom: 8.0), // Padding below the teacher name
          child: Text.rich(
            TextSpan(
              text: 'Teacher: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold, // Bold text
                  ),
              children: <TextSpan>[
                TextSpan(
                  text: teacherName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(bottom: 8.0), // Padding below the venue
          child: Text.rich(
            TextSpan(
              text: 'Venue: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold, // Bold text
                  ),
              children: <TextSpan>[
                TextSpan(
                  text: venue,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(bottom: 8.0), // Padding below the duration
          child: Text.rich(
            TextSpan(
              text: 'Duration: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold, // Bold text
                  ),
              children: <TextSpan>[
                TextSpan(
                  text: duration,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(bottom: 8.0), // Padding below the class ID
          child: Text.rich(
            TextSpan(
              text: 'Class ID: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold, // Bold text
                  ),
              children: <TextSpan>[
                TextSpan(
                  text: classID,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
