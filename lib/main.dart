import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/jadwal_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  runApp(
    ChangeNotifierProvider(
      create: (context) => JadwalProvider(),
      child: MyApp(isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeeklySkin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        useMaterial3: true,
      ),

      home: NotificationInitWrapper(isLoggedIn: isLoggedIn),
    );
  }
}

class NotificationInitWrapper extends StatefulWidget {
  final bool isLoggedIn;
  const NotificationInitWrapper({super.key, required this.isLoggedIn});

  @override
  State<NotificationInitWrapper> createState() => _NotificationInitWrapperState();
}

class _NotificationInitWrapperState extends State<NotificationInitWrapper> {
  @override
  void initState() {
    super.initState();
  
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}