import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewNotes extends StatefulWidget {
  final String classID;
  final String noteID;
  final String noteTitle;
  final String className;
  final String userID;

  const ViewNotes({
    Key? key,
    required this.classID,
    required this.noteID,
    required this.noteTitle,
    required this.className,
    required this.userID,
  }) : super(key: key);

  @override
  State<ViewNotes> createState() => _ViewNotesState();
}

class _ViewNotesState extends State<ViewNotes> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};

  late CollectionReference commentsCollection;
  late CollectionReference repliesCollection;
  late CollectionReference usersCollection;
  late CollectionReference notesCollection;

  @override
  void initState() {
    super.initState();
    commentsCollection = FirebaseFirestore.instance.collection('comments');
    repliesCollection = FirebaseFirestore.instance.collection('replies');
    usersCollection = FirebaseFirestore.instance.collection('users');
    notesCollection = FirebaseFirestore.instance.collection('notes');
  }

  Future<String> _fetchUsername(String userID) async {
    if (userID.isEmpty) return 'Unknown User';
    try {
      DocumentSnapshot userDoc = await usersCollection.doc(userID).get();
      return userDoc.exists
          ? (userDoc.data() as Map<String, dynamic>)['username'] ??
              'Unknown User'
          : 'Unknown User';
    } catch (e) {
      print("Error fetching username: $e");
      return 'Unknown User';
    }
  }

  Future<String> _fetchNoteContent() async {
    DocumentSnapshot noteDoc = await notesCollection.doc(widget.noteID).get();
    return noteDoc.exists
        ? (noteDoc.data() as Map<String, dynamic>)['noteContent'] ??
            'Content not found'
        : 'Content not found';
  }

  Future<List<Map<String, dynamic>>> _fetchComments() async {
    try {
      QuerySnapshot commentsSnapshot = await commentsCollection
          .where('noteID', isEqualTo: widget.noteID)
          .get();

      List<Map<String, dynamic>> comments = [];

      for (var doc in commentsSnapshot.docs) {
        Map<String, dynamic> comment = doc.data() as Map<String, dynamic>;
        comment['commentID'] = doc.id; // Add comment ID for fetching replies
        comment['username'] =
            await _fetchUsername(comment['userID']); // Fetch username
        comment['replies'] = await _fetchReplies(comment['commentID']);
        _replyControllers.putIfAbsent(comment['commentID'],
            () => TextEditingController()); // Initialize controller
        comments.add(comment);
      }

      return comments;
    } catch (e) {
      print("Error fetching comments: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchReplies(String commentID) async {
    try {
      QuerySnapshot repliesSnapshot = await repliesCollection
          .where('commentID', isEqualTo: commentID)
          .get();

      List<Map<String, dynamic>> replies = [];

      for (var doc in repliesSnapshot.docs) {
        Map<String, dynamic> reply = doc.data() as Map<String, dynamic>;
        reply['username'] = await _fetchUsername(
            reply['userID']); // Fetch username for each reply
        replies.add(reply);
      }

      return replies;
    } catch (e) {
      print("Error fetching replies: $e");
      return [];
    }
  }

  void _postComment() async {
    String commentContent = _commentController.text.trim();

    if (commentContent.isNotEmpty) {
      try {
        // Add the comment and get the document reference
        DocumentReference commentDocRef = await commentsCollection.add({
          'noteID': widget.noteID,
          'userID': widget.userID, // Ensure the userID is passed correctly
          'commentContent': commentContent,
          'generationDate': FieldValue.serverTimestamp(),
        });

        // Get the document ID and update the document with commentID
        String commentID = commentDocRef.id;
        await commentDocRef.update({'commentID': commentID});

        // Clear the comment input field
        _commentController.clear();

        // Refresh the comments list
        setState(() {});
      } catch (e) {
        print("Error posting comment: $e");
      }
    } else {
      print("Comment content is empty.");
    }
  }

  void _postReply(String commentID) async {
    String replyContent = _replyControllers[commentID]?.text.trim() ?? '';

    if (replyContent.isNotEmpty) {
      try {
        // Add the reply and get the document reference
        DocumentReference replyDocRef = await repliesCollection.add({
          'commentID': commentID,
          'userID': widget.userID, // Ensure the userID is passed correctly
          'replyContent': replyContent,
        });

        // Get the document ID and update the document with replyID
        String replyID = replyDocRef.id;
        await replyDocRef.update({'replyID': replyID});

        // Clear the reply input field
        _replyControllers[commentID]?.clear();

        // Refresh the comments list
        setState(() {});
      } catch (e) {
        print("Error posting reply: $e");
      }
    } else {
      print("Reply content is empty.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View Notes",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Class Name
                  Center(
                    child: Text(
                      widget.className,
                      style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Georgia'),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Note Name
                  TextField(
                    controller: TextEditingController(text: widget.noteTitle),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(195, 172, 151, 1),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 20.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: const TextStyle(
                        color: Colors.brown,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Times New Roman',
                        ),
                    readOnly: true,
                    enableInteractiveSelection: false,
                  ),
                  const SizedBox(height: 20.0),
                  // Function To Fetch Note Content
                  FutureBuilder<String>(
                    future: _fetchNoteContent(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Note content not found.'));
                      }

                      String noteContent = snapshot.data!;
                      // Note Content
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            noteContent,
                            style: const TextStyle(
                                color: Colors.brown, 
                                fontSize: 16.0,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20.0),
                  // Function To Fetch Comments
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchComments(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No comments yet.'));
                      }

                      List<Map<String, dynamic>> comments = snapshot.data!;

                      return Column(
                        children: comments.map<Widget>((comment) {
                          final controller =
                              _replyControllers[comment['commentID']]!;
                          // Commments Section
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            color: const Color.fromRGBO(195, 172, 151, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              // side: BorderSide(
                              //     color: Colors.grey, width: 1.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Username for comment section
                                  Text(
                                    comment['username'] ?? 'Unknown User',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Times New Roman'
                                        ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  // Comment
                                  Text(
                                    comment['commentContent'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Times New Roman'
                                      ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  ...comment['replies']?.map<Widget>((reply) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0, top: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Username for reply section
                                              Text(
                                                reply['username'] ??
                                                    'Unknown User',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontFamily: 'Times New Roman'
                                                    ),
                                              ),
                                              const SizedBox(height: 5.0),
                                              // Reply
                                              Text(
                                                reply['replyContent'] ?? '',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Times New Roman',
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })?.toList() ??
                                      [],
                                  const Divider(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controller,
                                          cursorColor: Colors.brown,
                                          decoration: const InputDecoration(
                                            hintText: 'Write a reply...',
                                            border: InputBorder.none,
                                            )
                                          ),
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.send,
                                            color: Colors.brown),
                                        onPressed: () {
                                          _postReply(comment['commentID']);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 5.0),
                  TextField(
                    controller: _commentController,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey,
                          ),
                        ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.grey),
                        onPressed: _postComment,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
