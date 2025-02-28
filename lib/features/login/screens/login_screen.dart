import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:three_r_market_live/core/widgets/custom_text_input.dart';
import 'package:three_r_market_live/core/widgets/customtext_widget.dart';
import 'package:three_r_market_live/features/login/screens/forgot_password_screen.dart';
import '../../../core/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_bar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _isLoadingProvider = StateProvider<bool>((ref) => false);
  bool _isPasswordVisible = false;
  final RoundedLoadingButtonController _buttonController=RoundedLoadingButtonController();

  Future<void> _login() async {
    ref.read(_isLoadingProvider.notifier).update((state) => true);
    String phoneText = _phoneController.text.trim();
    int? phone = int.tryParse(phoneText);
    String password = _passwordController.text.trim();
    if (phone == null || phoneText.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      ref.read(_isLoadingProvider.notifier).update((state) => false);
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password cannot be empty.')),
      );
      ref.read(_isLoadingProvider.notifier).update((state) => false);
      return;
    }
    if (kDebugMode) {
      print('Phone: $phone, Password: $password');
    } // Debugging
    var headers = {
      'X-Secret-Key': 'IfiuH/Ox6QKC3jP6ES6Y+aGYuGJEAOkbJb',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://api.task.aurify.ae/user/login/66e994239654078fd531dc2a'));

    request.body = json.encode({
      "contact": phone,
      "password":password,
      "token": "f7OW_uHRSNKkYEi8JyTFHK:APA91bEbuovN97LQ6QIqwO8Aj85gIQ57m0Hm6Pm4V2M8kiiQ8efq77csFofJvdAganDTDyQlalqp2iIBJuA-X45J5aaqoU7Du9hm-5nEaryP8OSNhouCHLNq3R3YTGxFfP0SinCf0P"
    });

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (kDebugMode) {
        print('Response Code: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response Body: $responseBody');
      }

      if (!mounted) return;
      ref.read(_isLoadingProvider.notifier).update((state) => false);
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(responseBody);
        if (kDebugMode) {
          print('decodedddddd$decodedResponse');
        }
        String? userId = decodedResponse['userId'];
        if (kDebugMode) {
          print('uuuuuuuuuuu$userId');
        }
        if ( userId != null) {
          if (kDebugMode) {
            print("11111111111111111111111111111");
          }
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId',decodedResponse['userId'] );
        }
        showSnackBar(context, 'Login successful!');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const BottomNavBar()));
      } else {
        String errorMessage = 'Login failed. Please try again.';
        try {
          var decodedResponse = jsonDecode(responseBody);
          if (decodedResponse['message'] != null) {
            errorMessage = decodedResponse['message'];
          }
        } catch (_) {}
        showSnackBar(context, errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login Error: $e');
      }
      showSnackBar(context, 'Something went wrong. Please check your internet connection.');
      ref.read(_isLoadingProvider.notifier).update((state) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(w * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomTextWidget(
                      text: 'Gold & Silver Rates',
                      fontSizeMultiplier: 0.07,
                      weight: FontWeight.bold,
                      color: Colors.white),
                  SizedBox(height: w * 0.1),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.025),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.02),
                      child: Column(
                        children: [
                          CustomTextInput(
                            controller: _phoneController,
                            prefixIcon: const Icon(Icons.phone),
                            label: 'Phone Number',
                            hintText: 'Enter phone number',
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: w * 0.06),
                          CustomTextInput(
                            hintText: 'Enter Password',
                            controller: _passwordController,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          SizedBox(height: w * 0.02),
                           Align(
                            alignment: Alignment.topLeft,
                              child:  InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                                },
                                  child: const CustomTextWidget(text: 'Forgot Password?',color:Colors.blue,fontSizeMultiplier: 0.028,))),
                          SizedBox(height: w * 0.02),
                          RoundedLoadingButton(
                            color: Colors.amber,
                            controller: _buttonController,
                            onPressed: (){
                              _login().then((value) {
                                _buttonController.reset();
                              },);
                            },
                              child: const CustomTextWidget(
                                text:  'Login',
                                fontSizeMultiplier: 0.04,
                              )
                          ),
                        ],
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
  }
}


