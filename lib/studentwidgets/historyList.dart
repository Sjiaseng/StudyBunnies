import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Widget historyList() {
  final storage = FlutterSecureStorage();

  return Expanded(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: FutureBuilder<String?>(
        future: storage.read(key: 'userID'), // Retrieve the userID from secure storage
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User ID not found.'));
          }

          final userID = snapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('giftshistory')
                .where('userID', isEqualTo: userID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No redeemed gifts.'));
              }

              final giftHistories = snapshot.data!.docs;

              return ListView.builder(
                itemCount: giftHistories.length,
                itemBuilder: (context, index) {
                  final giftHistory = giftHistories[index].data() as Map<String, dynamic>;
                  final giftID = giftHistory['giftID'] as String;
                  final status = giftHistory['status'] as int; // Assuming 'status' is an int field
                  
                  // Fetch gift details including image URL
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('gifts').doc(giftID).get(),
                    builder: (context, giftSnapshot) {
                      if (giftSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!giftSnapshot.hasData || !giftSnapshot.data!.exists) {
                        return const Center(child: Text('Gift details not found.'));
                      }

                      final giftData = giftSnapshot.data!.data() as Map<String, dynamic>;
                      final giftImage = giftData['gift_image'] as String?; // Assuming the image URL is stored in 'gift_image'

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
                                      image: giftImage != null
                                          ? DecorationImage(
                                              image: NetworkImage(giftImage),
                                              fit: BoxFit.contain, // Ensures the entire image is visible
                                            )
                                          : const DecorationImage(
                                              image: AssetImage('images/exchanged_gift_image.png'), // Placeholder image
                                              fit: BoxFit.contain,
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
                                        'Gift ID: ${giftID}', // Display giftID as placeholder
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: const Color.fromRGBO(116, 116, 116, 1),
                                        ),
                                      ),
                                      SizedBox(height: 1.5.h),
                                      Text(
                                        'Echange Date: ${giftHistory['requestdate'].toDate().toLocal().toString()}', // Format date as needed
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: const Color.fromRGBO(116, 116, 116, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 1.h, // Adjust this value to move the button higher or lower
                              left: 37.5.w, // Center the button horizontally
                              child: SizedBox(
                                width: 45.w, // Adjust width as needed
                                child: ElevatedButton(
                                  onPressed: status == 0
                                      ? () {
                                          // Define your redeem action here if needed
                                        }
                                      : null, // Disable button if already redeemed
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 1.h),
                                    backgroundColor: status == 0
                                        ? const Color.fromRGBO(116, 116, 116, 1)
                                        : Colors.grey, // Change color if redeemed
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    status == 0 ? 'Not Redeemed' : 'Redeemed',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    ),
  );
}
