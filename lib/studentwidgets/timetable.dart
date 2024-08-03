import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// Widget for displaying the header of the timetable: shows date
Widget timetableHeader(String mydate) {
  return Container(
    margin: EdgeInsets.only(
        bottom: 2.h), // Adds margin below the header for spacing
    width: double.infinity, // Full width of the container
    height: 5.h, // Sets the height of the container to 5% of the screen height
    decoration: BoxDecoration(
      color: const Color.fromRGBO(
          217, 217, 217, 1), // Background color of the header
      border: Border.all(
          color: const Color.fromRGBO(217, 217, 217, 1),
          width: 1.0), // Border with the same color and 1.0 width
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
          horizontal:
              5.w), // Added padding to avoid text being too close to the border
      child: Align(
        alignment: Alignment.centerLeft, // Align date text to the left
        child: Text(
          mydate, // The date string to display
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

// Widget for displaying the content: course details
Widget timetableContent(BuildContext context, String courseTitle,
    String lecturername, String venue, String timestart, String timeend) {
  return Container(
    width: double.infinity,
    height: 20.h,
    margin: EdgeInsets.only(bottom: 1.h),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(241, 241, 241, 1),
      border:
          Border.all(color: const Color.fromRGBO(217, 217, 217, 1), width: 1.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Padding(
      padding: EdgeInsets.only(
          left: 5.w, right: 5.w), // Padding on the left and right sides
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Aligns children to the left
        children: [
          // Displays the course title
          Padding(
            padding: EdgeInsets.only(
                top: 2.h), // Padding from the top of the container
            child: Text(
              courseTitle, // Course title string
              maxLines: 1, // Limits the text to a single line
              style: TextStyle(
                fontSize: 14.sp, // Font size scaled according to screen size
                overflow: TextOverflow.ellipsis, // Adds '...' if text overflows
                fontWeight: FontWeight.bold, // Bold font weight
                fontFamily: 'Roboto', // Custom font family
              ),
            ),
          ),
          // Displays the lecturer's name
          Padding(
            padding:
                EdgeInsets.only(top: 1.h), // Padding from the previous text
            child: Text(
              lecturername, // Lecturer's name string
              maxLines: 1, // Limits the text to a single line
              style: TextStyle(
                fontSize: 12.sp, // Font size scaled according to screen size
                overflow: TextOverflow.ellipsis, // Adds '...' if text overflows
                fontFamily: 'Roboto', // Custom font family
              ),
            ),
          ),
          // Displays the venue with an icon
          Row(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 1.h), // Padding from the previous text
                child: Icon(
                  Icons.location_on, // Location icon
                  size: 14.sp, // Icon size scaled according to screen size
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 1.h,
                    left: 1.w), // Padding from the icon and previous text
                child: Text(
                  venue, // Venue string
                  style: TextStyle(
                    fontSize:
                        12.sp, // Font size scaled according to screen size
                    fontFamily: 'Roboto', // Custom font family
                  ),
                ),
              ),
            ],
          ),
          // Displays the time with an icon
          Row(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 1.h), // Padding from the previous text
                child: Icon(
                  Icons.timelapse, // Clock icon
                  size: 14.sp, // Icon size scaled according to screen size
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 1.h,
                    left: 1.w), // Padding from the icon and previous text
                child: Text(
                  '$timestart - $timeend', // Time range string
                  style: TextStyle(
                    fontSize:
                        12.sp, // Font size scaled according to screen size
                    fontFamily: 'Roboto', // Custom font family
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
