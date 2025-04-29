import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:shared_preferences/shared_preferences.dart';
import 'bookmark_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BookmarkService _bookmarkService = BookmarkService();
  final Random _random = Random();
  static const String _notificationKey = 'lastNotificationDate';

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    tz_init.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permission for iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Mengecek dan menjadwalkan notifikasi jika diperlukan
    await _checkAndScheduleNotifications();
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  Future<void> _checkAndScheduleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastNotificationDate = prefs.getString(_notificationKey);
    final String today = DateTime.now().toIso8601String().split('T')[0];

    //  Jika notifikasi belum dijadwalkan, maka di jadwalkan
    if (lastNotificationDate != today) {
      await _scheduleRandomNotifications();
      await prefs.setString(_notificationKey, today);
    }
  }

  Future<void> _scheduleRandomNotifications() async {
    // Cancel seluruh notifikasi yang ada
    await _flutterLocalNotificationsPlugin.cancelAll();

    // Get data bookmark terakhir
    final bookmarkData = await _bookmarkService.getLastRead();
    if (bookmarkData == null) {
      return;
    }

    final surahName = bookmarkData['surahName'];
    final ayahNumber = bookmarkData['ayahNumber'];

    // Waktu random untuk notifikasi di hari ini
    final now = DateTime.now();
    final DateTime morning = DateTime(
        now.year,
        now.month,
        now.day,
        8 + _random.nextInt(4), // Antara 8 AM dan 12 PM
        _random.nextInt(60)
    );

    final DateTime evening = DateTime(
        now.year,
        now.month,
        now.day,
        16 + _random.nextInt(6), // Antara 4 PM dan 10 PM
        _random.nextInt(60)
    );

    // Jadwal notifikasi untuk pagi
    if (morning.isAfter(now)) {
      await _scheduleNotification(
        id: 1,
        title: 'Waktu Membaca Al-Quran',
        body: 'Terakhir kamu membaca di Surah $surahName, Ayat $ayahNumber. Yuk, lanjutkan kembali bacaanmu hari ini.',
        scheduledTime: morning,
        payload: 'surah=$surahName&ayah=$ayahNumber',
      );
    }

    // Jadwal notifikasi untuk malam
    if (evening.isAfter(now)) {
    await _scheduleNotification(
      id: 2,
      title: 'Pengingat Al-Quran',
      body: 'Terakhir kamu berhenti di Surah $surahName ayat $ayahNumber. Jangan biarkan bacaanmu terhenti, yuk lanjutkan!',
      scheduledTime: evening,
      payload: 'surah=$surahName&ayah=$ayahNumber',
    );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quran_reminder_channel',
          'Quran Reminder',
          channelDescription: 'Notifications to remind you to continue reading Quran',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> rescheduleNotificationsIfNeeded() async {
    await _checkAndScheduleNotifications();
  }

  // Metode untuk menguji notifikasi (tambahkan di dalam kelas NotificationService)
  Future<void> showTestNotification() async {
    final bookmarkData = await _bookmarkService.getLastRead();
    if (bookmarkData == null) {
      print('No bookmark data found for notification test');
      return;
    }

    final surahName = bookmarkData['surahName'];
    final ayahNumber = bookmarkData['ayahNumber'];

    await _flutterLocalNotificationsPlugin.show(
      99,
      'Pengujian Notifikasi',
      'Terakhir kamu membaca di Surah $surahName, Ayat $ayahNumber. Yuk, lanjutkan kembali bacaanmu hari ini.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quran_reminder_channel',
          'Quran Reminder',
          channelDescription: 'Notifications to remind you to continue reading Quran',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'logo',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'surah=$surahName&ayah=$ayahNumber',
    );
  }
}