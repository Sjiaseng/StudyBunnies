import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';

class ViewNotes extends StatefulWidget {
  final String classID;
  final String noteID;
  final String noteTitle;
  final String noteContent;
  final String className;

  const ViewNotes({
    super.key,
    required this.classID,
    required this.noteID,
    required this.noteTitle,
    required this.noteContent,
    required this.className,
  });

  @override
  State<ViewNotes> createState() => _ViewNotesState();
}

class _ViewNotesState extends State<ViewNotes> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};
  final Map<String, bool> _expandedComments = {};
  bool _isPublicCommentsExpanded = false;

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

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown date'; // Or handle null case appropriately
    }
    return DateFormat('yyyy-MM-dd h:mm:ss a').format(timestamp.toDate());
  }

  Future<List<Map<String, dynamic>>> _fetchComments() async {
    List<Map<String, dynamic>> comments = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('comments')
        .where('noteID', isEqualTo: widget.noteID)
        .get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['commentID'] = doc.id;

      // Fetch user info from 'users' collection using userID
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(data['userID'])
          .get();
      data['username'] = userSnapshot['username'];

      // Fetch replies for each comment
      List<Map<String, dynamic>> replies = [];
      QuerySnapshot replySnapshot = await FirebaseFirestore.instance
          .collection('replies')
          .where('commentID', isEqualTo: doc.id)
          .get();

      for (var replyDoc in replySnapshot.docs) {
        Map<String, dynamic> replyData =
            replyDoc.data() as Map<String, dynamic>;

        // Fetch user info for each reply
        DocumentSnapshot replyUserSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(replyData['userID'])
            .get();
        replyData['username'] = replyUserSnapshot['username'];

        replies.add(replyData);
      }

      data['replies'] = replies;
      comments.add(data);
    }
    return comments;
  }

  Future<void> _postComment(String commentContent) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && commentContent.isNotEmpty) {
      // Generate a new commentID
      String commentID =
          FirebaseFirestore.instance.collection('comments').doc().id;

      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentID)
          .set({
        'commentID': commentID,
        'userID': user.uid,
        'commentContent': commentContent,
        'noteID': widget.noteID,
        'generationDate': Timestamp.now(),
      });

      _commentController.clear();
      setState(() {});
    }
  }

  Future<void> _postReply(String commentID, String reply) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && reply.isNotEmpty) {
      // Generate a new replyID
      String replyID =
          FirebaseFirestore.instance.collection('replies').doc().id;

      await FirebaseFirestore.instance.collection('replies').doc(replyID).set({
        'replyID': replyID,
        'userID': user.uid,
        'replyContent': reply,
        'commentID': commentID,
      });

      _replyControllers[commentID]?.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: mainappbar("View Notes", "", context,
          showBackIcon: true, showProfileIcon: false),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Class Name Section
              Center(
                child: Text(
                  widget.className,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20.0),
              // Notes Title Section
              TextField(
                controller: TextEditingController(text: widget.noteTitle),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromRGBO(213, 208, 176, 1),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 20.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(213, 208, 176, 1)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(213, 208, 176, 1)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: const TextStyle(
                  color: Color.fromRGBO(61, 47, 34, 1),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
                readOnly: true,
                enableInteractiveSelection: false,
              ),
              const SizedBox(height: 30.0),
              // Notes Content Section
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(213, 208, 213, 1),
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 8.0,
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: TextFormField(
                      initialValue: widget.noteContent,
                      minLines: null,
                      maxLines: 15,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(213, 208, 213, 1),
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(213, 208, 213, 1)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(213, 208, 213, 1)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: const EdgeInsets.all(20.0),
                      ),
                      style: const TextStyle(
                        color: Color.fromRGBO(61, 47, 34, 1),
                      ),
                      readOnly: true,
                      enableInteractiveSelection: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // Public Comments Section
              // Public Comments Section
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchComments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching comments'));
                  } else {
                    final comments = snapshot.data ?? [];
                    return ExpansionPanelList(
                      elevation: 1,
                      expandedHeaderPadding: const EdgeInsets.all(0),
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _isPublicCommentsExpanded =
                              !_isPublicCommentsExpanded;
                        });
                      },
                      children: [
                        ExpansionPanel(
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return Container(
                              padding: const EdgeInsets.all(14.0),
                              child: const Text(
                                'Public Comments',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(61, 47, 34, 1),
                                ),
                              ),
                            );
                          },
                          body: Container(
                            padding: const EdgeInsets.all(14.0),
                            color: const Color.fromRGBO(243, 230, 176, 1),
                            child: Column(
                              children: [
                                if (comments.isEmpty)
                                  const Center(
                                      child: Text('No comments available')),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = comments[index];
                                    final commentID = comment['commentID'];
                                    final replies = comment['replies'];
                                    final bool isCommentExpanded =
                                        _expandedComments[commentID] ?? false;
                                    final replyController =
                                        _replyControllers[commentID] ??
                                            TextEditingController();
                                    _replyControllers[commentID] =
                                        replyController;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png'),
                                                    radius: 15,
                                                  ),
                                                  const SizedBox(width: 10.0),
                                                  Text(
                                                    comment['username'] ??
                                                        'Unknown',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromRGBO(
                                                          61, 47, 34, 1),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5.0),
                                                  Text(
                                                    formatDate(comment[
                                                            'generationDate']
                                                        as Timestamp?),
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5.0),
                                              Text(
                                                comment['commentContent'] ?? '',
                                                style: const TextStyle(
                                                  color: Color.fromRGBO(
                                                      61, 47, 34, 1),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _expandedComments[
                                                            commentID] =
                                                        !isCommentExpanded;
                                                  });
                                                },
                                                child: Text(
                                                  isCommentExpanded
                                                      ? 'Hide Replies'
                                                      : 'Show Replies',
                                                  style: const TextStyle(
                                                    color: Color.fromRGBO(
                                                        172, 130, 103, 1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isCommentExpanded)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: replies.length,
                                                  itemBuilder:
                                                      (context, replyIndex) {
                                                    final reply =
                                                        replies[replyIndex];
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 10.0),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromRGBO(
                                                            243, 230, 176, 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 1,
                                                            blurRadius: 5,
                                                            offset:
                                                                const Offset(
                                                                    0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const CircleAvatar(
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png'),
                                                                radius: 15,
                                                              ),
                                                              const SizedBox(
                                                                  width: 10.0),
                                                              Text(
                                                                reply['username'] ??
                                                                    'Unknown',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          61,
                                                                          47,
                                                                          34,
                                                                          1),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 5.0),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5.0),
                                                          Text(
                                                            reply['replyContent'] ??
                                                                '',
                                                            style:
                                                                const TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      61,
                                                                      47,
                                                                      34,
                                                                      1),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 10.0),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            replyController,
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText: 'Reply...',
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10.0),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.send),
                                                      onPressed: () {
                                                        _postReply(
                                                            commentID,
                                                            replyController
                                                                .text);
                                                      },
                                                      color:
                                                          const Color.fromRGBO(
                                                              172, 130, 103, 1),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _commentController,
                                        decoration: const InputDecoration(
                                          hintText: 'Add a comment...',
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.send),
                                      onPressed: () {
                                        _postComment(_commentController.text);
                                      },
                                      color: const Color.fromRGBO(
                                          172, 130, 103, 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          isExpanded: _isPublicCommentsExpanded,
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: navbar(2),
    );
  }
}
