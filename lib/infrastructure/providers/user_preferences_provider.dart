import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Hive.openBox() は、Hive自体が一度もinitFlutter()されていない状態で呼ぶと、
// try/catchで捕捉できるエラーとは別に、Flutterのテストフレームワークが
// 未処理例外として検出してしまう非同期エラーを重ねて発生させる（Hiveパッケージ側の挙動）。
// ActivityStore.init()が実アプリ起動時には必ずHive.initFlutter()を呼んでいるため
// 実機では問題にならないが、このファイルの各Notifierを直接ウィジェットテストから
// 触る場合（Hive.initFlutter()未実行）に備え、openBoxの直前で必ず呼んでおく。
// initFlutter()自体は複数回呼んでも安全。
Future<void> _ensureHiveReady() => Hive.initFlutter();

/// 永続化された文字列（'light'/'dark'/'system'）をFlutterの[ThemeMode]に変換する
ThemeMode themeModeFromString(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

/// State notifier for managing user's selected interest categories
class SelectedInterestsNotifier
    extends StateNotifier<AsyncValue<List<String>>> {
  SelectedInterestsNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  static const String _boxName = 'user_preferences';
  static const String _interestsKey = 'selected_interests';

  Future<void> _init() async {
    try {
      await _ensureHiveReady();
      final box = await Hive.openBox<List<dynamic>>(_boxName);
      final interests = box.get(_interestsKey, defaultValue: <String>[]);
      final stringInterests = (interests ?? const <String>[])
          .cast<String>()
          .toList();
      state = AsyncValue.data(stringInterests);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addInterest(String interest) async {
    try {
      await _ensureHiveReady();
      final box = await Hive.openBox<List<dynamic>>(_boxName);
      final current = state.maybeWhen<List<String>>(
        data: (v) => v,
        orElse: () => <String>[],
      );

      if (!current.contains(interest)) {
        final updated = [...current, interest];
        await box.put(_interestsKey, updated);
        state = AsyncValue.data(updated);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> removeInterest(String interest) async {
    try {
      await _ensureHiveReady();
      final box = await Hive.openBox<List<dynamic>>(_boxName);
      final current = state.maybeWhen<List<String>>(
        data: (v) => v,
        orElse: () => <String>[],
      );

      final updated = current.where((i) => i != interest).toList();
      await box.put(_interestsKey, updated);
      state = AsyncValue.data(updated);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggle(String interest) async {
    try {
      final current = state.maybeWhen<List<String>>(
        data: (v) => v,
        orElse: () => <String>[],
      );

      if (current.contains(interest)) {
        await removeInterest(interest);
      } else {
        await addInterest(interest);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Riverpod provider for selected interests with automatic persistence
final selectedInterestsProvider =
    StateNotifierProvider<SelectedInterestsNotifier, AsyncValue<List<String>>>(
      (ref) => SelectedInterestsNotifier(),
    );

/// State notifier for managing theme mode preference
class ThemeModeNotifier extends StateNotifier<AsyncValue<String>> {
  ThemeModeNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  static const String _boxName = 'user_preferences';
  static const String _themeModeKey = 'theme_mode';
  // 既定は 'light'。多くの画面がテーマ非対応の固定色（AppColors.*）を直接
  // 参照しているため、既存ユーザーの見え方を勝手に変えないよう、
  // ダークモードは設定画面から明示的に選んだ場合のみ有効になるようにする。
  static const String _defaultTheme = 'light';

  Future<void> _init() async {
    try {
      await _ensureHiveReady();
      final box = await Hive.openBox<String>(_boxName);
      final themeMode =
          box.get(_themeModeKey, defaultValue: _defaultTheme) ?? _defaultTheme;
      state = AsyncValue.data(themeMode);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> setThemeMode(String mode) async {
    try {
      await _ensureHiveReady();
      final box = await Hive.openBox<String>(_boxName);
      await box.put(_themeModeKey, mode);
      state = AsyncValue.data(mode);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Riverpod provider for theme mode preference with automatic persistence
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AsyncValue<String>>(
      (ref) => ThemeModeNotifier(),
    );
