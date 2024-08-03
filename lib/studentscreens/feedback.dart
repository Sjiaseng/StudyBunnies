import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';

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
      'reason': _selectedReason,
      'feedback': _feedbackController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('Feedback submitted successfully!');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Feedback submitted successfully!')),
    );
    _feedbackController.clear();
    setState(() {
      _selectedReason = null;
    });
  } catch (e) {
    print('Failed to submit feedback: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit feedback')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: inactivenavbar(),
      body: Padding(
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
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _uploadFeedback();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.grey,
                ),
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
