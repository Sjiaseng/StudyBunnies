import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart'; // For page transition animation
import 'package:sizer/sizer.dart'; // For responsive sizing
import 'package:intl/intl.dart'; // For formatting data
import 'package:studybunnies/authentication/logoutscreen.dart';
import 'package:studybunnies/studentscreens/classes.dart';
import 'package:studybunnies/studentscreens/faq.dart';
import 'package:studybunnies/studentscreens/feedback.dart';
import 'package:studybunnies/studentscreens/giftcatalogue.dart';
import 'package:studybunnies/studentscreens/dashboard.dart';
import 'package:studybunnies/studentscreens/notes.dart';
import 'package:studybunnies/studentscreens/points.dart';
import 'package:studybunnies/studentscreens/quiztest.dart';
import 'package:studybunnies/studentscreens/timetable.dart';

class StudentDrawer extends StatelessWidget {
  final int drawercurrentindex;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  StudentDrawer({required this.drawercurrentindex, required String userID});

  Future<String?> _getUserId() async {
    return await _secureStorage.read(key: 'userID');
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy (E)').format(DateTime.now());

    return Drawer(
      backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
      child: Column(
        children: <Widget>[
          // StreamBuilder for the user's profile
          FutureBuilder<String?>(
            future: _getUserId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const DrawerHeader(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return DrawerHeader(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const DrawerHeader(
                  child: Center(child: Text('No user ID found')),
                );
              } else {
                String userID = snapshot.data!;
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const DrawerHeader(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return DrawerHeader(
                        child: Center(child: Text('Error: ${snapshot.error}')),
                      );
                    } else if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const DrawerHeader(
                        child: Center(child: Text('No data available')),
                      );
                    } else {
                      var userData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      String username = userData?['username'] ?? 'Unknown User';
                      String profileImg = userData?['profile_img'] ?? '';
                      return UserAccountsDrawerHeader(
                        // display the date here
                        // try not to modify other code
                        accountName: Text(
                          username,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        accountEmail: Text(
                          'ID: $userID',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: 'Roboto',
                            color: Colors.grey[600],
                          ),
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          backgroundImage: profileImg.isNotEmpty
                              ? NetworkImage(profileImg)
                              : null,
                          child: profileImg.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 10.w,
                                  color: Colors.black,
                                )
                              : null,
                        ),
                        decoration: const BoxDecoration(
                          color: const Color.fromRGBO(100, 30, 30, 1),
                        ),
                      );
                    }
                  },
                );
              }
            },
          ),
          // Expanded ListView
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  index: 0,
                  selectedIndex: drawercurrentindex,
                  destination: const StudentDashboard(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.table_chart_outlined,
                  title: 'Timetable',
                  index: 1,
                  selectedIndex: drawercurrentindex,
                  destination: const Timetablelist(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.note_outlined,
                  title: 'Notes',
                  index: 2,
                  selectedIndex: drawercurrentindex,
                  destination: const Noteslist(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.quiz,
                  title: 'Quiz/Test',
                  index: 3,
                  selectedIndex: drawercurrentindex,
                  destination: const QuizTestList(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.class_outlined,
                  title: 'Classes',
                  index: 4,
                  selectedIndex: drawercurrentindex,
                  destination: const Classlist(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.feedback_outlined,
                  title: 'Feedback',
                  index: 5,
                  selectedIndex: drawercurrentindex,
                  destination: const Feedbacklist(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.point_of_sale_outlined,
                  title: 'Points',
                  index: 6,
                  selectedIndex: drawercurrentindex,
                  destination: const Points(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.card_giftcard,
                  title: 'Gifts',
                  index: 7,
                  selectedIndex: drawercurrentindex,
                  destination: const Giftlist(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help,
                  title: 'FAQ',
                  index: 8,
                  selectedIndex: drawercurrentindex,
                  destination: const Faqpage(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  index: 9,
                  selectedIndex: drawercurrentindex,
                  destination: const Logoutscreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required int selectedIndex,
    required Widget destination,
  }) {
    Color selectedIconColor = const Color.fromRGBO(195, 154, 29, 1);
    Color unselectedIconColor = Colors.white;
    Color selectedContainerColor = Colors.yellow.withOpacity(0.2);
    Color unselectedContainerColor = Colors.transparent;

    TextStyle selectedStyle = TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
      color: selectedIconColor,
    );
    TextStyle normalStyle = TextStyle(
      fontSize: 12.sp,
      color: unselectedIconColor,
    );

    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.leftToRight,
            child: destination,
          ),
        );
      },
      child: Container(
        color: index == selectedIndex
            ? selectedContainerColor
            : unselectedContainerColor,
        child: ListTile(
          leading: Icon(
            icon,
            color: index == selectedIndex
                ? selectedIconColor
                : unselectedIconColor,
            size: 22.sp,
          ),
          title: Text(
            title,
            style: index == selectedIndex ? selectedStyle : normalStyle,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
          minLeadingWidth: 3.w,
        ),
      ),
    );
  }
}
