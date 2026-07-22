import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// バックグラウンド/終了状態で受信した際のハンドラ（トップレベル関数である必要がある）
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // バックグラウンドではAndroidが自動でシステム通知を表示するため、ここでは何もしない
}

/// 週刊ランキング更新など、運営からのプッシュ通知を扱うサービス
///
/// 送信自体はFirebase Console（Engage → Messaging）から`weekly_updates`トピック宛てに
/// 手動配信する運用。アプリ側はトピック購読・権限リクエスト・受信時の表示のみを担う。
class NotificationService {
  static const _topic = 'weekly_updates';

  final GlobalKey<NavigatorState> navigatorKey;
  final Logger _logger = Logger();

  NotificationService({required this.navigatorKey});

  Future<void> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.subscribeToTopic(_topic);

      FirebaseMessaging.onMessage.listen(_showForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage);
      }
    } catch (e) {
      _logger.e('Error initializing notifications: $e');
    }
  }

  void _showForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final context = navigatorKey.currentState?.overlay?.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          [
            notification.title,
            notification.body,
          ].where((s) => s != null && s.isNotEmpty).join('\n'),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    // 現時点では通知タップ時にホーム（ダッシュボード）へ戻すのみ。
    // 将来的に message.data['screen'] 等でランキング画面等への遷移を出し分けられる。
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }
}
