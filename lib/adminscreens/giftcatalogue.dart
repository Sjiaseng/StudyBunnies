import 'package:flutter/material.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';

class Giftlist extends StatefulWidget {
  const Giftlist({super.key});

  @override
  State<Giftlist> createState() => _GiftlistState();
}

class _GiftlistState extends State<Giftlist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainappbar("Gift Catalogue", "This section includes the list of gifts that can be redeemed by the students.", context),
      drawer: adminDrawer(context, 4),
      bottomNavigationBar: navbar(4),
      body: Center(child:Text("Page4"),),
    );
  }
}