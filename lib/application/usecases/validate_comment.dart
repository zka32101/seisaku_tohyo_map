import 'ng_words.dart';

/// コメント投稿前のバリデーション（NGワード・スパム対策）
class ValidateComment {
  /// 投稿不可の場合はエラーメッセージ、問題なければ null を返す
  static String? call(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 'コメントを入力してください';
    }

    final lower = trimmed.toLowerCase();
    for (final word in ngWords) {
      if (lower.contains(word.toLowerCase())) {
        return '不適切な言葉が含まれている可能性があります';
      }
    }

    if (RegExp(r'https?://|www\.').hasMatch(lower)) {
      return 'URLを含むコメントは投稿できません';
    }

    if (RegExp(r'(.)\1{7,}').hasMatch(trimmed)) {
      return '同じ文字の連続が多すぎます';
    }

    return null;
  }
}
