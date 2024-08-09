import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';


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

  // Initialize the user ID and check/set points field
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
    DocumentReference docRef = FirebaseFirestore.instance.collection('points').doc(userID);
    DocumentSnapshot doc = await docRef.get();

    if (!doc.exists) {
      // Create the document with a default points field set to 0 and include the studentID
      await docRef.set({'points': 0, 'studentID': userID});
      setState(() {
        debugMessage = 'Document created for User ID: $userID with default points = 0 and studentID set.';
      });
    } else {
      var data = doc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('points')) {
        // If the 'points' field doesn't exist, set it to 0 and also ensure the studentID is set
        await docRef.set({'points': 0, 'studentID': userID}, SetOptions(merge: true));
        setState(() {
          debugMessage = 'Points field set to 0 for User ID: $userID and studentID set.';
        });
      } else {
        // If the document exists and has the points field, ensure the studentID is also set
        if (!data.containsKey('studentID')) {
          await docRef.set({'studentID': userID}, SetOptions(merge: true));
          setState(() {
            debugMessage = 'StudentID set for User ID: $userID.';
          });
        } else {
          setState(() {
            debugMessage = 'Points and studentID fields already exist for User ID: $userID';
          });
        }
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
      appBar: mainappbar("Points", "This section consists of student points.", context),
      drawer: _buildDrawer(),
      bottomNavigationBar: inactivenavbar(),
      body: _buildBody(),
    );
  }

  // Build the drawer based on userID
  Widget _buildDrawer() {
    return userID == null
        ? const Drawer(child: Center(child: CircularProgressIndicator()))
        : StudentDrawer(drawercurrentindex: 6, userID: userID!);
  }

  // Build the main body of the Points page
  Widget _buildBody() {
    return userID == null
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPointsStreamBuilder(),
              // Uncomment for debugging
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Text(
              //     'Debug Info: $debugMessage',
              //     style: const TextStyle(color: Colors.red),
              //   ),
              // ),
            ],
          );
  }

  // Build the StreamBuilder to fetch and display points
  Widget _buildPointsStreamBuilder() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('points')
          .doc(userID)
          .snapshots(),
      builder: (context, pointsSnapshot) {
        if (pointsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (pointsSnapshot.hasError) {
          return Center(child: Text('Error: ${pointsSnapshot.error}'));
        }

        if (!pointsSnapshot.hasData) {
          return const Center(child: Text('No data found.'));
        }

        var pointsData = pointsSnapshot.data!.data() as Map<String, dynamic>?;
        if (pointsData == null) {
          return const Center(child: Text('Document data is null.'));
        }

        int points = pointsData['points'] ?? 0;
        return _buildPointsCard(points);
      },
    );
  }

// Build the card to display points
Widget _buildPointsCard(int points) {
  int level = (points ~/ 100) + 1; // Calculate level
  int pointsForCurrentLevel = points % 100; // Points within the current level
  double progress = pointsForCurrentLevel / 100; // Progress within the level

  return Center(
    child: SizedBox(
      height: 500, // Set a fixed height for the card
      width: 350,  // Set a fixed width for the card
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        margin: const EdgeInsets.all(16.0),
        elevation: 8.0, // Increased elevation for a stronger shadow
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 232, 190, 182), Color.fromARGB(255, 109, 23, 5)], // Gradient background
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$points',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 80,
                      color: Colors.white, // White text color for contrast
                    ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'points',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      fontSize: 30,
                      color: Colors.white70, // Lighter white for subtext
                    ),
              ),
              const SizedBox(height: 30.0),
              Container(
                height: 10.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners for the progress bar
                  color: Colors.white24, // Background color for progress bar
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners for the progress indicator
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10.0,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white, // Progress bar color
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Level $level',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                      color: Colors.white, // White text color for level
                    ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
