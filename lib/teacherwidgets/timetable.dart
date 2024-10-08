import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget Timetableheader(String mydate) {
  return Container(
    margin: EdgeInsets.only(bottom: 2.h),
    width: double.infinity,
    height: 5.h,
    decoration: BoxDecoration(
      color: const Color.fromRGBO(217, 217, 217, 1),
      border:
          Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
      borderRadius: BorderRadius.circular(8.0), // Added borderRadius
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
          horizontal:
              5.w), // Added padding to avoid text being too close to the border
      child: Align(
        alignment: Alignment.centerLeft, // Align text to the left
        child: Text(
          mydate,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    ),
  );
}

Widget Timetablecontent(BuildContext context, String courseTitle, String venue,
    String timestart, String timeend) {
  return Container(
    width: double.infinity,
    height: 15.h,
    margin: EdgeInsets.only(bottom: 1.h),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(241, 241, 241, 1),
      border:
          Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Padding(
      padding: EdgeInsets.only(
          left: 5.w, right: 5.w), // Adjusted padding for the whole content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment
            .start, // Ensures all children are aligned to the left
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Text(
              courseTitle,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14.sp,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Icon(
                  Icons.location_on,
                  size: 14.sp,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.h, left: 1.w),
                child: Text(
                  venue,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Icon(
                  Icons.timelapse,
                  size: 14.sp,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.h, left: 1.w),
                child: Text(
                  '$timestart - $timeend',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
