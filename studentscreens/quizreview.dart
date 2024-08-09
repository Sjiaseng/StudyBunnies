import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizReview extends StatefulWidget {
  final String userID;
  final String classID;
  final String quizID;

  const QuizReview({
    Key? key,
    required this.userID,
    required this.classID,
    required this.quizID,
  }) : super(key: key);

  @override
  _QuizReviewState createState() => _QuizReviewState();
}

class _QuizReviewState extends State<QuizReview> {
  bool _hasAttempted = false;

  @override
  void initState() {
    super.initState();
    _checkAttempt();
  }

  Future<void> _checkAttempt() async {
    final attemptSnapshot = await FirebaseFirestore.instance
        .collection('studentQuizAnswer')
        .where('studentID', isEqualTo: widget.userID)
        .where('quizID', isEqualTo: widget.quizID)
        .limit(1)
        .get();

    if (attemptSnapshot.docs.isNotEmpty) {
      setState(() {
        _hasAttempted = true;
      });
    } else {
      setState(() {
        _hasAttempted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Review'),
        backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Class Name, Score, and Quiz Title
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('classes')
                  .doc(widget.classID)
                  .get(),
              builder: (context, classSnapshot) {
                if (!classSnapshot.hasData) {
                  return Text(
                    'Loading class information...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                }

                final classData = classSnapshot.data?.data() as Map<String, dynamic>?;
                final className = classData?['classname'] ?? 'Unknown class';

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('quiz')
                      .doc(widget.quizID)
                      .get(),
                  builder: (context, quizSnapshot) {
                    if (!quizSnapshot.hasData) {
                      return Text(
                        'Loading quiz information...',
                        style: Theme.of(context).textTheme.bodyLarge,
                      );
                    }

                    final quizData = quizSnapshot.data?.data() as Map<String, dynamic>?;
                    final quizTitle = quizData?['quizTitle'] ?? 'Unknown quiz';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                className,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      fontFamily: 'Georgia',
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('studentQuizAnswer')
                                  .where('studentID', isEqualTo: widget.userID)
                                  .where('quizID', isEqualTo: widget.quizID)
                                  .limit(1)
                                  .get(),
                              builder: (context, scoreSnapshot) {
                                if (scoreSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text('Loading score...');
                                }
                                if (scoreSnapshot.hasError) {
                                  return const Text('Error loading score');
                                }
                                if (scoreSnapshot.hasData &&
                                    scoreSnapshot.data!.docs.isNotEmpty) {
                                  final scoreData = scoreSnapshot.data!.docs.first
                                      .data() as Map<String, dynamic>?;
                                  final score = scoreData?['score'] ?? 0;

                                  return Text(
                                    'Score: $score',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23,
                                          fontFamily: 'Georgia',
                                        ),
                                  );
                                }
                                return const SizedBox.shrink(); // No message displayed if no attempt is made
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          quizTitle,
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                                fontFamily: 'Georgia',
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16.0),

            // Display Quiz Questions
            Expanded(
              child: _hasAttempted
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('quizquestion')
                          .where('quizID', isEqualTo: widget.quizID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final questions = snapshot.data?.docs ?? [];
                        if (questions.isEmpty) {
                          return const Center(
                            child: Text('No questions found for this quiz.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            final questionData = questions[index].data() as Map<String, dynamic>;
                            final questionText = questionData['question'] ?? 'No question text';
                            final choices = List<String>.from(questionData['choices'] ?? []);
                            final correctOption = questionData['correctOption'];

                            return Card(
                              color: const Color.fromRGBO(211, 211, 211, 1),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Question ${index + 1}:',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Times New Roman',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      )
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      questionText,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Times New Roman',
                                        fontSize: 17,
                                      )
                                    ),
                                    const SizedBox(height: 8.0),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: List<Widget>.generate(choices.length, (i) {
                                        final choice = choices[i];
                                        final isCorrect = i == correctOption;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                                              backgroundColor:
                                                  isCorrect ? const Color.fromRGBO(225, 247, 213, 1) : const Color.fromRGBO(225, 189, 189, 1),
                                            ),
                                            child: Text(
                                              choice,
                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontFamily: 'Times New Roman',
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No attempt has been made. \nPlease make an attempt before checking the answers.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Times New Roman',
                          fontSize: 20,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
