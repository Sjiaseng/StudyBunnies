import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExchangeGift extends StatelessWidget {
  final String giftID;

  const ExchangeGift({Key? key, required this.giftID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storage = FlutterSecureStorage();

    return AlertDialog(
      title: const Text('Exchange Gift'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you want to exchange this gift?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            try {
              // Retrieve the userID from secure storage
              final userID = await storage.read(key: 'userID');
              if (userID == null) {
                throw Exception('User ID not found');
              }

              // Get references to the Firestore collections
              final giftHistoryRef = FirebaseFirestore.instance.collection('giftshistory');
              final giftRef = FirebaseFirestore.instance.collection('gifts').doc(giftID);
              final pointsRef = FirebaseFirestore.instance.collection('points').doc(userID);

              // Use a transaction to ensure atomicity
              await FirebaseFirestore.instance.runTransaction((transaction) async {
                // Read all necessary data
                final giftDoc = await transaction.get(giftRef);
                if (!giftDoc.exists) {
                  throw Exception('Gift not found');
                }

                final pointsDoc = await transaction.get(pointsRef);
                if (!pointsDoc.exists) {
                  throw Exception('Student points not found');
                }

                // Extract data needed for calculations
                final newStockAmount = (giftDoc.data()!['stock_amount'] as int) - 1;
                if (newStockAmount < 0) {
                  throw Exception('Not enough stock');
                }

                final pointsRequired = (giftDoc.data()!['points_required'] as int);
                final currentPoints = (pointsDoc.data()!['points'] as int);
                if (currentPoints < pointsRequired) {
                  throw Exception('Not enough points');
                }

                // Perform all write operations
                transaction.update(giftRef, {
                  'stock_amount': newStockAmount,
                });

                final newPointsBalance = currentPoints - pointsRequired;
                transaction.update(pointsRef, {
                  'points': newPointsBalance,
                });

                // Add a new document to the 'giftshistory' collection
                final historyDocRef = giftHistoryRef.doc(); // Get a new document reference
                transaction.set(historyDocRef, {
                  'historyID': historyDocRef.id, // Set historyID as the document ID
                  'userID': userID,
                  'adminID': '', // Leave adminID blank
                  'requestdate': Timestamp.fromDate(DateTime.now()), // Set requestdate to the current date and time
                  'redeemdate': null, // Initialize redeemdate as null
                  'giftID': giftID,
                  'status': 0 // Default status
                });
              });

              // Show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exchange Successful!')),
              );

              // Close the dialog after successfully adding the document
              Navigator.of(context).pop();
            } catch (e) {
              // Handle any errors that might occur
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          child: const Text('Exchange'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
