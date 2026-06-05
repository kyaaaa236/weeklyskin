import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/jadwal_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inisialisasi Firebase
  await Firebase.initializeApp();

  // 2. Minta izin notifikasi ke HP
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 3. ATURAN POP-UP: Memaksa notifikasi muncul melayang di Android
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,  // Ini yang memicu spanduk pop-up di atas layar
    badge: true,
    sound: true,
  );

  // 4. Ambil Token FCM untuk dicetak di terminal VS Code
  String? fcmToken = await messaging.getToken();
  debugPrint("==================================================");
  debugPrint("FCM Token Perangkat Kamu: $fcmToken");
  debugPrint("==================================================");
  
  // 5. Sistem Session Login SharedPreferences bawaan kamu (Aman)
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