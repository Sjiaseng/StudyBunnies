import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentscreens/notesdetails.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/timetable.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class Classdetails extends StatefulWidget {
  final String className;

  const Classdetails({super.key, required this.className});

  @override
  State<Classdetails> createState() => _ClassdetailsState();
}

class _ClassdetailsState extends State<Classdetails> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _notes = [
    'Chapter 1',
    'Chapter 2',
    'Chapter 3',
    'Chapter 4'
  ];
  List<String> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _filteredNotes = List.from(_notes);
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
    setState(() {
      _filteredNotes = query.isEmpty
          ? List.from(_notes)
          : _notes.where((note) => note.toLowerCase().contains(query)).toList();
    });
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
        appBar: mainappbar(
          "Notes",
          "This page contains all information for the notes",
          context,
        ),
        bottomNavigationBar: navbar(1),
        drawer: studentDrawer(context, 2),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to start
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
              Center(
                child: Text(
                  widget.className,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredNotes.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(241, 241, 241, 1),
                        border: Border.all(
                          color: const Color.fromRGBO(217, 217, 217, 1),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(_filteredNotes[index]),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotesDetailsPage(
                                  className: widget.className,
                                  chapterName: _filteredNotes[index],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                          ),
                          child: const Text('View'),
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
