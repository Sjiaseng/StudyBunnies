import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:studybunnies/studentmodels/exchange_gift.dart';

Widget giftGrid() {
  return Expanded(
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('gifts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/norecord.png'),
            ],
          );
        }
        final gifts = snapshot.data!.docs;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            mainAxisExtent: 37.h,
            crossAxisSpacing: 5.w,
            mainAxisSpacing: 2.h,
          ),
          itemCount: gifts.length,
          itemBuilder: (context, index) {
            var gift = gifts[index].data() as Map<String, dynamic>;
            String giftID = gifts[index].id; // Accessing the document ID

            return ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color.fromRGBO(195, 172, 151, 1),
                    padding: EdgeInsets.only(left: 4.w, top: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36.w,
                          height: 15.h,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(gift['gift_image']),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        SizedBox(
                          width: 30.w,
                          child: Text(
                            gift['giftName'] ?? 'Gift Name',
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              fontFamily: 'Times New Roman'
                            ),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        SizedBox(
                          width: 30.w,
                          child: Text(
                            gift['description'] ?? 'Description Here...',
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 10.sp,
                              overflow: TextOverflow.ellipsis,
                              color: const Color.fromRGBO(116, 116, 116, 1),
                              fontFamily: 'Times New Roman'
                            ),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        SizedBox(height: 1.h),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 1.5.w, 
                    bottom: 1.h, 
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w), 
                      child: Row(
                        children: [
                          Text(
                            '${gift['points_required']} pts.',
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 3.5.w), // Reduced spacing to move button closer to points
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  duration: const Duration(milliseconds: 305),
                                  child: ExchangeGift(giftID: giftID), 
                                ),
                              );
                            },
                            child: Container(
                              width: 18.w, 
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(131,105,83,1),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Exchange',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Times New Roman',
                                  ),
                                ),
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
        );
      },
    ),
  );
}
