import 'package:dooms_day/widget/bottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'alerts_page.dart';
import 'health.dart';

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
  // int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    // _loadNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(isDarkMode: widget.isDarkMode, toggleTheme: widget.toggleTheme),
      // const SearchPage(),
      const AlertsPage(),
      StepTrackerScreen(),
      // const ProfilePage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        hasNotifications: true,
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
