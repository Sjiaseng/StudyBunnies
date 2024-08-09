import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';

class TopSnackBar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final double paddingHorizontal;
  final double paddingVertical;
  final double width;
  final double height;
  final double borderRadius; 

  const TopSnackBar({
    Key? key,
    required this.message,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.paddingHorizontal = 4.0, // Use Sizer for padding
    this.paddingVertical = 2.0, // Use Sizer for padding
    this.width = 80.0, // Use Sizer for width (in percentage)
    this.height = 8.0, // Use Sizer for height (in percentage)
    this.borderRadius = 8.0, // Default border radius
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width.w, // Use Sizer for width
        height: height.h, // Use Sizer for height
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius.w), // Circular border
        ),
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal.w, // Use Sizer for padding
          vertical: paddingVertical.h, // Use Sizer for padding
        ),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontSize: 10.sp, // Use Sizer for font size
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

void showTopSnackBar(BuildContext context, String message,
    {Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    double paddingHorizontal = 4.0, // Use Sizer for padding
    double paddingVertical = 1.0, // Use Sizer for padding
    double width = 80.0, // Use Sizer for width (in percentage)
    double height = 5.0, // Use Sizer for height (in percentage)
    double borderRadius = 2.0}) { // Add borderRadius parameter
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 2.5.h, // Use Sizer for vertical positioning
      left: 18.w, // Center horizontally based on screen width
      child: TopSnackBar(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        paddingHorizontal: paddingHorizontal,
        paddingVertical: paddingVertical,
        width: width,
        height: height,
        borderRadius: borderRadius, // Pass borderRadius parameter
      ),
    ),
  );

  // Insert the overlay entry
  overlay.insert(overlayEntry);

  // Remove the overlay entry after a delay
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
