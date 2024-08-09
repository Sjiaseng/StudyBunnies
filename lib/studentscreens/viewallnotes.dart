import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/authentication/session.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentscreens/viewnotes.dart';

class Notelist extends StatefulWidget {
  @override
  _NotelistState createState() => _NotelistState();
}

class _NotelistState extends State<Notelist> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Session _session = Session(); // Create an instance of the Session class

  String _errorMessage = '';
  String _searchQuery = '';

  // Function to fetch classes by userID
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
        Map<String, dynamic> classData =
            classDoc.data() as Map<String, dynamic>;
        String classID = classDoc.id;

        // Fetch notes for the class
        List<Map<String, dynamic>> notesList = await _fetchNotes(classID);

        classesList.add({
          'classID': classID,
          'classname': classData['classname'] ?? 'No class name',
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

  // Function to fetch notes by classID
  Future<List<Map<String, dynamic>>> _fetchNotes(String classID) async {
    List<Map<String, dynamic>> notesList = [];

    try {
      QuerySnapshot notesSnapshot = await _firestore
          .collection('notes')
          .where('classID', isEqualTo: classID)
          .get();

      if (notesSnapshot.docs.isNotEmpty) {
        for (var noteDoc in notesSnapshot.docs) {
          Map<String, dynamic> noteData =
              noteDoc.data() as Map<String, dynamic>;
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
        future: _session.getUserId(), // Use the Session class to get the userID
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

              // Group notes by className
              Map<String, List<Map<String, dynamic>>> groupedNotes = {};
              for (var classData in classesList) {
                final className = classData['classname'] ?? 'No class name';
                final notes = classData['notes'] ?? [];
                final filteredClassNotes = notes
                    .where((note) =>
                        filteredNotes.any((n) => n['noteID'] == note['noteID']))
                    .toList();

                if (filteredClassNotes.isNotEmpty) {
                  groupedNotes[className] = filteredClassNotes;
                }
              }

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
                            color: Colors.grey,
                            width: 1.0, // Search bar border color and width
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color:
                                Colors.grey, // Focused search bar border color
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
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
                    child: groupedNotes.isEmpty
                        ? const Center(child: Text('No notes found.'))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: groupedNotes.entries.map((entry) {
                                final className = entry.key;
                                final notes = entry.value;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          className,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Georgia',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 8.0), // Space between class name and card
                                      ...notes.map((note) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromRGBO(240,240, 240, 1), // Card Border Color
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Card(
                                            margin: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            color: const Color.fromRGBO(195, 172, 151, 1), // Card background color
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    note['noteTitle'],
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Times New Roman', // Text size
                                                      color: Color.fromRGBO(61, 12, 2, 1), // Text color
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ViewNotes(
                                                            userID: userID,
                                                            classID: entry.value.firstWhere((n) =>n['noteID'] == note['noteID'])['classID'] ??'',
                                                            noteID: note['noteID'],
                                                            noteTitle: note['noteTitle'],
                                                            className:className,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: const Color.fromRGBO(152,118,84,1), // Button color
                                                      shape:RoundedRectangleBorder(
                                                        borderRadius:BorderRadius.circular(8.0),
                                                        side: const BorderSide(
                                                          color: const Color.fromRGBO(152,118,84,1), // Button border color
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'View Note',
                                                      style: TextStyle(
                                                        fontSize: 13.0,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Times New Roman',
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
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
