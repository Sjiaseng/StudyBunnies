import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class Feedbacklist extends StatefulWidget {
  const Feedbacklist({super.key});

  @override
  State<Feedbacklist> createState() => _FeedbacklistState();
}

class _FeedbacklistState extends State<Feedbacklist> {
  String? _selectedReason;
  final TextEditingController _feedbackController = TextEditingController();
  String? _userRole;
  String? _userID;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeUserDetails();
  }

  Future<void> _initializeUserDetails() async {
    try {
      // Retrieve userID from the session
      _userID = await _secureStorage.read(key: 'userID');

      if (_userID != null) {
        // Fetch user details from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userID)
            .get();
        if (userDoc.exists) {
          setState(() {
            _userRole = userDoc.data()?['role']; 
          });
        }
      }
    } catch (e) {
      print('Error retrieving user details: $e');
    }
  }

  Future<void> _uploadFeedback() async {
    final feedbackCollectionRef =
        FirebaseFirestore.instance.collection('feedback');

    try {
      // Add a new document to the collection and get the document reference
      final docRef = await feedbackCollectionRef.add({
        'generation_date': FieldValue.serverTimestamp(),
        'feedback_title': _selectedReason,
        'feedback_desc': _feedbackController.text,
        'userID': _userID, // Include the userID in the feedback data
        'user_role': _userRole, // Include the userRole in the feedback data
      });

      // Update the document with the feedbackID as the document ID
      await docRef.update({
        'feedbackID': docRef.id,
      });

      print('Feedback submitted successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );
      _feedbackController.clear();
      setState(() {
        _selectedReason = null;
      });
    } catch (e) {
      print('Failed to submit feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit feedback')),
      );
    }
  }

// Validation Before Submit Feedback
  void _validateAndSubmitFeedback() {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a reason for your feedback.')),
      );
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback.')),
      );
      return;
    }

    _uploadFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Feedback",
          style: TextStyle(color: Color.fromRGBO(239, 238, 233, 1)),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(239, 238, 233, 1),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StudentDashboard()),
            );
          },
        ),
        backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Icon(
                  Icons.edit_square,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Want to share your thoughts?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Let us know what you think about StudyBunnies.\nWe'd love to hear your ideas.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: const InputDecoration(
                  labelText: "Reason for feedback",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                items: [
                  "App Performance",
                  "Feature Request",
                  "Bug Report",
                  "General Feedback",
                  "Other"
                ]
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Text area",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _validateAndSubmitFeedback,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
                      foregroundColor: const Color.fromRGBO(239, 238, 233, 1),
                    ),
                    child: const Text("Submit"),
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
