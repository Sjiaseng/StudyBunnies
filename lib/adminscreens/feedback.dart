import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';

class Feedbacklist extends StatefulWidget {
  const Feedbacklist({Key? key}) : super(key: key);

  @override
  State<Feedbacklist> createState() => _FeedbacklistState();
}

class _FeedbacklistState extends State<Feedbacklist> {
  List<bool> selectedFilters = [true, false, false];
  TextEditingController mycontroller = TextEditingController();

  void focusButton(int index) {
    setState(() {
      for (int i = 0; i < selectedFilters.length; i++) {
        selectedFilters[i] = i == index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar(
          "Feedback", "This section consists of feedback retrieved from teachers and students.", context),
      drawer: adminDrawer(context, 5),
      bottomNavigationBar: inactivenavbar(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 0),
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
                    'Latest',
                    style: TextStyle(
                      fontWeight: selectedFilters[0] ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    'Oldest',
                    style: TextStyle(
                      fontWeight: selectedFilters[1] ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    'Favourite',
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
                        // Implement search logic here
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      margin: EdgeInsets.only(bottom: 1.5.h),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(3.w),
                        highlightColor: Colors.grey,
                        onTap: () {
                          print('Tapped on Feedback');
                        },
                        child: Container(
                          height: 17.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
                            borderRadius: BorderRadius.circular(3.w),
                            color: const Color.fromRGBO(217, 217, 217, 1),
                          ),
                          padding: EdgeInsets.only(left: 3.w, top: 1.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 2.w),
                                  child: const Text("19/11/2004"),
                                ), 
                              ),

                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 3.8.w,
                                  backgroundColor: Colors.grey,
                                ),

                                SizedBox(width: 3.w),

                                SizedBox(
                                  width: 72.w,
                                  child:Text(
                                  "username", maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                    overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )

                              ]

                            ),


                            SizedBox(height: 1.h),

                            SizedBox(
                              width: 75.w,
                              height: 5.h,
                              child: Text("Lorem Ipsumaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", maxLines: 2,
                              style:TextStyle (
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black,
                                fontSize: 10.sp,
                                ),
                              
                              )
                            ),

                            Padding(
                              padding: EdgeInsets.only(right: 3.w),
                              child: Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.star,
                              size: 18.sp,
                              
                              ),
                            ),
                            ),
                            ],
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
    );
  }
}
