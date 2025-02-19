import 'package:dooms_day/widget/bottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'alerts_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';


class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function toggleTheme;

  const MainScreen(
      {Key? key, required this.isDarkMode, required this.toggleTheme})
      : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}



class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(isDarkMode: widget.isDarkMode, toggleTheme: widget.toggleTheme),
      const SearchPage(),
      const AlertsPage(),
      const SettingsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex], 
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        isDarkMode: widget.isDarkMode, 
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

