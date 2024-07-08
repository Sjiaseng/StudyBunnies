import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybunnies/authentication/loginscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.robotoTextTheme(),
          ),
          home: Splashscreen(),
        );
      },
    );
  }
}

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final List<String> texts = [
    'Loading, please wait...',
    'Welcome to StudyBunnies!',
    'Getting things ready...',
  ];

  int _currentTextIndex = 0;
  Timer? _timer;
  bool _fadeOut = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Delay for 5 seconds before fading out
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _fadeOut = true;
      });
    });
    // Navigate to home screen after 6 seconds
    Future.delayed(Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginscreen()),
      );
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        _currentTextIndex = (_currentTextIndex + 1) % texts.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 222, 179, 1),
      body: Center(
        child: AnimatedOpacity(
          opacity: _fadeOut ? 0.0 : 1.0,
          duration: Duration(seconds: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'appicon/transparent_logo.png',
                width: 45.w,
                height: 30.h,
              ),
              Image.asset(
                'images/loading.gif', // Replace with your loading GIF path
                width: 17.w,
                height: 17.h,
              ),
              SizedBox(height: 20),
              Text(
                texts[_currentTextIndex],
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(184, 89, 30, 1.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
