import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool hasNotifications;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.hasNotifications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed, 
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none, 
            children: [
              const Icon(Icons.notifications),
              if (hasNotifications)
                Positioned(
                  right: -2, 
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          label: "Alerts",
        ),
        const BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined), label: "Health"),
      ],
    );
  }
}
