import 'ng_words.dart';

/// 課題提案（ユーザーからの新規課題提案）投稿前のバリデーション
class ValidateProposal {
  static const _minTitleLength = 4;
  static const _minDescriptionLength = 10;

  /// 投稿不可の場合はエラーメッセージ、問題なければ null を返す
  static String? call({required String title, required String description}) {
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();

    if (trimmedTitle.isEmpty) {
      return '課題のタイトルを入力してください';
    }
    if (trimmedTitle.length < _minTitleLength) {
      return 'タイトルは$_minTitleLength文字以上で入力してください';
    }
    if (trimmedDescription.isEmpty) {
      return '課題の説明を入力してください';
    }
    if (trimmedDescription.length < _minDescriptionLength) {
      return '説明は$_minDescriptionLength文字以上で入力してください';
    }

    final combined = '$trimmedTitle $trimmedDescription'.toLowerCase();
    for (final word in ngWords) {
      if (combined.contains(word.toLowerCase())) {
        return '不適切な言葉が含まれている可能性があります';
      }
    }

    if (RegExp(r'https?://|www\.').hasMatch(combined)) {
      return 'URLを含む投稿はできません';
    }

    if (RegExp(r'(.)\1{7,}').hasMatch('$trimmedTitle$trimmedDescription')) {
      return '同じ文字の連続が多すぎます';
    }

    return null;
  }
}
