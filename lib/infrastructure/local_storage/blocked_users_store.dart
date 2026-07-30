import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

/// 端末ローカルに保存する、自分がブロックしたユーザーの一覧
///
/// ブロックしたユーザーの投稿（コメント・提案）は、この端末上でのみ非表示になる
/// （Firestore側からは削除されない。運営側の対応は通報機能・reportsコレクション経由で行う）。
class BlockedUsersStore {
  static const _boxName = 'blocked_users';
  static final Logger _logger = Logger();
  static bool _initialized = false;

  BlockedUsersStore._();

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
      await Hive.openBox(_boxName);
      _initialized = true;
    } catch (e) {
      _logger.e('Error initializing BlockedUsersStore: $e');
    }
  }

  static Box? get _box {
    try {
      return Hive.box(_boxName);
    } catch (e) {
      return null;
    }
  }

  static Set<String> getAll() {
    try {
      final raw = _box?.get('ids', defaultValue: const <String>[]) as List?;
      return (raw ?? const <String>[]).cast<String>().toSet();
    } catch (e) {
      _logger.e('Error reading blocked users: $e');
      return {};
    }
  }

  static Future<void> add(String userId) async {
    try {
      final ids = getAll()..add(userId);
      await _box?.put('ids', ids.toList());
    } catch (e) {
      _logger.e('Error blocking user: $e');
    }
  }
}
