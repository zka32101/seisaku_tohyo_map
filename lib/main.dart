import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'infrastructure/local_storage/activity_store.dart';
import 'infrastructure/notifications/notification_service.dart';
import 'presentation/screens/content_policy_screen.dart';
import 'presentation/screens/macro_dashboard_screen.dart';
import 'presentation/theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ActivityStore.init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationService(navigatorKey: navigatorKey).initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '日本の未来マップ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AppGate(),
    );
  }
}

/// 初回起動時はコンテンツポリシーへの同意画面を挟み、同意後にダッシュボードへ進む
class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  late bool _accepted = ActivityStore().hasAcceptedContentPolicy;

  @override
  Widget build(BuildContext context) {
    if (!_accepted) {
      return ContentPolicyScreen(
        onAccepted: () => setState(() => _accepted = true),
      );
    }
    return const MacroDashboardScreen();
  }
}
