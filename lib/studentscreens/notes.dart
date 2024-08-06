import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/studentscreens/notesdetails.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class Notelist extends StatefulWidget {
  @override
  _NotelistState createState() => _NotelistState();
}

class _NotelistState extends State<Notelist> {
  final storage = const FlutterSecureStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _errorMessage = '';
  String _searchQuery = '';

  Future<List<Map<String, dynamic>>> _fetchClasses(String userID) async {
    List<Map<String, dynamic>> classesList = [];

    try {
      print('Fetching classes for userID: $userID'); // Debug log

      QuerySnapshot classesSnapshot = await _firestore
          .collection('classes')
          .where('student', arrayContains: userID)
          .get();

      print('Classes fetched: ${classesSnapshot.docs.length}'); // Debug log

      if (classesSnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No classes available for this userID.';
        });
        return classesList;
      }

      for (var classDoc in classesSnapshot.docs) {
        Map<String, dynamic> classData = classDoc.data() as Map<String, dynamic>;
        String classID = classDoc.id;

        // Fetch notes for the class
        List<Map<String, dynamic>> notesList = await _fetchNotes(classID);

        classesList.add({
          'classID': classID,
          'class_desc': classData['class_desc'] ?? 'No description',
          'class_img': classData['class_img'] ?? '',
          'classname': classData['classname'] ?? 'No class name',
          'lecturer': classData['lecturer'] ?? [],
          'notes': notesList, // Add notes to the class data
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching classes: $e';
      });
    }

    return classesList;
  }

  Future<List<Map<String, dynamic>>> _fetchNotes(String classID) async {
    List<Map<String, dynamic>> notesList = [];

    try {
      QuerySnapshot notesSnapshot = await _firestore
          .collection('notes')
          .where('classID', isEqualTo: classID)
          .get();

      if (notesSnapshot.docs.isNotEmpty) {
        for (var noteDoc in notesSnapshot.docs) {
          Map<String, dynamic> noteData = noteDoc.data() as Map<String, dynamic>;
          notesList.add({
            'noteID': noteDoc.id,
            'noteTitle': noteData['noteTitle'] ?? 'No title',
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching notes: $e';
      });
    }

    return notesList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar(
        'Notes',
        'Search for notes available for your userID.',
        context,
      ),
      bottomNavigationBar: navbar(1),
      drawer: StudentDrawer(
        drawercurrentindex: 2,
        userID: '', // No need to pass userID here
      ),
      body: FutureBuilder<String?>(
        future: storage.read(key: 'userID'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No userID found.'));
          }

          String userID = snapshot.data!;
          print('Retrieved userID: $userID'); // Debug log

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchClasses(userID),
            builder: (context, classesSnapshot) {
              if (classesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (classesSnapshot.hasError) {
                return Center(child: Text('Error: ${classesSnapshot.error}'));
              }

              if (!classesSnapshot.hasData || classesSnapshot.data!.isEmpty) {
                return Center(child: Text(_errorMessage));
              }

              List<Map<String, dynamic>> classesList = classesSnapshot.data!;
              print('Classes List: $classesList'); // Debug log

              // Filter notes based on search query
              List filteredNotes = classesList
                  .expand((classData) => classData['notes'])
                  .where((note) => note['noteTitle']
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: TextEditingController(
                        text: _searchQuery,
                      ), // Ensure search text is shown
                      decoration: InputDecoration(
                        hintText: 'Search notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.0, // Search bar border color and width
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2.0, // Focused search bar border color
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black, // Search icon color
                        ),
                      ),
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: filteredNotes.isEmpty
                        ? const Center(child: Text('No notes found.'))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: filteredNotes.map((note) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromRGBO(240, 240, 240, 1), // Card border color
                                        width: 2.0, // Card border width
                                      ),
                                      borderRadius: BorderRadius.circular(12.0), // Card border radius
                                      color: const Color.fromRGBO(240, 240, 240, 1), // Card background color
                                    ),
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0), // Card border radius
                                      ),
                                      color: const Color.fromRGBO(240, 240, 240, 1), // Card background color
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              note['noteTitle'],
                                              style: const TextStyle(
                                                fontSize: 16.0, // Text size
                                                color: Colors.black, // Text color
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => NotesDetailsPage(
                                                      userID: userID,
                                                      classID: '', // Adjust if needed
                                                      noteID: note['noteID'],
                                                      className: '', // Adjust if needed
                                                      chapterName: '', // Adjust if needed
                                                      noteTitle: note['noteTitle'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey, // Button color
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8.0), // Button border radius
                                                  side: const BorderSide(
                                                    color: Colors.grey, // Button border color
                                                    width: 1.0, // Button border width
                                                  ),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 8.0, // Button padding
                                                ),
                                              ),
                                              child: const Text(
                                                'View',
                                                style: TextStyle(
                                                  fontSize: 14.0, // Button text size
                                                  color: Colors.black, // Button text color
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
