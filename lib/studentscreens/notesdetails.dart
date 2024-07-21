import 'package:flutter/material.dart';

class NotesDetailsPage extends StatefulWidget {
  const NotesDetailsPage(
      {super.key, required this.className, required this.chapterName});

  final String className;
  final String chapterName;

  @override
  _NotesDetailsPageState createState() => _NotesDetailsPageState();
}

class _NotesDetailsPageState extends State<NotesDetailsPage> {
  bool _commentsExpanded = false;
  final TextEditingController _newCommentController = TextEditingController();
  final List<String> _comments = List.generate(
      10,
      (index) =>
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec.'); // Sample comments

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
          color: Color.fromRGBO(239, 238, 233, 1), // Change icon color here
        ),
      ),
      body: SingleChildScrollView(
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
              const SizedBox(height: 16.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text('These are the notes for the class.'),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Images:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Placeholder for images
                      Row(
                        children: [
                          Expanded(
                            child: Image.network(
                                'https://via.placeholder.com/150'),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Image.network(
                                'https://via.placeholder.com/150'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50], // Background color
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
                      const SizedBox(height: 8.0),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 170.0, // Set a max height to prevent overflow
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          child: Icon(Icons.person),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text('User ${index + 1}'),
                                                  const SizedBox(width: 8.0),
                                                  const Text(
                                                    '22/03/2024 18:24', // Change this to actual date and time
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 1.0),
                                              Text(
                                                _comments[index], // Use the comments list
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    if (_commentsExpanded) ...[
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              child: TextField(
                                                maxLines: 2,
                                                decoration: InputDecoration(
                                                  hintText: 'Reply',
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(Icons.send),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_commentsExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newCommentController, // Connect the controller
                            decoration: const InputDecoration(
                              hintText: 'Add new comment',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_newCommentController.text.isNotEmpty) {
                                _comments.add(_newCommentController.text);
                                _newCommentController.clear();
                              }
                            });
                          },
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
