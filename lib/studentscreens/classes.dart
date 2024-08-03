import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentscreens/classdetails.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/giftcatalogue.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class Classlist extends StatefulWidget {
  const Classlist({super.key});

  @override
  State<Classlist> createState() => _ClasslistState();
}

class _ClasslistState extends State<Classlist> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _classes =
      List<String>.generate(10, (index) => 'Class ${index + 1}');
  List<String> _filteredClasses = [];

  @override
  void initState() {
    super.initState();
    _filteredClasses = List.from(_classes);
    _searchController.addListener(_filterClasses);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClasses);
    _searchController.dispose();
    super.dispose();
  }

  void _filterClasses() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredClasses = List.from(_classes);
      });
    } else {
      setState(() {
        _filteredClasses = _classes
            .where((className) => className.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Swiping in right direction.
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
        // Swiping in left direction.
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
        drawer: studentDrawer(context, 3),
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
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4.0, // Space between cards
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(217, 217, 217, 1),
                          width: 1.0, // Border color and width
                        ),
                        borderRadius:
                            BorderRadius.circular(8.0), // Corner radius
                      ),
                      child: Card(
                        margin: EdgeInsets.zero, // Remove default margin
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Corner radius for the Card
                        ),
                        color: const Color.fromRGBO(241, 241, 241, 1),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(child: Text(_filteredClasses[index])),
                              const SizedBox(
                                width: 100,
                                child: LinearProgressIndicator(
                                  value: 0.7, // Example progress value
                                  backgroundColor: Colors
                                      .white, // Background color of progress bar
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromRGBO(195, 154, 28,1), // Color of progress bar
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                duration: const Duration(milliseconds: 305),
                                child: Classdetails(
                                    className: _filteredClasses[index]),
                              ),
                            );
                          },
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
