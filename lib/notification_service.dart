import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Pengingat Skincare WeeklySkin',
      description: 'Channel untuk memunculkan notifikasi rutinitas skincare mingguan',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotificationFromFCM(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'Pengingat Skincare WeeklySkin',
        channelDescription: 'Channel untuk memunculkan notifikasi rutinitas skincare mingguan',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: notificationDetails,
      );
    }
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Pengingat Skincare WeeklySkin',
      channelDescription: 'Channel untuk memunculkan notifikasi rutinitas skincare mingguan',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  static Future<void> jadwalkanPengingat({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    debugPrint("🔔 jadwalkanPengingat dipanggil: jam $hour:$minute");

    final tz.TZDateTime sekarang = tz.TZDateTime.now(tz.local);

    tz.TZDateTime waktuAlarm = tz.TZDateTime(
      tz.local,
      sekarang.year,
      sekarang.month,
      sekarang.day,
      hour,
      minute,
    );

    if (waktuAlarm.isBefore(sekarang)) {
      waktuAlarm = waktuAlarm.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: waktuAlarm,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Pengingat Skincare WeeklySkin',
          channelDescription: 'Channel untuk memunculkan notifikasi rutinitas skincare mingguan',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}