import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:three_r_market_live/core/widgets/custom_text_input.dart';
import 'package:three_r_market_live/core/widgets/customtext_widget.dart';
import '../../../core/globals.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final RoundedLoadingButtonController _buttonController = RoundedLoadingButtonController();

  Future<String> resetPassword(String contact, String newPassword) async {
    try {
      if (kDebugMode) {
        print("Resetting password...");
      }
      final Uri url = Uri.parse("https://api.task.aurify.ae/user/forgot-password/66e994239654078fd531dc2a");
      final Map<String, String> headers = {
        'X-Secret-Key': 'IfiuH/Ox6QKC3jP6ES6Y+aGYuGJEAOkbJb',
        'Content-Type': 'application/json'
      };
      final Map<String, dynamic> body = {
        "contact": contact,
        "password": newPassword
      };
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (kDebugMode) {
        print("Response Status Code: ${response.statusCode}");
      }
      if (kDebugMode) {
        print("Response Body: ${response.body}");
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.pop(context);
        return data["message"] ?? "Password reset successful";
      } else {
        return "Failed to reset password: ${response.statusCode}";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error resetting password: $e");
      }
      return "Error resetting password";
    }
  }

  void _handleResetPassword() async {
    String phoneText = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    if (phoneText.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter phone number and password")),
      );
      _buttonController.reset();
      return;
    }

    String result = await resetPassword(phoneText, password);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
    _buttonController.success();
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
                            // obscureText: !_isPasswordVisible,
                            prefixIcon: const Icon(Icons.lock),
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
                          SizedBox(height: w * 0.04),
                          RoundedLoadingButton(
                            color: Colors.amber,
                            controller: _buttonController,
                            onPressed:(){
                              _handleResetPassword();
                              _buttonController.reset();
                            },
                            child: const CustomTextWidget(
                              text: 'Reset Password',
                              fontSizeMultiplier: 0.04,
                            ),
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
