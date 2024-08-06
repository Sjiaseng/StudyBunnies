import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For controlling system UI overlay styles
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentscreens/classes.dart';
import 'package:studybunnies/studentscreens/timetable.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? userID;
  String userName = ''; // Initialize as empty string
  String userProfilePicUrl = ''; // Initialize as empty string

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
        });
        if (userId != null) {
          await _fetchUserProfile(userId);
        }
      }
    } catch (e) {
      print('Error initializing user ID: $e');
    }
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        setState(() {
          userName = userData['username'] ?? 'Student';
          userProfilePicUrl = userData['profile_img'] ??
              'assets/images/placeholder.png'; // Use a local image if URL is empty or invalid
        });
        print('Fetched username: $userName');
        print('Fetched profile_img: $userProfilePicUrl');
      } else {
        setState(() {
          userName = 'Student';
          userProfilePicUrl =
              'assets/images/placeholder.png'; // Local placeholder
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        userName = 'Student';
        userProfilePicUrl =
            'assets/images/placeholder.png'; // Local placeholder
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Set status bar color to black
      statusBarBrightness:
          Brightness.dark, // Set status bar text/icons to dark mode
    ));

    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: const Timetablelist(),
            ),
          );
        }
        if (details.delta.dx < -25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 305),
              child: const Classlist(),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: mainappbar("Home", "This is students dashboard.", context),
        drawer: StudentDrawer(drawercurrentindex: 0, userID: userID ?? ''),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Welcome back, $userName!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Times New Roman',
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              userProfilePicUrl.startsWith('http') ||
                                      userProfilePicUrl.startsWith('https')
                                  ? NetworkImage(userProfilePicUrl)
                                  : FileImage(File(userProfilePicUrl))
                                      as ImageProvider,
                          radius: 50.0,
                          backgroundColor: Colors.grey[
                              500], // Optional: background color if the image fails to load
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          userName,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Student ID: ${userID ?? 'N/A'}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                // Add other widgets or content here
              ],
            ),
          ),
        ),
        bottomNavigationBar: navbar(2),
      ),
    );
  }
}
