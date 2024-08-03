import 'package:flutter/material.dart';

class ExchangeGift extends StatelessWidget {
  final String giftID;

  const ExchangeGift({Key? key, required this.giftID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exchange Gift'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you want to exchange this gift?'),
          // Your exchange logic or form here
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Handle exchange logic
            Navigator.of(context).pop();
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
