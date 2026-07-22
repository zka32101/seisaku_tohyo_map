import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/glossary_provider.dart';
import '../../domain/entities/glossary_term.dart';
import '../theme/app_theme.dart';

class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terms = ref.watch(glossaryTermsProvider);
    final query = ref.watch(glossarySearchQueryProvider);

    final q = query.trim();
    final filtered = q.isEmpty
        ? terms
        : terms
              .where(
                (t) =>
                    t.term.contains(q) ||
                    t.reading.contains(q) ||
                    t.definition.contains(q),
              )
              .toList();
    final sorted = [...filtered]..sort((a, b) => a.term.compareTo(b.term));

    return Scaffold(
      appBar: AppBar(title: const Text('用語集')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) =>
                  ref.read(glossarySearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: '用語を検索（例: 実質賃金）',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _controller.clear();
                          ref.read(glossarySearchQueryProvider.notifier).state =
                              '';
                        },
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${sorted.length}件の用語',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: sorted.isEmpty
                  ? const Center(
                      child: Text(
                        '該当する用語が見つかりませんでした',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: sorted.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) =>
                          _TermCard(term: sorted[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  final GlossaryTerm term;

  const _TermCard({required this.term});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(term.category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  term.term,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2),
            child: Text(
              term.reading,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              term.definition,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
