import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:studybunnies/adminscreens/adminsubpage/editgift.dart';


Widget buildGiftsGridView() {
  return Expanded(
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisExtent: 37.h,
        crossAxisSpacing: 5.w,
        mainAxisSpacing: 2.h,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: const Color.fromRGBO(217, 217, 217, 1),
                padding: EdgeInsets.only(left: 4.w, top: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36.w,
                      height: 15.h,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('images/profile.webp'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(
                      width: 30.w,
                      child: Text(
                        'Gift Name',
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SizedBox(
                      width: 30.w,
                      child: Text(
                        'Description Here...',
                        maxLines: 2,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 10.sp,
                          overflow: TextOverflow.ellipsis,
                          color: const Color.fromRGBO(116, 116, 116, 1),
                        ),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Amount',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color.fromRGBO(116, 116, 116, 1),
                      ),
                    ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
              Positioned(
                left: 0.w,
                top: 30.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 25.w,
                        child: Text(
                          '50 pts.',
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context, PageTransition(
                            type: PageTransitionType.rightToLeft,
                              duration: const Duration(milliseconds: 305),  
                              child: const Editgift(),  
                            ),);                       
                        },
                        child: Container(
                            width: 10.w,
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.black, width: 1.0),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 15.sp,
                            ),
                          ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}