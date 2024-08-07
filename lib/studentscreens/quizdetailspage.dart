import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizDetailsPage extends StatefulWidget {
  final String userID;
  final String classID;
  final String quizID;

  const QuizDetailsPage({
    Key? key,
    required this.userID,
    required this.classID,
    required this.quizID,
  }) : super(key: key);

  @override
  _QuizDetailsPageState createState() => _QuizDetailsPageState();
}

class _QuizDetailsPageState extends State<QuizDetailsPage> {
  final Map<String, int?> _selectedOptionIndices =
      {}; // Updated to store indices
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final String studentQuizAnsID = '8heJ8re7mDUVBNJ0FaBw'; // Document name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Details'),
        backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up), // Audio icon
            onPressed: _onAudioIconPressed,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildClassNameAndQuizTitle(),
                const SizedBox(height: 16.0),
              ]),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('quizquestion')
                .where('quizID', isEqualTo: widget.quizID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final questions = snapshot.data!.docs;

              if (questions.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text('No questions found.')),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final questionData =
                        questions[index].data() as Map<String, dynamic>;
                    final questionID =
                        questions[index].id; // Get the questionID
                    final questionNumber = questionData['questionNumber'];
                    final question = questionData['question'];
                    final choices = List<String>.from(questionData['choices']);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question $questionNumber:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              question,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: List.generate(choices.length, (i) {
                                final choice = choices[i];
                                final isSelected =
                                    _selectedOptionIndices[questionID] == i;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _onOptionTap(questionID, choice, i),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      foregroundColor: Colors.black,
                                      backgroundColor: isSelected
                                          ? const Color.fromRGBO(
                                              195, 154, 29, 1)
                                          : Colors.yellow[
                                              100], // Highlight selected option
                                    ),
                                    child: Text(choice),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: questions.length,
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(100, 30, 30, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('Submit'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassNameAndQuizTitle() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classID)
          .get(),
      builder: (context, classSnapshot) {
        if (!classSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final className = classSnapshot.data!.get('classname') as String;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('quiz')
              .doc(widget.quizID)
              .get(),
          builder: (context, quizSnapshot) {
            if (!quizSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final quizTitle = quizSnapshot.data!.get('quizTitle') as String;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  quizTitle,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onAudioIconPressed() async {
    final player = AudioPlayer();
    const assetPath =
        'assets/audio/once-in-paris-168895.mp3'; // Path to the audio file in assets

    try {
      // Play the audio file from assets
      await player.play(AssetSource(assetPath));

      print('Audio is playing');
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  bool _areAllQuestionsAnswered(List<String> questionIDs) {
    return questionIDs
        .every((questionID) => _selectedOptionIndices.containsKey(questionID));
  }

  // void _onOptionTap(String questionID, String selectedOption, int index) {
  //   setState(() {
  //     _selectedOptionIndices[questionID] = index; // Store the index
  //   });

  //   // Fetch the index of the selected option and store it
  //   FirebaseFirestore.instance.collection('userResponses').add({
  //     'userID': widget.userID,
  //     'questionID': questionID,
  //     'chooseOption': index, // Store the selected option index
  //     'timestamp': FieldValue.serverTimestamp(),
  //   }).then((value) {
  //     print('Selected option index stored successfully.');
  //   }).catchError((error) {
  //     print('Failed to store selected option index: $error');
  //   });
  // }

  void _onOptionTap(String questionID, String selectedOption, int index) {
  setState(() {
    _selectedOptionIndices[questionID] = index; // Store the index locally
  });
}

// function to update the details to the studentQuizAnswer collection after click on submit
void _onSubmit() async {
  // Map the selected options to a format suitable for submission
  final studentAnswers = _selectedOptionIndices.entries.map((entry) {
    return {'questionID': entry.key, 'chooseOption': entry.value};
  }).toList();

  try {
    // Calculate the score based on the selected options
    final score = await _calculateScore();

    // Generate a unique ID for the document
    final studentQuizAnsID = _firestore.collection('studentQuizAnswer').doc().id;

    // Create a new document in 'studentQuizAnswer' collection with the specified ID
    await _firestore.collection('studentQuizAnswer').doc(studentQuizAnsID).set({
      'studentQuizAnsID': studentQuizAnsID, // Save the document ID
      'quizID': widget.quizID,
      'score': score, // Use the calculated score
      'studentAnswer': studentAnswers,
      'studentID': widget.userID,
      'submission': 'submitted',
      'submissionDate': FieldValue.serverTimestamp(),
    });

    // Update student's points
    await _updateStudentPoints(score);

    print('Quiz answers submitted successfully.');
    Navigator.pop(context); // Optionally navigate back or show a success message
  } catch (error) {
    print('Failed to submit quiz answers: $error');
  }
}

// function to calculate score obtained by the student
  Future<int> _calculateScore() async {
    int score = 0;

    for (var entry in _selectedOptionIndices.entries) {
      final questionID = entry.key;
      final selectedOptionIndex = entry.value;

      try {
        final questionSnapshot = await FirebaseFirestore.instance
            .collection('quizquestion')
            .doc(questionID)
            .get();

        if (questionSnapshot.exists) {
          final questionData = questionSnapshot.data() as Map<String, dynamic>;
          final correctOptionIndex = questionData[
              'correctOption']; // Ensure this field matches Firestore

          if (selectedOptionIndex == correctOptionIndex) {
            score += 1;
          }
        }
      } catch (e) {
        print('Error fetching question: $e');
      }
    }

    return score;
  }

  Future<void> _updateStudentPoints(int score) async {
    try {
      final studentPointsDoc =
          await _firestore.collection('points').doc(widget.userID).get();

      if (studentPointsDoc.exists) {
        final currentPoints = studentPointsDoc.data()!['points'] as int? ?? 0;
        final updatedPoints = currentPoints + score;

        await _firestore.collection('points').doc(widget.userID).update({
          'points': updatedPoints,
        });

        print('Student points updated successfully.');
      } else {
        print('Student document not found in points collection.');
      }
    } catch (error) {
      print('Failed to update student points: $error');
    }
  }
}
