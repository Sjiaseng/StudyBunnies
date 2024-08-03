import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybunnies/adminscreens/adminsubpage/addclass.dart';
import 'package:studybunnies/adminscreens/adminsubpage/classinner.dart';
import 'package:studybunnies/adminscreens/dashboard.dart';
import 'package:studybunnies/adminscreens/giftcatalogue.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
import 'package:sizer/sizer.dart';

class Classlist extends StatefulWidget {
  const Classlist({super.key});

  @override
  State<Classlist> createState() => _ClasslistState();
}

class _ClasslistState extends State<Classlist> {
  List<bool> selectedFilters = [true, false, false];
  TextEditingController mycontroller = TextEditingController();
  String searchQuery = '';

  void focusButton(int index) {
    setState(() {
      for (int i = 0; i < selectedFilters.length; i++) {
        selectedFilters[i] = i == index;
      }
    });
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
              child: const AdminDashboard(),
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
        appBar: mainappbar(
          "Classes",
          "This interface will display the list of classes generated by Admin.",
          context,
        ),
        bottomNavigationBar: navbar(3),
        drawer: adminDrawer(context, 2),
        body: Padding(
          padding: EdgeInsets.only(left: 5.w, top: 1.5.h, right: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToggleButtons(
                textStyle: const TextStyle(fontFamily: 'Roboto'),
                constraints: BoxConstraints(minWidth: 2.w, minHeight: 3.h),
                isSelected: selectedFilters,
                borderRadius: BorderRadius.circular(2.w),
                onPressed: focusButton,
                selectedColor: Colors.black,
                fillColor: Colors.grey,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontWeight: selectedFilters[0] ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Text(
                      'Ascending',
                      style: TextStyle(
                        fontWeight: selectedFilters[1] ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Text(
                      'Descending',
                      style: TextStyle(
                        fontWeight: selectedFilters[2] ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.all(1.w),
                width: 90.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 2.0.w),
                    const Icon(Icons.search),
                    SizedBox(width: 2.0.w),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        controller: mycontroller,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('classes').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<DocumentSnapshot> classes = snapshot.data!.docs;

                    if (selectedFilters[1]) {
                      classes.sort((a, b) => a['classname'].compareTo(b['classname']));
                    } else if (selectedFilters[2]) {
                      classes.sort((a, b) => b['classname'].compareTo(a['classname']));
                    }

                    if (searchQuery.isNotEmpty) {
                      classes = classes.where((doc) {
                        return doc['classname'].toString().toLowerCase().contains(searchQuery);
                      }).toList();
                    }

                    if (classes.isEmpty) {
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/norecord.png', 
                            ),
                          ],
                        ),
                      );
                  }


                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: classes.length,
                      itemBuilder: (BuildContext context, int index) {
                        var classData = classes[index];
                        var classID = classData.id;  // Get the classID from the document ID
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                duration: const Duration(milliseconds: 305),
                                child: Classinner(classID: classID),
                              ),
                            );
                          },
                          child: Container(
                            height: 10.h,
                            margin: EdgeInsets.only(bottom: 2.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Container(
                              width: 90.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: const Color.fromRGBO(217, 217, 217, 1),
                              ),
                              padding: EdgeInsets.all(2.w),
                              child: Row(
                                children: [
                                  SizedBox(width: 2.w),
                                  Container(
                                    width: 15.w,
                                    height: 15.w,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(classData['class_img']),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0), // Optional: rounded corners
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 1.h),
                                        child: SizedBox(
                                          width: 60.w,
                                          child: Text(
                                            classData['classname'],
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      SizedBox(
                                        width: 60.w,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.people_alt_sharp,
                                              size: 11.sp,
                                              color: const Color.fromRGBO(116, 116, 116, 1),
                                            ),
                                            SizedBox(width: 3.w),
                                            Text(
                                              'Total Students: 0',
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10.sp,
                                                color: const Color.fromRGBO(116, 116, 116, 1),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                duration: const Duration(milliseconds: 305),
                child: const Addclass(),
              ),
            );
          },
          backgroundColor: const Color.fromARGB(255, 100, 30, 30),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
