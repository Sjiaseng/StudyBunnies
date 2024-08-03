import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybunnies/authentication/loginscreen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black, 
    statusBarBrightness: Brightness.dark, 
  ));

  runApp(const MyApp());
  
}


ThemeData theme() {
  return ThemeData(
    textTheme: GoogleFonts.robotoTextTheme(), 
    scaffoldBackgroundColor: const Color.fromRGBO(239, 238, 233, 1)
  );
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme(),
          home: const Loginscreen(),
        );
      },
    );
  }
}

