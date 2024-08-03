import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Feedbacklist extends StatefulWidget {
  const Feedbacklist({super.key});

  @override
  State<Feedbacklist> createState() => _FeedbacklistState();
}

class _FeedbacklistState extends State<Feedbacklist> {
  String? _selectedReason;
  final TextEditingController _feedbackController = TextEditingController();

  // Method to upload feedback data to Firestore
  Future<void> _uploadFeedback() async {
    final feedbackCollectionRef = FirebaseFirestore.instance.collection('feedback');

    try {
      await feedbackCollectionRef.add({
        'feedbackID': DateTime.now().millisecondsSinceEpoch.toString(),
        'generation_date': FieldValue.serverTimestamp(),
        'feedback_title': _selectedReason,
        'feedback_desc': _feedbackController.text,
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

  // Method to validate inputs and call the upload method
  void _validateAndSubmitFeedback() {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for your feedback.')),
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
            Navigator.pop(context);
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
                  border: OutlineInputBorder(),
                ),
                items: ["Option 1", "Option 2", "Option 3"]
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
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Move label to top of the text area
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity, // Full width button
                  child: ElevatedButton(
                    onPressed: _validateAndSubmitFeedback, // Call validation method
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: const Color.fromRGBO(100, 30, 30, 1), // Button background color
                      foregroundColor: const Color.fromRGBO(239, 238, 233, 1), // Text color
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
