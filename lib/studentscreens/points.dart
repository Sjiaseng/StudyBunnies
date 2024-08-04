import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';

class Points extends StatefulWidget {
  const Points({super.key});

  @override
  State<Points> createState() => _PointsState();
}

class _PointsState extends State<Points> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? userID;
  String debugMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    try {
      final userId = await _secureStorage.read(key: 'userID');
      if (mounted) {
        setState(() {
          userID = userId;
          debugMessage = 'Retrieved User ID: $userId';
        });
        if (userId != null) {
          await _checkAndSetPointsField(userId);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          debugMessage = 'Error retrieving User ID: $e';
        });
      }
    }
  }

  Future<void> _checkAndSetPointsField(String userID) async {
    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('points').doc(userID);
      DocumentSnapshot doc = await docRef.get();

      if (!doc.exists) {
        // Create the document with a default points field set to 0
        await docRef.set({'points': 0});
        setState(() {
          debugMessage =
              'Document created for User ID: $userID with default points = 0';
        });
      } else {
        // Check if the 'points' field exists and set it to 0 if it doesn't
        var data = doc.data() as Map<String, dynamic>?;
        if (data == null || !data.containsKey('points')) {
          await docRef.set({'points': 0}, SetOptions(merge: true));
          setState(() {
            debugMessage = 'Points field set to 0 for User ID: $userID';
          });
        } else {
          setState(() {
            debugMessage = 'Points field already exists for User ID: $userID';
          });
        }
      }
    } catch (e) {
      setState(() {
        debugMessage = 'Error in _checkAndSetPointsField: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar(
          "Points", "This section consists of student points.", context),
      drawer: userID == null
          ? const Drawer(child: Center(child: CircularProgressIndicator()))
          : StudentDrawer(drawercurrentindex: 6, userID: userID!),
      bottomNavigationBar: inactivenavbar(),
      body: userID == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('points')
                      .doc(userID)
                      .snapshots(),
                  builder: (context, pointsSnapshot) {
                    if (pointsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (pointsSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${pointsSnapshot.error}'));
                    }

                    if (!pointsSnapshot.hasData) {
                      return const Center(child: Text('No data found.'));
                    }

                    var pointsData =
                        pointsSnapshot.data!.data() as Map<String, dynamic>?;
                    if (pointsData == null) {
                      return const Center(
                          child: Text('Document data is null.'));
                    }

                    int points = pointsData['points'] ?? 0;

                    return Center(
                      child: SizedBox(
                        height: 500,
                        child: Card(
                          margin: const EdgeInsets.all(16.0),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '$points',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 90, // Bolder text
                                      ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'points',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w200,
                                        fontSize: 40, // Bolder text
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Display debug message below the points section
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Text(
                //     'Debug Info: $debugMessage',
                //     style: const TextStyle(color: Colors.red),
                //   ),
                // ),
              ],
            ),
    );
  }
}
