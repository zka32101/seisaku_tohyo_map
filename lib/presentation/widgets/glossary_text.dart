import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/glossary_provider.dart';
import '../../domain/entities/glossary_term.dart';
import '../theme/app_theme.dart';

/// 用語集に登録された単語を自動でハイライトし、タップで定義をボトムシート表示するテキスト
class GlossaryText extends ConsumerStatefulWidget {
  final String text;
  final TextStyle? style;

  const GlossaryText(this.text, {super.key, this.style});

  @override
  ConsumerState<GlossaryText> createState() => _GlossaryTextState();
}

class _GlossaryTextState extends ConsumerState<GlossaryText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final terms = ref.watch(glossaryTermsProvider);
    // Text ウィジェットと同様に、アンビエントの DefaultTextStyle（文字色など）を
    // 明示的にマージする。RichText は DefaultTextStyle を自動継承しないため、
    // これを省略すると背景色によっては文字が見えなくなる。
    final baseStyle = DefaultTextStyle.of(context).style.merge(widget.style);

    return RichText(
      text: TextSpan(style: baseStyle, children: _buildSpans(terms)),
    );
  }

  List<InlineSpan> _buildSpans(List<GlossaryTerm> terms) {
    if (terms.isEmpty) return [TextSpan(text: widget.text)];

    final sortedTerms = [...terms]
      ..sort((a, b) => b.term.length.compareTo(a.term.length));
    final pattern = sortedTerms.map((t) => RegExp.escape(t.term)).join('|');
    final regex = RegExp(pattern);

    final spans = <InlineSpan>[];
    var last = 0;
    for (final match in regex.allMatches(widget.text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: widget.text.substring(last, match.start)));
      }
      final matchedText = match.group(0)!;
      final term = sortedTerms.firstWhere((t) => t.term == matchedText);
      final recognizer = TapGestureRecognizer()
        ..onTap = () => _showDefinition(term);
      _recognizers.add(recognizer);
      spans.add(
        TextSpan(
          text: matchedText,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
            decorationStyle: TextDecorationStyle.dotted,
          ),
          recognizer: recognizer,
        ),
      );
      last = match.end;
    }
    if (last < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(last)));
    }
    return spans;
  }

  void _showDefinition(GlossaryTerm term) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      builder: (context) => _TermDefinitionSheet(term: term),
    );
  }
}

class _TermDefinitionSheet extends StatelessWidget {
  final GlossaryTerm term;

  const _TermDefinitionSheet({required this.term});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(term.category);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.menu_book_outlined, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    term.term,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              term.reading,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              term.definition,
              style: const TextStyle(fontSize: 14, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
