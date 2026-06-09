import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/jadwal_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.showNotificationFromFCM(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.subscribeToTopic('all');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    NotificationService.showNotificationFromFCM(message);
  });

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  String? fcmToken = await messaging.getToken();
  debugPrint("==================================================");
  debugPrint("FCM Token Perangkat Kamu: $fcmToken");
  debugPrint("==================================================");
 
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  await NotificationService.init();

  final androidPlugin = FlutterLocalNotificationsPlugin()
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.requestExactAlarmsPermission();

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
  Widget build(BuildContext context) {
    return widget.isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}