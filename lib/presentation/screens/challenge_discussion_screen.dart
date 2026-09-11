import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihon_future_map/infrastructure/providers/discussion_provider.dart';

/// Challenge discussion and comments screen
class ChallengeDiscussionScreen extends ConsumerStatefulWidget {
  const ChallengeDiscussionScreen({
    Key? key,
    required this.challengeId,
    required this.userId,
  }) : super(key: key);

  final String challengeId;
  final String userId;

  @override
  ConsumerState<ChallengeDiscussionScreen> createState() =>
      _ChallengeDiscussionScreenState();
}

class _ChallengeDiscussionScreenState
    extends ConsumerState<ChallengeDiscussionScreen> {
  final _commentController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discussionAsync = ref.watch(discussionProvider(widget.challengeId));

    return Scaffold(
      appBar: AppBar(title: const Text('ディスカッション'), centerTitle: true),
      body: discussionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
        data: (discussion) => _buildContent(context, discussion),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ChallengeDiscussion discussion) {
    return Column(
      children: [
        // Comments list
        Expanded(
          child: discussion.comments.isEmpty
              ? const Center(child: Text('コメントがまだありません'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: discussion.comments.length,
                  itemBuilder: (context, index) {
                    final comment = discussion.comments[index];
                    return _buildCommentCard(context, comment);
                  },
                ),
        ),

        // Comment input section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display name input
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  hintText: 'ユーザー名 (省略可)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 8),

              // Comment input
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'コメントを入力',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 8),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitComment,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('コメント送信'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentCard(BuildContext context, DiscussionComment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  comment.userDisplayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatDate(comment.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Comment content
            Text(comment.content, style: const TextStyle(fontSize: 13)),

            const SizedBox(height: 8),

            // Like button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined),
                  iconSize: 16,
                  onPressed: () {
                    _likeComment(comment.id);
                  },
                ),
                Text('${comment.likes}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('コメントを入力してください')));
      return;
    }

    try {
      final displayName = _displayNameController.text.isNotEmpty
          ? _displayNameController.text
          : '匿名ユーザー';

      await addDiscussionComment(
        challengeId: widget.challengeId,
        userId: widget.userId,
        displayName: displayName,
        content: _commentController.text,
      );

      _commentController.clear();
      _displayNameController.clear();

      // Refresh the discussion
      ref.refresh(discussionProvider(widget.challengeId));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('コメントが送信されました')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラー: $e')));
    }
  }

  Future<void> _likeComment(String commentId) async {
    try {
      await likeDiscussionComment(
        challengeId: widget.challengeId,
        commentId: commentId,
      );

      // Refresh the discussion
      ref.refresh(discussionProvider(widget.challengeId));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラー: $e')));
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}日前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}時間前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分前';
    } else {
      return '今';
    }
  }
}
