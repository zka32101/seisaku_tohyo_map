import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/proposal_provider.dart';
import '../../application/usecases/check_new_achievements.dart';
import '../../application/usecases/validate_proposal.dart';
import '../../domain/entities/user_proposal.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_unlock_dialog.dart';

const _categories = ['economy', 'welfare', 'demographic', 'politics', 'debt'];

class SubmitProposalScreen extends ConsumerStatefulWidget {
  const SubmitProposalScreen({super.key});

  @override
  ConsumerState<SubmitProposalScreen> createState() =>
      _SubmitProposalScreenState();
}

class _SubmitProposalScreenState extends ConsumerState<SubmitProposalScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = _categories.first;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final title = _titleController.text;
    final description = _descriptionController.text;
    final error = ValidateProposal.call(title: title, description: description);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _submitting = true);
    final result = await ref.read(
      submitProposalProvider((
        title: title.trim(),
        description: description.trim(),
        category: _category,
      )).future,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result != null) {
      final newlyUnlocked = await CheckNewAchievements.call(
        () => ActivityStore().addSubmittedProposal(result),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('提案を投稿しました。みんなの投票で正式な課題を目指しましょう！')),
      );
      if (newlyUnlocked.isNotEmpty) {
        await showAchievementUnlockDialogs(context, newlyUnlocked);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('投稿に失敗しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('課題を提案する')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Text(
                  '投票数が${UserProposal.promotionThreshold}票を超えると「正式課題候補」として一覧に表示され、'
                  '将来的に正式な課題として詳しい分析ページが作られる可能性があります。',
                  style: const TextStyle(fontSize: 12, height: 1.6),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'タイトル',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                maxLength: 40,
                decoration: const InputDecoration(hintText: '例: フリーランスの社会保障格差'),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                '説明',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                maxLength: 300,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'どんな課題か、なぜ重要だと思うかを書いてください',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'カテゴリ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final selected = category == _category;
                  final color = AppColors.categoryColor(category);
                  return ChoiceChip(
                    label: Text(AppColors.categoryLabel(category)),
                    avatar: Icon(
                      AppColors.categoryIcon(category),
                      size: 16,
                      color: selected ? Colors.white : color,
                    ),
                    selected: selected,
                    selectedColor: color,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (_) => setState(() => _category = category),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('提案を投稿する'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
