import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:aether_weather/core/constants/app_constants.dart';
import 'package:aether_weather/core/logging/app_logger.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          AppLogger.instance.info('Notification tapped: ${response.payload}');
        },
      );

      // Request Android 13+ POST_NOTIFICATIONS permission
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _isInitialized = true;
      AppLogger.instance.info('NotificationService initialized successfully.');
    } catch (e, stack) {
      AppLogger.instance.error('Failed to initialize NotificationService', e, stack);
    }
  }

  Future<void> showSevereWeatherAlert({
    required String title,
    required String body,
    required String area,
    bool isExtreme = false,
  }) async {
    if (!_isInitialized) {
      AppLogger.instance.info('NotificationService uninitialized, skipping notification dispatch.');
      return;
    }
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        AppConstants.severeAlertChannelId,
        AppConstants.severeAlertChannelName,
        channelDescription: AppConstants.severeAlertChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Severe Weather Warning',
        playSound: true,
        enableVibration: true,
        color: isExtreme ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _notificationsPlugin.show(
        id: id,
        title: '🚨 $title - $area',
        body: body,
        notificationDetails: details,
        payload: 'severe_alert:$area',
      );
      AppLogger.instance.info('Dispatched severe alert notification: $title in $area');
    } catch (e, stack) {
      AppLogger.instance.error('Failed to show severe weather alert notification', e, stack);
    }
  }
}
