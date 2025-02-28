
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_r_market_live/features/login/screens/login_screen.dart';
import '../../../core/globals.dart';
import '../../menu/screens/menu_screen.dart';
import '../../spot_rates/screens/spot_rates.dart';
import 'add_button_screen.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({super.key});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  final indexProvider = StateProvider<int>((ref) => 0);

  // Updated Icons for the navigation bar
  List<Widget> pages = const [
    Icon(Icons.home_filled),
    Icon(Icons.add),
    Icon(Icons.menu),
  ];

  Widget buildBody() {
    switch (ref.watch(indexProvider)) {
      case 0:
        return const SpotRate();
      case 1:
        return const AddScreen();
      default:
        return const MenuPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60.0,
        backgroundColor: Colors.black,
        buttonBackgroundColor: Colors.amber,
        color: Colors.amber,
        onTap: (value) {
          ref.read(indexProvider.notifier).update((state) => value);
        },
        items: List.generate(pages.length, (index) => pages[index]),
      ),
    );
  }
}
