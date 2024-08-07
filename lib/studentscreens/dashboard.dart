// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentscreens/notes.dart';
import 'package:studybunnies/studentwidgets/appbar.dart';
import 'package:studybunnies/studentscreens/classes.dart';
import 'package:studybunnies/studentwidgets/bottomnav.dart';
import 'package:studybunnies/studentwidgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../authentication/session.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final Session _session = Session(); // Create an instance of Session

  String? userID;
  String userName = '';
  String userProfilePicUrl = '';
  String contactNumber = '';
  String country = '';
  String email = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _initializeUserId(); // Initialize user ID on widget creation
  }

  // Method to initialize user ID
  Future<void> _initializeUserId() async {
    try {
      final userId = await _session.getUserId(); // Use Session class to get userID
      if (mounted) {
        setState(() {
          userID = userId;
        });
        if (userId != null) {
          await _fetchUserProfile(userId); // Fetch user profile if user ID is available
        }
      }
    } catch (e) {
      print('Error initializing user ID: $e');
    }
  }

  // Method to fetch user profile from Firestore
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
          userProfilePicUrl = userData['profile_img'] ?? 'assets/images/placeholder.png';
          contactNumber = userData['contactnumber'] ?? '';
          country = userData['country'] ?? '';
          email = userData['email'] ?? '';
          role = userData['role'] ?? '';
          userID = userData['userID'] ?? userId;
        });
        // Print fetched data
        print('Fetched username: $userName');
        print('Fetched profile_img: $userProfilePicUrl');
        print('Fetched contact number: $contactNumber');
        print('Fetched country: $country');
        print('Fetched email: $email');
        print('Fetched role: $role');
        print('Fetched userID: $userID');
      } else {
        // Set default values if user document does not exist
        setState(() {
          userName = 'Student';
          userProfilePicUrl = 'assets/images/placeholder.png';
          contactNumber = 'Kindly update your information from profile page';
          country = 'Kindly update your information from profile page';
          email = 'Kindly update your information from profile page';
          role = 'Kindly update your information from profile page';
          userID = userId;
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      // Set default values in case of an error
      setState(() {
        userName = 'Student';
        userProfilePicUrl = 'assets/images/placeholder.png';
        contactNumber = 'Kindly update your information from profile page';
        country = 'Kindly update your information from profile page';
        email = 'Kindly update your information from profile page';
        role = 'Kindly update your information from profile page';
        userID = userId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Detect swipe gestures for navigation
      onPanUpdate: (details) {
        if (details.delta.dx > 25) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              duration: const Duration(milliseconds: 305),
              child: Notelist(),
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
                // Welcome message
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Welcome back, $userName!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Times New Roman',
                          color: const Color.fromRGBO(61, 47, 34, 1),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16.0),
                // Card displaying user profile
                Center(
                  child: Card(
                    color: const Color.fromRGBO(220, 220, 220, 1),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // User profile picture
                          CircleAvatar(
                            backgroundImage: userProfilePicUrl.startsWith('http') ||
                                    userProfilePicUrl.startsWith('https')
                                ? NetworkImage(userProfilePicUrl)
                                : FileImage(File(userProfilePicUrl)) as ImageProvider,
                            radius: 50.0,
                            backgroundColor: Colors.grey[500],
                          ),
                          const SizedBox(height: 16.0),
                          // User role
                          Text(
                            role,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Georgia',
                                  color: const Color.fromRGBO(61, 47, 34, 1),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          // Padding to increase spacing
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email row
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      color: Color.fromRGBO(61, 47, 34, 1),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontSize: 20.0,
                                              fontFamily: 'Courier',
                                              color: const Color.fromRGBO(113, 118, 121, 1),
                                            ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                // Contact number row
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      color: Color.fromRGBO(61, 47, 34, 1),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        contactNumber,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontSize: 20.0,
                                              fontFamily: 'Courier',
                                              color: const Color.fromRGBO(113, 118, 121, 1),
                                            ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                // Country row
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: Color.fromRGBO(61, 47, 34, 1),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        country,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontSize: 20.0,
                                              fontFamily: 'Courier',
                                              color: const Color.fromRGBO(113, 118, 121, 1),
                                            ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                // Add other widgets or content here
              ],
            ),
          ),
        ),
        bottomNavigationBar: navbar(2), // Bottom navigation bar
      ),
    );
  }
}
