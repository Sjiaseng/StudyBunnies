import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studybunnies/studentmodels/comment.dart';
import 'package:studybunnies/studentmodels/reply.dart';

class NotesDetailsPage extends StatefulWidget {
  const NotesDetailsPage({
    super.key,
    required this.className,
    required this.chapterName,
    required this.classID,
    required this.noteTitle,
    required this.noteID,
    required String userID,
  });

  final String className;
  final String chapterName;
  final String classID;
  final String noteTitle;
  final String noteID;

  @override
  _NotesDetailsPageState createState() => _NotesDetailsPageState();
}

class _NotesDetailsPageState extends State<NotesDetailsPage> {
  late Future<DocumentSnapshot> _noteDocument;
  bool _commentsExpanded = false;
  final List<Comment> _comments = []; // List to hold comments
  final TextEditingController _newCommentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.noteID.isEmpty) {
      throw ArgumentError('noteID cannot be empty');
    }

    _noteDocument = FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.noteID)
        .get();

    // Fetch comments
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      var commentsSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('noteID', isEqualTo: widget.noteID)
          .get();

      // Fetch all comments
      List<Comment> commentsList = [];

      for (var doc in commentsSnapshot.docs) {
        var commentData = doc.data();
        String commentID = commentData['commentID'];
        String userID = commentData['userID'];
        String commentContent = commentData['commentContent'];
        Timestamp generationDate = commentData['generationDate'];

        // Fetch username for the comment
        var userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .get();
        String username = userSnapshot.data()?['username'] ?? 'Unknown User';

        // Fetch replies for the comment
        var repliesSnapshot = await FirebaseFirestore.instance
            .collection('replies')
            .where('commentID', isEqualTo: commentID)
            .get();

        List<Reply> repliesList = [];
        for (var replyDoc in repliesSnapshot.docs) {
          var replyData = replyDoc.data();
          String replyUserID = replyData['userID'];
          String replyContent = replyData['replyContent'];

          // Fetch username for the reply
          var replyUserSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(replyUserID)
              .get();
          String replyUsername = replyUserSnapshot.data()?['username'] ?? 'Unknown User';

          repliesList.add(Reply(
            replyContent: replyContent,
            userID: replyUserID,
            username: replyUsername, profileImgUrl: '',
          ));
        }

        commentsList.add(Comment(
          commentID: commentID,
          commentContent: commentContent,
          generationDate: generationDate.toDate(),
          username: username,
          replies: repliesList, profileImgUrl: '',
        ));
      }

      setState(() {
        _comments.clear();
        _comments.addAll(commentsList);
        print('Fetched comments: $_comments'); // Debug print
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
      title: Text(
        widget.className,
        style: const TextStyle(color: Color.fromRGBO(239, 238, 233, 1)),
      ),
      iconTheme: const IconThemeData(
        color: Color.fromRGBO(239, 238, 233, 1),
      ),
    ),
    body: FutureBuilder<DocumentSnapshot>(
      future: _noteDocument,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('Note not found'));
        }

        var noteData = snapshot.data!.data() as Map<String, dynamic>;
        String noteContent = noteData['noteContent'] ?? 'No content available';

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chapterName,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes:',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.noteTitle,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noteContent,
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(217, 217, 217, 1),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: GestureDetector(
                          onTap: () {
                            setState(() {
                              _commentsExpanded = !_commentsExpanded;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Public Comments:',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(_commentsExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                            ],
                          ),
                        ),
                      ),
                      if (_commentsExpanded) ...[
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 400.0,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            'https://example.com/default_profile.png', // Placeholder for profile image
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comment.username,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                comment.commentContent,
                                              ),
                                              Text(
                                                '${comment.generationDate.toLocal()}',
                                                style: const TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    ...comment.replies.map((reply) => Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              'https://example.com/default_profile.png', // Placeholder for profile image
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  reply.username,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  reply.replyContent,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newCommentController,
                                decoration: const InputDecoration(
                                  hintText: 'Add a new comment...',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                // Add functionality to submit a new comment
                                setState(() {
                                  // Update comments with the new comment
                                  _comments.add(Comment(
                                    commentID: 'newCommentID', // Replace with actual ID
                                    commentContent: _newCommentController.text,
                                    generationDate: DateTime.now(),
                                    username: 'Your Username', // Replace with actual username
                                    replies: [], profileImgUrl: '',
                                  ));
                                  _newCommentController.clear();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}