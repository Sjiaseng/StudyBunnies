import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'package:studybunnies/teacherwidgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddNotes extends StatefulWidget {
  final String classID;
  final String className;
  const AddNotes({super.key, required this.classID, required this.className});

  @override
  // ignore: library_private_types_in_public_api
  _AddNotesState createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  String? loggedInUserId;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      loggedInUserId = user?.uid;
    });
  }

  void _saveNote() async {
    // Ensure loggedInUserId is set
    getCurrentUser();

    if (loggedInUserId == null) {
      showCustomSnackbar(context, 'User not logged in!');
      return;
    }

    String noteTitle = titleController.text.trim();
    String noteContent = notesController.text.trim();

    // Check if title or content is empty
    if (noteTitle.isEmpty || noteContent.isEmpty) {
      showCustomSnackbar(context, 'Please fill in both title and content.');
      return;
    }

    // Generate a new note ID - use Firestore's automatic ID generation
    String noteID = FirebaseFirestore.instance.collection('notes').doc().id;

    // Prepare note data
    Map<String, dynamic> noteData = {
      'classID': widget.classID,
      'noteID': noteID,
      'noteTitle': noteTitle,
      'noteContent': noteContent,
      'link': '-',
      'teacherID': loggedInUserId,
      'postedDate': Timestamp.now(),
    };

    try {
      // Save the note to Firestore
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(noteID)
          .set(noteData);

      // After saving, show the custom snackbar
      showCustomSnackbar(context, 'Note created successfully!');

      // Optionally, navigate back or clear the fields
      Navigator.pop(context);
    } catch (e) {
      showCustomSnackbar(context, 'Error saving note: $e');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: mainappbar("Add New Notes",
          "This is the Add New Notes screen for ${widget.className}.", context,
          showBackIcon: true),
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
                margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: scrollController,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: TextFormField(
                      controller: notesController,
                      minLines: null,
                      maxLines: 14,
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
      bottomNavigationBar: navbar(2), 
    );
  }
}
