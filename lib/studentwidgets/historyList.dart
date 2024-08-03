import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget historyList() {
  return Expanded(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: ListView.builder(
        itemCount: 10, // Adjust to match the actual number of items
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
                            image: AssetImage('images/exchanged_gift_image.png'), // Replace with actual gift image
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
                            'Gift Name: Gift Name Here', // Replace with actual gift name
                            style: TextStyle(
                              fontSize: 9.sp, // Same font size as redeem time
                              color: const Color.fromRGBO(116, 116, 116, 1), // Same color as redeem time
                            ),
                          ),
                          SizedBox(height: 1.5.h), // Reduced spacing
                          Text(
                            'Redeem Time: 12/01/2024 11:01:33', // Replace with actual redeem time
                            style: TextStyle(
                              fontSize: 9.sp, // Same font size as gift name
                              color: const Color.fromRGBO(116, 116, 116, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 12.h, // Adjust this value to move the button higher
                  left: 34.5.w, // Adjust as needed
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
                  top: 12.h, // Adjust this value to move the button higher
                  left: 75.w, // Adjust as needed
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
                      ),
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
