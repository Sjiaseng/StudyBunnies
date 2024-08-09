import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'package:studybunnies/teacherwidgets/snackbar.dart';
import 'package:studybunnies/teacherscreens/notes.dart';

class EditNotes extends StatefulWidget {
  final String classID;
  final String className;
  final String noteID;

  const EditNotes(
      {super.key,
      required this.classID,
      required this.className,
      required this.noteID});

  @override
  // ignore: library_private_types_in_public_api
  _EditNotesState createState() => _EditNotesState();
}

class _EditNotesState extends State<EditNotes> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  String? loggedInUserId;

  @override
  void initState() {
    super.initState();
    _fetchNote();
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _fetchNote() async {
    // Fetch the note data from Firestore using the noteID
    DocumentSnapshot noteDoc = await FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.noteID)
        .get();
    if (noteDoc.exists) {
      titleController.text =
          noteDoc['noteTitle']; // Adjust field name as needed
      notesController.text =
          noteDoc['noteContent']; // Adjust field name as needed
    }
  }

  void _saveNote() {
    // Update the note in Firestore
    FirebaseFirestore.instance.collection('notes').doc(widget.noteID).update({
      'noteTitle': titleController.text,
      'noteContent': notesController.text,
    }).then((_) {
      showCustomSnackbar(context, 'Note saved successfully!');
    }).catchError((error) {
      showCustomSnackbar(context, 'Failed to save note: $error');
    });
  }

  void _deleteNote() {
    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              // Check if the document exists
              DocumentSnapshot noteDoc = await FirebaseFirestore.instance
                  .collection('notes')
                  .doc(widget.noteID)
                  .get();
              if (noteDoc.exists) {
                // Delete the note
                await FirebaseFirestore.instance
                    .collection('notes')
                    .doc(widget.noteID)
                    .delete()
                    .then((_) {
                  showCustomSnackbar(context, 'Note deleted successfully!');
                  Navigator.of(context).pop(); // Close the dialog

                  // Navigate back to the notes.dart page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => Notes(
                        classID: widget.classID, // Pass the current classID
                        className:
                            widget.className, // Pass the current className
                      ), // Replace with your Notes page widget
                    ),
                  );
                }).catchError((error) {
                  showCustomSnackbar(context, 'Failed to delete note: $error');
                });
              } else {
                showCustomSnackbar(context, 'Note not found.');
                Navigator.of(context).pop(); // Close the dialog
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: mainappbar("Edit Notes", "", context,
          showBackIcon: true, showProfileIcon: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  widget.className,
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Enter note title...',
                  hintStyle:
                      const TextStyle(color: Color.fromRGBO(113, 118, 121, 1)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(61, 47, 34, 1)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 20.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(61, 47, 34, 1)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: const TextStyle(
                  color: Color.fromRGBO(61, 47, 34, 1),
                ),
              ),
              const SizedBox(height: 40.0),
              Container(
                width: double.infinity,
                height: 370.0,
                margin: const EdgeInsets.only(top: 5.0, bottom: 0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: scrollController,
                  thickness: 6.0,
                  radius: const Radius.circular(10.0),
                  scrollbarOrientation: ScrollbarOrientation.right,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 300.0,
                      ),
                      child: TextFormField(
                        controller: notesController,
                        minLines: null,
                        maxLines: 13,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Enter notes here...',
                          hintStyle: const TextStyle(
                              color: Color.fromRGBO(113, 118, 121, 1)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: const EdgeInsets.all(20.0),
                        ),
                        style: const TextStyle(
                          color: Color.fromRGBO(61, 47, 34, 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _deleteNote();
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text(
                    'Delete Note',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveNote,
        backgroundColor: const Color.fromRGBO(101, 143, 172, 1),
        icon: const Icon(Icons.save_sharp, color: Colors.white),
        label: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar:
          navbar(2), // Replace 2 with the correct index for Classes item
    );
  }
}
