import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentscreens/notesdetails.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/timetable.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

// StatefulWidget for the Noteslist page
class Noteslist extends StatefulWidget {
  const Noteslist({super.key});

  @override
  State<Noteslist> createState() => _NoteslistState();
}

class _NoteslistState extends State<Noteslist> {
  // Controller to manage the search input
  final TextEditingController _searchController = TextEditingController();

  // Map to store notes categorized by subject
  Map<String, List<String>> _notesMap = {
    'Biology': ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4'],
    'Chemistry': ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4'],
    'Maths': ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4'],
  };

  // Filtered map to show notes based on search query
  Map<String, List<String>> _filteredNotesMap = {};

  @override
  void initState() {
    super.initState();
    // Initialize _filteredNotesMap with all notes initially
    _filteredNotesMap = Map.from(_notesMap);
    // Add listener to search controller to filter notes on text change
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    // Remove listener and dispose of the search controller
    _searchController.removeListener(_filterNotes);
    _searchController.dispose();
    super.dispose();
  }

  // Method to filter notes based on the search query
  void _filterNotes() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      // If query is empty, show all notes
      setState(() {
        _filteredNotesMap = Map.from(_notesMap);
      });
    } else {
      // Filter notes based on the query
      final filteredMap = <String, List<String>>{};
      _notesMap.forEach((className, notes) {
        final filteredNotes =
            notes.where((note) => note.toLowerCase().contains(query)).toList();
        if (filteredNotes.isNotEmpty) {
          filteredMap[className] = filteredNotes;
        }
      });
      setState(() {
        _filteredNotesMap = filteredMap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Swipe detection to navigate between pages
        if (details.delta.dx > 25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: const Timetablelist(),
            ),
          );
        }
        if (details.delta.dx < -25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const StudentDashboard(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar("Notes",
            "This page contains all accessible notes for the user", context),
        bottomNavigationBar: navbar(1),
        drawer: StudentDrawer(drawercurrentindex: 2, userID: 'userID'),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search bar to filter notes
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Notes',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // List of notes filtered based on search query
              Expanded(
                child: ListView(
                  children: _filteredNotesMap.keys.map((className) {
                    return Column(
                      children: [
                        _buildClassSection(
                            className, _filteredNotesMap[className]!),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds a section for each class with a list of notes
  Widget _buildClassSection(String className, List<String> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header text for the class section
        Center(
          child: Text(
            className,
            style: const TextStyle(
              fontSize: 20.0, // Font size for the class name
              fontWeight: FontWeight.bold, // Bold font weight for emphasis
              color: Colors.black, // Color for the class name
            ),
          ),
        ),
        const SizedBox(
            height:8.0 
            ), 
        // List view to display all notes for the class
        ListView.builder(
          shrinkWrap:
              true, // Prevents the ListView from taking up more space than necessary
          physics:
              const NeverScrollableScrollPhysics(), // Disables scrolling within this ListView
          itemCount: notes.length, // Number of items in the notes list
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(241, 241, 241, 1), // Background color of the container
                border: Border.all(
                  color: const Color.fromRGBO(217, 217, 217, 1), // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(8.0), // Rounded corners for the container
              ),
              margin:
                  const EdgeInsets.only(bottom: 8.0), // Margin between cards
              child: ListTile(
                title: Text(notes[index]), // Display the note title
                trailing: ElevatedButton(
                  onPressed: () {
                    // Navigate to the details page when the button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotesDetailsPage(
                          className:
                              className, // Pass the class name to the details page
                          chapterName: notes[
                              index], // Pass the chapter name to the details page
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, // Text color of the button
                    backgroundColor: const Color.fromRGBO(217, 217, 217, 1), // Background color of the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                  ),
                  child: const Text('View'), // Text displayed on the button
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
