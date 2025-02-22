import 'package:dooms_day/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();
  initNotifications();
  final bool isDarkMode = await _loadThemePreference();
  runApp(MyApp(isDarkMode: isDarkMode));
}

Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.request();
  if (status.isDenied) {
    print("Notification Permission Denied");
  }
}

Future<bool> _loadThemePreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDarkMode') ?? false;
}

void initNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-Day',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: MainScreen(isDarkMode: _isDarkMode, toggleTheme: _toggleTheme),
    );
  }
}
