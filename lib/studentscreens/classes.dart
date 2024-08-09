import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/authentication/session.dart';
import 'package:studybunnies/studentscreens/giftcatalogue.dart';
import 'package:studybunnies/studentscreens/classdetails.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class Classlist extends StatefulWidget {
  const Classlist({super.key});

  @override
  State<Classlist> createState() => _ClasslistState();
}

class _ClasslistState extends State<Classlist> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _classes = [];
  List<String> _filteredClasses = [];
  final Session session = Session(); // Instantiate Session

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterClasses);
    _fetchClasses();
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
          ? List.from(_classes)
          : _classes
              .where((className) => className.toLowerCase().contains(query))
              .toList();
    });
  }

// Fetch Classes associates with the studentID
  Future<void> _fetchClasses() async {
    final userID = await session.getUserId(); // Use the Session class

    if (userID == null) {
      print('User ID is null');
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('student', arrayContains: userID)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No classes found for userID $userID');
        setState(() {
          _classes = [];
          _filteredClasses = [];
        });
      } else {
        print('Classes found for userID $userID: ${snapshot.docs.length}');
        setState(() {
          _classes = snapshot.docs.map((doc) {
            final classname = doc['classname'] as String? ?? 'No class name';
            print('Mapping class: $classname');
            return classname;
          }).toList();
          _filteredClasses = List.from(_classes);
        });
      }
    } catch (e) {
      print('Error fetching classes: $e');
    }
  }

// Fetch classID
  Future<String> _fetchClassID(String className) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('classname', isEqualTo: className)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      } else {
        throw Exception('Class not found');
      }
    } catch (e) {
      print('Error fetching classID: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: const StudentDashboard(),
            ),
          );
        }
        if (details.delta.dx < -25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const Giftlist(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar(
          "Classes",
          "This interface will display the list of classes.",
          context,
        ),
        bottomNavigationBar: navbar(3),
        drawer: FutureBuilder<String?>(
          future: session.getUserId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            return StudentDrawer(
              drawercurrentindex: 4,
              userID: snapshot.data ?? 'guest',
            );
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                cursorColor: Colors.grey, 
                decoration: InputDecoration(
                  hintText: 'Search Classes',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              // Display Class Name
              const SizedBox(height: 16.0),
              Expanded(
                child: _filteredClasses.isEmpty
                    ? const Center(child: Text('No classes found.'))
                    : ListView.builder(
                        itemCount: _filteredClasses.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Card(
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                color: const Color.fromRGBO(195, 172, 151, 1),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        _filteredClasses[index],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown,
                                          fontFamily: 'Times New Roman',
                                        ),
                                      )),
                                    ],
                                  ),
                                  onTap: () async {
                                    final classID = await _fetchClassID(
                                        _filteredClasses[index]);
                                    final userID = await session
                                        .getUserId(); // Fetch userID

                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        duration:
                                            const Duration(milliseconds: 305),
                                        child: Classdetails(
                                          className: _filteredClasses[index],
                                          classID: classID,
                                          userID: userID ??
                                              'Unknown', // Pass userID
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
