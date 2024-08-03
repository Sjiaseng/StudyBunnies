import 'package:flutter/material.dart';

class NotesDetailsPage extends StatefulWidget {
  const NotesDetailsPage(
      {super.key, required this.className, required this.chapterName});

  final String className; // Class name passed from previous page
  final String chapterName; // Chapter name passed from previous page

  @override
  _NotesDetailsPageState createState() => _NotesDetailsPageState();
}

class _NotesDetailsPageState extends State<NotesDetailsPage> {
  bool _commentsExpanded = false; // To toggle the visibility of comments
  final TextEditingController _newCommentController =
      TextEditingController(); // Controller for adding new comments
  final List<String> _comments = List.generate(
      10,
      (index) =>
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec.There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don look even slightly believable.'); // Sample comments

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromRGBO(100, 30, 30, 1), // AppBar background color
        title: Text(
          widget.className, // Display class name in the AppBar
          style: const TextStyle(
              // Title text color
              color: Color.fromRGBO(239, 238, 233, 1)),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(239, 238, 233, 1), // Icon color in AppBar
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), // Padding around the main content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chapterName, // Display chapter name
                style: const TextStyle(
                  fontSize: 24.0, // Font size for chapter name
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
              const SizedBox(
                  // Spacing between chapter name and notes
                  height: 16.0),
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16.0), // Padding inside the Card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes:', // Section title for notes
                        style: TextStyle(
                          fontSize: 18.0, // Font size for section titles
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                      const SizedBox(
                          height: 8.0 // Spacing between section title and notes
                          ),
                      const Text(
                          'These are the notes for the class.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum'),
                      const SizedBox(
                        height: 16.0, // Spacing between notes and images
                      ),
                      const Text(
                        'Images:', // Section title for images
                        style: TextStyle(
                          fontSize: 18.0, // Font size for section titles
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                      const SizedBox(
                        height: 8.0, // Spacing between section title and images
                      ),
                      // Placeholder for images
                      Row(
                        children: [
                          Expanded(
                            child: Image.network(
                                'https://via.placeholder.com/150'),
                          ),
                          const SizedBox(width: 8.0), // Spacing between images
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
              const SizedBox(height: 16.0), // Spacing between sections
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(217, 217, 217,
                      1), // Background color for comments section
                  border: Border.all(color: Colors.grey), // Border color
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            _commentsExpanded =
                                !_commentsExpanded; // Toggle comments visibility
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Public Comments:', // Section title for public comments
                              style: TextStyle(
                                fontSize: 18.0, // Font size for section titles
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                            ),
                            Icon(_commentsExpanded
                                ? Icons
                                    .expand_less // Icon when comments are expanded
                                : Icons
                                    .expand_more), // Icon when comments are collapsed
                          ],
                        ),
                      ),
                    ),
                    if (_commentsExpanded) ...[
                      const SizedBox(
                        height:
                            2.0, // Spacing between section title and comments
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight:
                              170.0, // Set a max height to prevent overflow
                        ),
                        child: ListView.builder(
                          shrinkWrap:
                              true, // Prevents the ListView from taking up more space than necessary
                          itemCount: _comments.length, // Number of comments
                          itemBuilder: (context, index) {
                            return Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width *
                                    0.8, // Adjust the maxWidth to be smaller
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    8.0), // Padding inside the comment card
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row for user info and date
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          foregroundColor: Colors.black,
                                          child: Icon(Icons.person),
                                        ),
                                        const SizedBox(
                                            width:
                                                8.0), // Spacing between avatar and text
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'User ${index + 1}', // User name
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold, // Bold text for user name
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          8.0), // Spacing between user name and date
                                                  Text(
                                                    '22/03/2024 18:24', // Placeholder date and time
                                                    style: const TextStyle(
                                                      fontSize:
                                                          12.0, // Font size for date
                                                      color: Colors
                                                          .grey, // Text color for date
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height:
                                                      4.0), // Spacing between date and comment text
                                              Text(
                                                _comments[
                                                    index], // Comment text
                                                style: const TextStyle(
                                                  fontSize:
                                                      14.0, // Font size for comment text
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height:
                                            8.0), // Spacing between comment text and reply field
                                    if (_commentsExpanded) ...[
                                      Container(
                                        padding: const EdgeInsets.all(
                                            8.0), // Padding inside the reply container
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  Colors.grey), // Border color
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Rounded corners
                                        ),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Reply', // Placeholder text for reply field
                                                  border: InputBorder
                                                      .none, // No border for text field
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed:
                                                  () {}, // Handle reply button press
                                              icon: const Icon(Icons
                                                  .send), // Reply button icon
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Padding around the new comment field
                  child: Container(
                    padding: const EdgeInsets.all(
                        8.0), // Padding inside the container
                    decoration: BoxDecoration(
                      border: Border.all(
                        // Border color
                        color: const Color.fromRGBO(217, 217, 217, 1),
                        width: 1.0,
                      ),
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller:
                                _newCommentController, // Controller to manage new comment input
                            decoration: const InputDecoration(
                              hintText:
                                  'Add new comment', // Placeholder text for new comment field
                              border:
                                  InputBorder.none, // No border for text field
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_newCommentController.text.isNotEmpty) {
                                _comments.add(_newCommentController
                                    .text); // Add new comment to the list
                                _newCommentController
                                    .clear(); // Clear the text field
                              }
                            });
                          },
                          icon: const Icon(Icons.send), // Send button icon
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
