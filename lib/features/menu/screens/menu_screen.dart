import 'package:flutter/material.dart';
import 'package:three_r_market_live/features/menu/screens/bank_details.dart';
import 'package:three_r_market_live/features/menu/screens/profile_page.dart';
import 'package:three_r_market_live/features/menu/screens/shop_screen.dart';
import '../../../core/globals.dart';
import '../../../core/widgets/customtext_widget.dart';
import '../../../theme/palette.dart';
import 'news_page.dart';


class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      backgroundColor: Palette.blackColor,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: false,
        title: const CustomTextWidget(text: "Menu",color: Colors.black,weight: FontWeight.w700,fontSizeMultiplier: 0.05,),
      ),
      body:  const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileTile(title: 'Profile', subTitle: '', page: ProfilePage()),
              ProfileTile(title: 'Shop', subTitle: '', page: ShopPage()),
              ProfileTile(title: 'Bank', subTitle: '', page: BankDetails()),
              ProfileTile(title: 'News', subTitle: '', page: NewsListingPage()),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfileTile extends StatefulWidget {
  final String title;
  final String subTitle;
  final Color color;
  final Widget page;

  const ProfileTile(
      {super.key,
        required this.title,
        required this.subTitle,
        required this.page, this.color=Colors.white});

  @override
  State<ProfileTile> createState() => _ProfileTileState();
}

class _ProfileTileState extends State<ProfileTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => widget.page,
          ),
        );
      },
      shape: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      title: CustomTextWidget(text: widget.title,color: widget.color,fontSizeMultiplier: 0.045,weight: FontWeight.bold,),
      subtitle: CustomTextWidget(text: widget.subTitle,color: widget.color,),
      trailing: Icon(Icons.arrow_forward_ios_rounded,color: widget.color,size: w*0.04,),
    );
  }
}