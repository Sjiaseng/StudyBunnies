import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'addnotes.dart';
import 'editnotes.dart';
import 'viewnotes.dart';

class Notes extends StatefulWidget {
  final String classID;
  final String className;

  const Notes({Key? key, required this.classID, required this.className})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _notesList = [];
  List<Map<String, String>> _filteredNotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterNotes);
    fetchNotes();
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
          ? List.from(_notesList)
          : _notesList
              .where((note) => note['noteTitle']!.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> fetchNotes() async {
    try {
      QuerySnapshot notesSnapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('classID', isEqualTo: widget.classID)
          .get();

      List<Map<String, String>> fetchedNotes = [];

      for (var noteDoc in notesSnapshot.docs) {
        String noteID = noteDoc.id;
        String noteTitle = noteDoc['noteTitle'];
        String noteContent = noteDoc['noteContent'];

        fetchedNotes.add({
          'noteID': noteID,
          'noteTitle': noteTitle,
          'noteContent': noteContent,
        });
      }

      setState(() {
        _notesList = fetchedNotes;
        _filteredNotes = fetchedNotes;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching notes: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: mainappbar(
          "Notes", "This is the notes screen for ${widget.className}.", context,
          showBackIcon: true),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.className,
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search notes...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredNotes.isEmpty
                      ? const Center(
                          child: Text('No notes found for this class.'))
                      : Column(
                          children: _filteredNotes.map((noteData) {
                            String noteID = noteData['noteID']!;
                            String noteTitle = noteData['noteTitle']!;
                            String noteContent = noteData['noteContent']!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  margin: const EdgeInsets.only(bottom: 20.0),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(213, 208, 176, 1),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        noteTitle,
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          _NotesButton(
                                            label: 'Edit',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditNotes(
                                                    classID: widget.classID,
                                                    noteID: noteID,
                                                    className: widget.className,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          _NotesButton(
                                            label: 'View',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewNotes(
                                                    classID: widget.classID,
                                                    noteID: noteID,
                                                    className: widget.className,
                                                    noteTitle: noteTitle,
                                                    noteContent: noteContent,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNotes(
                classID: widget.classID, 
                className: widget.className,
              ),
            ),
          );
        },
        backgroundColor: const Color.fromRGBO(172, 130, 103, 1),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: navbar(2),
    );
  }
}

class _NotesButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NotesButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(172, 130, 103, 1),
        padding: const EdgeInsets.symmetric(
            horizontal: 10.0, vertical: 5.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
