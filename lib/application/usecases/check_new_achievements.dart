import '../../domain/entities/achievement.dart';
import '../../infrastructure/local_storage/activity_store.dart';

/// ActivityStoreへの記録前後で実績バッジのスナップショットを比較し、
/// 新しく解除されたものだけを返す（獲得演出のトリガー用）
class CheckNewAchievements {
  static Future<List<Achievement>> call(Future<void> Function() record) async {
    final store = ActivityStore();
    final before = store.currentStats();
    await record();
    final after = store.currentStats();

    return Achievements.all
        .where((a) => a.isUnlockedBy(after) && !a.isUnlockedBy(before))
        .toList();
  }
}
