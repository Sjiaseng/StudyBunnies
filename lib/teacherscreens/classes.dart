import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'package:studybunnies/teacherwidgets/drawer.dart';
import 'package:studybunnies/teacherscreens/notes.dart';
import 'package:studybunnies/teacherscreens/quiztest.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Classes extends StatefulWidget {
  const Classes({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClassesState createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _classesDashboard = [];
  List<Map<String, String>> _filteredClasses = [];
  String? loggedInUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((_) {
      _searchController.addListener(_filterClasses);
      fetchClasses();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClasses);
    _searchController.dispose();
    super.dispose();
  }

  void _filterClasses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClasses = query.isEmpty
          ? List.from(_classesDashboard)
          : _classesDashboard
              .where((classData) =>
                  classData['classname']!.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      loggedInUserId = user?.uid;
    });
  }

  Future<void> fetchClasses() async {
    if (loggedInUserId == null) return;

    try {
      QuerySnapshot classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('lecturer', arrayContains: loggedInUserId)
          .get();

      List<Map<String, String>> fetchedClasses = [];

      for (var classDoc in classSnapshot.docs) {
        String classID = classDoc.id;
        String className = classDoc['classname'];

        fetchedClasses.add({
          'classID': classID,
          'classname': className,
        });
      }

      setState(() {
        _classesDashboard = fetchedClasses;
        _filteredClasses = fetchedClasses; // Initialize filtered classes
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching classes: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: mainappbar("Classes", "This is the classes screen.", context),
      drawer: teacherDrawer(context, 2, drawercurrentindex: 2),
      body: Scrollbar(
        thumbVisibility: true,
        thickness: 6.0,
        radius: const Radius.circular(8.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search classes...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const CircularProgressIndicator()
                  : _filteredClasses.isEmpty
                      ? const Text('No classes found.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _filteredClasses.map((classData) {
                            String classID = classData['classID']!;
                            String className = classData['classname']!;
                            List<String> parts = className.split(' ');
                            String upperPart =
                                parts.length > 1 ? parts[0] : className;
                            String lowerPart = parts.length > 1
                                ? parts.sublist(1).join(' ')
                                : '';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(213, 208, 176, 1),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            upperPart,
                                            style: TextStyle(
                                              color: const Color.fromRGBO(
                                                  61, 47, 34, 1),
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (lowerPart.isNotEmpty)
                                            Text(
                                              lowerPart,
                                              style: TextStyle(
                                                color: const Color.fromRGBO(
                                                    61, 47, 34, 1),
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          _ClassButton(
                                            label: 'Quiz\n& Test',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      QuizTest(
                                                    className: className,
                                                    classID: classID,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          _ClassButton(
                                            label: 'Notes',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Notes(
                                                    classID: classID,
                                                    className: className,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          }).toList(),
                        ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: navbar(2),
    );
  }
}

class _ClassButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ClassButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(172, 130, 103, 1),
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
