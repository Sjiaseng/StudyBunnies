import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studybunnies/adminwidgets/appbar.dart';
import 'package:studybunnies/adminwidgets/bottomnav.dart';
import 'package:studybunnies/adminwidgets/drawer.dart';
//import 'package:studybunnies/main.dart';


class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarBrightness: Brightness.dark, 
    ));

    return Scaffold(
      appBar: mainappbar("Home", "This is admins' dashboard.", context),
      drawer: adminDrawer(context, 0),
      body: const Center(
        child: Text('Main Page'),
      ),
      bottomNavigationBar: navbar(2),
    );
  }
}

