import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentscreens/notesdetails.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/timetable.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class Noteslist extends StatefulWidget {
  const Noteslist({super.key});

  @override
  State<Noteslist> createState() => _NoteslistState();
}

class _NoteslistState extends State<Noteslist> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<String>> _notesMap = {
    'Biology': ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4'],
    'Chemistry': ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4'],
    'Maths': ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4'],
  };
  Map<String, List<String>> _filteredNotesMap = {};

  @override
  void initState() {
    super.initState();
    _filteredNotesMap = Map.from(_notesMap);
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterNotes);
    _searchController.dispose();
    super.dispose();
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredNotesMap = Map.from(_notesMap);
      });
    } else {
      final filteredMap = <String, List<String>>{};
      _notesMap.forEach((className, notes) {
        final filteredNotes = notes.where((note) => note.toLowerCase().contains(query)).toList();
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
        // Swiping in right direction.
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
        // Swiping in left direction.
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
        appBar: mainappbar("Notes", "This page contains all information for the users registered in StudyBunnies", context),
        bottomNavigationBar: navbar(1),
        drawer: studentDrawer(context, 2),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
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
              Expanded(
                child: ListView(
                  children: _filteredNotesMap.keys.map((className) {
                    return Column(
                      children: [
                        _buildClassSection(className, _filteredNotesMap[className]!),
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

  Widget _buildClassSection(String className, List<String> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            className,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(notes[index]),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotesDetailsPage(className: className, chapterName: notes[index]),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                  child: const Text('View'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
