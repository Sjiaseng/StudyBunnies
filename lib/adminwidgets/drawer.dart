import 'dart:async';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:studybunnies/adminscreens/classes.dart';
import 'package:studybunnies/adminscreens/dashboard.dart';
import 'package:studybunnies/adminscreens/faq.dart';
import 'package:studybunnies/adminscreens/feedback.dart';
import 'package:studybunnies/adminscreens/giftcatalogue.dart';
import 'package:studybunnies/adminscreens/myprofile.dart';
import 'package:studybunnies/adminscreens/timetable.dart';
import 'package:studybunnies/adminscreens/users.dart';

Widget adminDrawer(BuildContext context, int drawercurrentindex) {
  String formattedDate = DateFormat('dd-MM-yyyy (E)').format(DateTime.now());
  TextStyle selectedStyle = TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color:const Color.fromRGBO(195, 154, 29, 1));
  TextStyle normalStyle = TextStyle(fontSize: 12.sp, color: Colors.white);
  Color selectedIconColor = const Color.fromRGBO(195, 154, 29, 1); 
  Color unselectedIconColor = Colors.white; 
  Color selectedContainerColor = Colors.yellow.withOpacity(0.2);
  Color unselectedContainerColor = Colors.transparent;
  return Drawer(
    backgroundColor: const Color.fromRGBO(100, 30, 30, 1),
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(
                height: 7.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 7.w),
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 10.w,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.only(left: 7.w),
                child: Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 7.w),
                child: Text(
                  'ID: 123456789',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: 'Roboto',
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
          Column(
            children: [
              Container(
                color: drawercurrentindex == 0
                    ? selectedContainerColor
                    : unselectedContainerColor,
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 5.w), // Add padding to the text
                    child: Row( 
                      children:[
                        Icon(
                          Icons.home,
                          color: drawercurrentindex == 0 ? selectedIconColor : unselectedIconColor,
                          ),
                        const SizedBox(width:10),
                        Text(
                          'Home',
                          style: drawercurrentindex == 0 ? selectedStyle : normalStyle,
                        ),
                      ],
                    ),
                  ),
                  selected: drawercurrentindex == 0,
                  onTap: (){
                   Navigator.pop(context);
                   Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        duration: const Duration(milliseconds: 205),  
                        child: const AdminDashboard()
                      )
                    );    
                   });
                  }                
                ),
              ),
              Container(
                color: drawercurrentindex == 1
                    ? selectedContainerColor
                    : unselectedContainerColor,
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 5.w), // Add padding to the text
                    child: Row( 
                      children:[
                        Icon(
                          Icons.table_chart,
                          color: drawercurrentindex == 1 ? selectedIconColor : unselectedIconColor,
                          ),
                        const SizedBox(width:10),
                        Text(
                          'Timetable',
                          style: drawercurrentindex == 1 ? selectedStyle : normalStyle,
                        ),
                      ],
                    ),
                  ),
                  selected: drawercurrentindex == 1,
                  onTap: (){
                   Navigator.pop(context);
                   Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        duration: const Duration(milliseconds: 205),  
                        child: const Timetablelist()
                      )
                    );    
                   });
                  } 
                ),
              ),
              Container(
                color: drawercurrentindex == 2
                    ? selectedContainerColor
                    : unselectedContainerColor,
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 5.w), // Add padding to the text
                    child: Row( 
                      children:[
                        Icon(
                          Icons.class_,
                          color: drawercurrentindex == 2 ? selectedIconColor : unselectedIconColor,
                          ),
                        const SizedBox(width:10),
                        Text(
                          'Classes',
                          style: drawercurrentindex == 2 ? selectedStyle : normalStyle,
                        ),
                      ],
                    ),
                  ),
                  selected: drawercurrentindex == 2,
                  onTap: (){
                   Navigator.pop(context);
                   Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        duration: const Duration(milliseconds: 205),  
                        child: const Classlist()
                      )
                    );    
                   });
                  }   
                ),
              ),
              Container(
                color: drawercurrentindex == 3
                    ? selectedContainerColor
                    : unselectedContainerColor,
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 5.w), 
                    child: Row( 
                      children:[
                        Icon(
                          Icons.person,
                          color: drawercurrentindex == 3 ? selectedIconColor : unselectedIconColor,
                          ),
                        const SizedBox(width:10),
                        Text(
                          'Users',
                          style: drawercurrentindex == 3 ? selectedStyle : normalStyle,
                        ),
                      ],
                    ),
                  ),
                  selected: drawercurrentindex == 3,
                  onTap: (){
                   Navigator.pop(context);
                   Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        duration: const Duration(milliseconds: 205),  
                        child: const Userlist()
                      )
                    );    
                   });
                  }   
                ),
              ),
              Container(
                color: drawercurrentindex == 4
                    ? selectedContainerColor
                    : unselectedContainerColor,
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 5.w), 
                    child: Row( 
                      children:[
                        Icon(
                          Icons.card_giftcard_rounded,
                          color: drawercurrentindex == 4 ? selectedIconColor : unselectedIconColor,
                          ),
                        const SizedBox(width:10),
                        Text(
                          'Gift Catalogue',
                          style: drawercurrentindex == 4 ? selectedStyle : normalStyle,
                        ),
                      ],
                    ),
                  ),
                  selected: drawercurrentindex == 4,
                  onTap: (){
                   Navigator.pop(context);
                   Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        duration: const Duration(milliseconds: 205),  
                        child: const Giftlist()
                      )
                    );    
                   });
                  }   
                ),
              ),
              Container(
                color: drawercurrentindex == 5
                    ? selectedContainerColor
                    : unselectedContainerColor,
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 5.w), // Add padding to the text
                    child: Row( 
                      children:[
                        Icon(
                          Icons.autorenew_rounded,
                          color: drawercurrentindex == 5 ? selectedIconColor : unselectedIconColor,
                          ),
                        const SizedBox(width:10),
                        Text(
                          'Feedback',
                          style: drawercurrentindex == 5 ? selectedStyle : normalStyle,
                        ),
                      ],
                    ),
                  ),
                  selected: drawercurrentindex == 5,
                  onTap: (){
                   Navigator.pop(context);
                   Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        duration: const Duration(milliseconds: 205),  
                        child: const Feedbacklist()
                      )
                    );    
                   });
                  }                
                ),
              ),
              Container(
                color: drawercurrentindex == 6
                    ? selectedContainerColor
                    : unselectedContainerColor,
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 5.w), 
                    child: Row( 
                      children:[
                        Icon(
                          Icons.person_pin,
                          color: drawercurrentindex == 6 ? selectedIconColor : unselectedIconColor,
                          ),
                        const SizedBox(width:10),
                        Text(
                          'My Profile',
                          style: drawercurrentindex == 6 ? selectedStyle : normalStyle,
                        ),
                      ],
                    ),
                  ),
                  selected: drawercurrentindex == 6,
                  onTap: (){
                   Navigator.pop(context);
                   Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        duration: const Duration(milliseconds: 305),  
                        child: const MyProfile()
                      )
                    );    
                   });
                  }                   
                ),
              ),
              Container(
                color: drawercurrentindex == 7
                    ? selectedContainerColor
                    : unselectedContainerColor,
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 5.w), 
                    child: Row( 
                      children:[
                        Icon(
                          Icons.warning,
                          color: drawercurrentindex == 7 ? selectedIconColor : unselectedIconColor,
                          ),
                        const SizedBox(width:10),
                        Text(
                          'FAQ',
                          style: drawercurrentindex == 7 ? selectedStyle : normalStyle,
                        ),
                      ],
                    ),
                  ),
                  selected: drawercurrentindex == 7,
                  onTap: (){
                   Navigator.pop(context);
                   Timer(const Duration(milliseconds: 205), () {
                    Navigator.push(
                      context, PageTransition(
                        type: PageTransitionType.rightToLeft,
                        duration: const Duration(milliseconds: 305),  
                        child: const Faqpage()
                      )
                    );    
                   });
                  }                   
                ),
              ),
            ],
          ),
      ],
    ),
  );
}