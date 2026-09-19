import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  static const String _defaultTheme = 'system';

  Future<void> _init() async {
    try {
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
