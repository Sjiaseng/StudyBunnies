import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentscreens/classdetails.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/giftcatalogue.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Classlist extends StatefulWidget {
  const Classlist({super.key});

  @override
  State<Classlist> createState() => _ClasslistState();
}

class _ClasslistState extends State<Classlist> {
  final TextEditingController _searchController = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  List<String> _classes = [];
  List<String> _filteredClasses = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterClasses);
    _fetchClasses(); // Load classes from Firestore
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
          : _classes.where((className) => className.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _fetchClasses() async {
    final userID = await storage.read(key: 'userID');

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
      } else {
        print('Classes found for userID $userID: ${snapshot.docs.length}');
        setState(() {
          _classes = snapshot.docs.map((doc) {
            final classname = doc['classname'] as String;
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

  Future<String> _fetchClassID(String className) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('classname', isEqualTo: className)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id; // Or the field that holds classID
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
        appBar: mainappbar("Classes",
            "This interface will display the list of classes.", context),
        bottomNavigationBar: navbar(3),
        drawer: StudentDrawer(drawercurrentindex: 3, userID: 'userID'),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Classes',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredClasses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromRGBO(217, 217, 217, 1),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: const Color.fromRGBO(241, 241, 241, 1),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(child: Text(_filteredClasses[index])),
                                const SizedBox(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    value: 0.7,
                                    backgroundColor: Colors.white,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromRGBO(195, 154, 28, 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              final classID = await _fetchClassID(_filteredClasses[index]);

                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  duration: const Duration(milliseconds: 305),
                                  child: Classdetails(
                                    className: _filteredClasses[index],
                                    classID: classID,
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
