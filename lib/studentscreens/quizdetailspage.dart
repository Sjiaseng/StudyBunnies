import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentscreens/notesdetails.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/timetable.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class QuizDetailsPage extends StatefulWidget {
  final String className;
  final String classID;

  const QuizDetailsPage({super.key, required this.className, required this.classID, required String quizTitle});

  @override
  State<QuizDetailsPage> createState() => _ClassdetailsState();
}

class _ClassdetailsState extends State<QuizDetailsPage> {
  final TextEditingController _searchNotesController = TextEditingController();
  
  List<String> _notes = [];
  List<String> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _searchNotesController.addListener(_filterNotes);
    _fetchNotes();
  }

  @override
  void dispose() {
    _searchNotesController.removeListener(_filterNotes);
    _searchNotesController.dispose();
    super.dispose();
  }

  void _filterNotes() {
    final query = _searchNotesController.text.toLowerCase();
    setState(() {
      _filteredNotes = query.isEmpty
          ? List.from(_notes)
          : _notes.where((note) => note.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _fetchNotes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('classID', isEqualTo: widget.classID)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No notes found for classID ${widget.classID}');
      } else {
        setState(() {
          _notes = snapshot.docs.map((doc) {
            final noteTitle = doc['noteTitle'] as String;
            return noteTitle;
          }).toList();
          _filteredNotes = List.from(_notes);
        });
      }
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
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
        appBar: mainappbar(
          widget.className,
          "This page contains all information for the notes section",
          context,
        ),
        bottomNavigationBar: navbar(1),
        drawer: StudentDrawer(drawercurrentindex: 2, userID: 'userID'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchNotesController,
                decoration: InputDecoration(
                  hintText: 'Search Notes',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Center(
                child: Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: _filteredNotes.map((note) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(217, 217, 217, 1),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: const Color.fromRGBO(241, 241, 241, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  note,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      duration: const Duration(milliseconds: 305),
                                      child: NotesDetailsPage(
                                        noteTitle: note,
                                        classID: widget.classID,
                                        className: widget.className,
                                        chapterName: '', // Adjust as needed
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.grey, // Black text color
                                ),
                                child: const Text('View'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
