
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_r_market_live/core/widgets/alert_dialog_widget.dart';
import '../../../core/globals.dart';
import '../../../core/widgets/customtext_widget.dart';
import '../../../theme/palette.dart';
import '../../login/screens/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, String>> getProfileDetails() async {
    var headers = {
      'X-Secret-Key': 'IfiuH/Ox6QKC3jP6ES6Y+aGYuGJEAOkbJb'
    };

    var request = http.Request(
        'GET', Uri.parse('https://api.task.aurify.ae/user/get-profile/66e994239654078fd531dc2a'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = json.decode(responseString);
      Map<String, dynamic> info = jsonResponse['info'];

      return {
        "Username": info['userName'] ?? "N/A",
        "Company Name": info['companyName'] ?? "N/A",
        "Address": info['address'] ?? "N/A",
        "Email": info['email'] ?? "N/A",
        "Contact": info['contact'].toString(),
        "WhatsApp": info['whatsapp'].toString(),
      };
    } else {
      throw Exception("Failed to load profile: ${response.reasonPhrase}");
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.blackColor,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: w * 0.03),
            child: TextButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              onPressed: () {},
              child: InkWell(
                onTap: (){
                  customAlertBox(
                    context: context,
                    title: 'Logout?',
                    content: 'Are you sure you want to logout?',
                    yes: () async {
                     _logout();
                    },
                  );

                },
                  child: const CustomTextWidget(text: 'Logout',weight: FontWeight.w700,)),
            ),
          ),
        ],

        titleSpacing: 0,
        title: const CustomTextWidget(
          text: "Profile",
          color: Colors.black,
          weight: FontWeight.w700,
          fontSizeMultiplier: 0.05,
        ),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: getProfileDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Data Available", style: TextStyle(color: Colors.white)));
          }

          final profileDetails = snapshot.data!;

          return Padding(
            padding: EdgeInsets.all(w * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: w * 0.15),
                Center(
                  child: CircleAvatar(
                    radius: w * 0.13,
                    child: Icon(Icons.person, size: w * 0.15),
                  ),
                ),
                SizedBox(height: w * 0.05),
                Text(
                  profileDetails['Company Name']!,
                  style: TextStyle(
                    fontSize: w * 0.065,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: w * 0.02),
                Text(
                  profileDetails['Email']!,
                  style: TextStyle(fontSize: w * 0.04, color: Colors.white),
                ),
                SizedBox(height: w * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_rounded, color: Colors.white, size: w * 0.045),
                    SizedBox(width: w * 0.03),
                    Text(
                      profileDetails['Address']!,
                      style: TextStyle(fontSize: w * 0.04, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: w * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: Colors.white, size: w * 0.045),
                    SizedBox(width: w * 0.03),
                    Text(
                      profileDetails['Contact']!,
                      style: TextStyle(fontSize: w * 0.04, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
