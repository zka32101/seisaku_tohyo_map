import 'package:flutter/material.dart';

/// Custom slide transition from right to left for screen navigation
class SlideRightTransition extends PageRouteBuilder {
  final Widget page;
  final String screenName;

  SlideRightTransition({required this.page, this.screenName = ''})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}

/// Navigation context for providing screen hierarchy information
class NavigationContext {
  final String screenName;
  final String screenTitle;
  final String? breadcrumb;
  final IconData? icon;

  const NavigationContext({
    required this.screenName,
    required this.screenTitle,
    this.breadcrumb,
    this.icon,
  });
}

/// Extension on BuildContext for enhanced navigation
extension NavigationExtension on BuildContext {
  /// Push a screen with smooth slide transition
  Future<T?> pushScreenWithTransition<T>(
    Widget screen, {
    String screenName = '',
  }) {
    return Navigator.of(
      this,
    ).push<T>(SlideRightTransition(page: screen, screenName: screenName));
  }

  /// Push replacement with transition
  Future<T?> pushReplacementScreenWithTransition<T>(
    Widget screen, {
    String screenName = '',
  }) {
    return Navigator.of(this).pushReplacement<T, T>(
      SlideRightTransition(page: screen, screenName: screenName),
    );
  }

  /// Enhanced pop with screen context
  void popScreen({String? fromScreen}) {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    }
  }
}

/// Map of screen names to display titles for breadcrumb/context
const screenTitleMap = {
  'MacroDashboard': '日本の未来',
  'ChallengeList': '気になる課題は？',
  'ChallengeDetail': '課題詳細',
  'ChallengeDiscussion': 'コメント・議論',
  'MyPage': 'マイページ',
  'Donation': '応援する（寄付）',
  'Glossary': '用語集',
  'Ranking': '週刊ランキング',
  'ProposalList': 'みんなの提案',
  'OverviewMap': '全体を俯瞰する',
  'Recommendations': 'あなたへのおすすめ',
  'MyAnalytics': 'あなたの分析',
  'Insights': '深掘り分析',
  'Achievements': 'アチーブメント',
  'TimeMachine': 'タイムマシン',
  'Quiz': 'クイズ',
  'QuizResult': 'クイズ結果',
  'UrgencyMatrix': '緊急度マトリックス',
  'AdvancedSearch': '詳細検索',
  'PrefectureAging': '都道府県別 高齢化',
  'AgeInput': '年齢入力',
  'SubmitProposal': '提案を提出',
  'SharePreview': 'シェアプレビュー',
  'GoodNews': 'グッドニュース',
  'About': 'について',
  'Summary': 'まとめ',
  'ContentPolicy': 'コンテンツポリシー',
};

/// Build a breadcrumb string for navigation context
String buildBreadcrumb(List<String> screens) {
  return screens.map((s) => screenTitleMap[s] ?? s).join(' > ');
}

/// AppBar builder with navigation context support
AppBar buildContextAwareAppBar({
  required String screenName,
  required BuildContext context,
  List<Widget>? actions,
  bool showBackButton = true,
  VoidCallback? onBackPressed,
}) {
  final title = screenTitleMap[screenName] ?? screenName;

  return AppBar(
    title: Text(title, style: Theme.of(context).textTheme.titleLarge),
    automaticallyImplyLeading: showBackButton && Navigator.of(context).canPop(),
    leading: showBackButton && Navigator.of(context).canPop()
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: '戻る',
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          )
        : null,
    actions: actions,
    elevation: 2,
  );
}
