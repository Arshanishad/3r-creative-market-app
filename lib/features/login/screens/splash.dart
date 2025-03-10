import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_r_market_live/core/widgets/customtext_widget.dart';
import 'package:three_r_market_live/features/login/screens/navigation_bar.dart';
import '../../../core/globals.dart';
import 'login_screen.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId')??"";
if (kDebugMode) {
  print('userid$userId');
}
    if (!mounted) return;

    if (userId.isNotEmpty ) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
        (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }




  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 2), () {
        _checkLoginStatus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF293036),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: h * 0.2,
              width:h* 0.2,
              decoration: const BoxDecoration(
                gradient: LinearGradient( colors: [Colors.amber, Colors.grey],),
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '3R',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Splash Text
            const CustomTextWidget(
              text: "Welcome to 3R Market",
          fontSizeMultiplier:0.04 ,
              color: Colors.white,
            ),

          ],
        ),
      ),
    );
  }
}
