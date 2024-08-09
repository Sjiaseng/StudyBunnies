import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/teacherwidgets/appbar.dart';
import 'package:studybunnies/teacherwidgets/bottomnav.dart';
import 'package:studybunnies/teacherwidgets/drawer.dart';
import 'package:studybunnies/teacherscreens/result.dart';
import 'package:studybunnies/teacherscreens/submission.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String? loggedInUserId;
  String? username;
  ImageProvider profileImg = const AssetImage('images/profile.webp');
  List<Map<String, String>> classesDashboard = [];
  List<Map<String, String>> assessments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      loggedInUserId = user?.uid;
    });
    if (loggedInUserId != null) {
      await fetchUserDetails();
      await fetchClasses();
      await fetchAssessments();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(loggedInUserId)
          .get();
      setState(() {
        username = userDoc['username'] ?? 'Unknown User';
        String? imageUrl = userDoc['profile_img'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          profileImg = NetworkImage(imageUrl);
        }
      });
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> fetchClasses() async {
    if (loggedInUserId == null) return;

    try {
      // Query classes where the lecturer field contains the loggedInUserId
      QuerySnapshot classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('lecturer', arrayContains: loggedInUserId)
          .get();

      List<Map<String, String>> fetchedClasses = [];

      for (var classDoc in classSnapshot.docs) {
        String classID = classDoc.id;
        String className = classDoc['classname'];

        // Use the updated getStudentCount to get the student count
        int studentCount = await getStudentCount(classID);

        fetchedClasses.add({
          'classID': classID,
          'classname': className,
          'student': studentCount.toString(), // Convert to string
        });
      }

      setState(() {
        classesDashboard = fetchedClasses; // Update the state
      });
    } catch (e) {
      print("Error fetching classes: $e");
    }
  }

  Future<int> getStudentCount(String classID) async {
    try {
      DocumentSnapshot classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classID)
          .get();

      List<dynamic>? students = classSnapshot['student'];

      return students?.length ?? 0; // Return the count of students or 0 if null
    } catch (e) {
      print("Error fetching student count: $e");
      return 0; // Return 0 on error
    }
  }

  Future<void> fetchAssessments() async {
    try {
      QuerySnapshot assessmentSnapshot = await FirebaseFirestore.instance
          .collection('assessments')
          .where('userID', isEqualTo: loggedInUserId)
          .limit(5)
          .get();
      List<Map<String, String>> fetchedAssessments = [];
      for (var assessmentDoc in assessmentSnapshot.docs) {
        String type = assessmentDoc['type'] ?? '';
        String assessmentID = assessmentDoc['assessmentID'] ?? '';
        String classID = assessmentDoc['classID'] ?? '';
        String className = await getClassName(classID);

        // Fetch the title based on the type
        String title = '';
        if (type == 'quiz') {
          DocumentSnapshot quizDoc = await FirebaseFirestore.instance
              .collection('quiz')
              .doc(assessmentID)
              .get();
          title = quizDoc.exists
              ? quizDoc['quizTitle'] ?? 'Title not found'
              : 'Title not found';
        } else if (type == 'test') {
          DocumentSnapshot testDoc = await FirebaseFirestore.instance
              .collection('test')
              .doc(assessmentID)
              .get();
          title = testDoc.exists
              ? testDoc['testTitle'] ?? 'Title not found'
              : 'Title not found';
        }

        fetchedAssessments.add({
          'title': title,
          'type': type,
          'classID': classID,
          'className': className,
          'assessmentID': assessmentID,
        });
      }
      setState(() {
        assessments = fetchedAssessments;
      });
    } catch (e) {
      print("Error fetching assessments: $e");
    }
  }

  Future<String> getClassName(String classID) async {
    try {
      DocumentSnapshot classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classID)
          .get();
      return classDoc['classname'];
    } catch (e) {
      print("Error fetching class name: $e");
      return 'Class not found';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(61, 47, 34, 1),
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      appBar: mainappbar("Home", "This is the teacher's dashboard.", context),
      drawer: teacherDrawer(
        context,
        0,
        drawercurrentindex: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
              thumbVisibility: true,
              thickness: 6.0,
              radius: const Radius.circular(8.0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: profileImg,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            username ?? 'Teacher Username',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: const Color.fromARGB(255, 60, 58, 1),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // My Classes Section
                    const Text(
                      'My Classes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: classesDashboard.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 2.5,
                      ),
                      itemBuilder: (context, index) {
                        var classData = classesDashboard[index];
                        var classID = classData['classID']!;

                        return Card(
                          color: const Color.fromRGBO(213, 208, 176, 1),
                          margin: EdgeInsets.zero,
                          child: FutureBuilder<int>(
                            future: getStudentCount(
                                classID), // Fetch the student count
                            builder: (context, snapshot) {
                              String studentCountText;

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                studentCountText = 'Fetching student count...';
                              } else if (snapshot.hasError) {
                                studentCountText =
                                    'Error fetching student count';
                              } else if (!snapshot.hasData ||
                                  snapshot.data == 0) {
                                studentCountText = 'No students';
                              } else {
                                studentCountText = '${snapshot.data} students';
                              }

                              return ListTile(
                                title: Text(
                                  classData['classname']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(studentCountText),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                    // Quiz & Test Section
                    const Text(
                      'Recent Quiz & Test',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: assessments.length,
                      itemBuilder: (context, index) {
                        var assessment = assessments[index];

                        Color cardColor = assessment['type'] == 'quiz'
                            ? const Color.fromARGB(255, 243, 230, 176)
                            : const Color.fromARGB(255, 204, 230, 225);
                        String buttonText = assessment['type'] == 'quiz'
                            ? 'View Results'
                            : 'View Submissions';

                        String assessmentID = assessment['assessmentID'] ?? '';
                        String type = assessment['type'] ?? '';
                        String className = assessment['className'] ?? '';
                        String title = assessment['title'] ?? '';

                        return Card(
                          color: cardColor,
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: ListTile(
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$className  ',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(61, 47, 34, 1),
                                      ),
                                    ),
                                    TextSpan(
                                      text: type == 'quiz'
                                          ? '(Quiz)  '
                                          : '(Test)  ',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(61, 47, 34, 1),
                                      ),
                                    ),
                                    TextSpan(
                                      text: title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromRGBO(61, 47, 34, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color.fromRGBO(
                                      61, 47, 34, 1), // button text color
                                  backgroundColor: const Color.fromARGB(255,
                                      172, 130, 103), // button background color
                                ),
                                onPressed: () {
                                  if (assessmentID.isNotEmpty &&
                                      type.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => type == 'quiz'
                                            ? Result(assessmentID: assessmentID)
                                            : Submission(
                                                assessmentID: assessmentID),
                                      ),
                                    );
                                  } else {
                                    // Handle cases where assessmentID or type might be missing
                                    print('Error: Missing assessmentID or type');
                                  }
                                },
                                child: Text(
                                  buttonText,
                                  style: const TextStyle(
                                    color: Colors.white, // button text color
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: navbar(0),
    );
  }
}
