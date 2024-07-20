import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';



Widget buildHistoryListView() {
  return Expanded(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(217, 217, 217, 1),
              border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 5.w, bottom: 0.2.h),
                      child: Container(
                        width: 25.w,
                        height: 18.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: const DecorationImage(
                            image: AssetImage('images/profile.webp'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Date: 11/01/2024 11:33:22',
                            style: TextStyle(
                              color: const Color.fromRGBO(116, 116, 116, 1),
                              fontFamily: 'Roboto',
                              fontSize: 8.sp,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Mohammad Ali',
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Redeem Time: 12/01/2024 11:01:33',
                            style: TextStyle(
                              fontSize: 9.sp,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Admin Name: Hutan Abc',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 13.h,
                  left: 34.5.w, 
                  child: SizedBox(
                    width: 38.w,
                    child: ElevatedButton(
                      onPressed: () {
                        // Define your onPressed function here
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.h), 
                        backgroundColor: const Color.fromRGBO(116, 116, 116, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Redeem',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 13.h,
                  left: 75.w, // Adjust the top position as needed
                   // Adjust the right position as needed
                  child: SizedBox(
                    width: 10.w,
                    child: ElevatedButton(
                      onPressed: () {
                        // Define your onPressed function here
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.h), 
                        backgroundColor: const Color.fromRGBO(116, 116, 116, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Icon(Icons.delete,
                        color: Colors.white,
                      )
                    ),
                  ),
                ),

              ],
            ),
          );
        },
      ),
    ),
  );
}