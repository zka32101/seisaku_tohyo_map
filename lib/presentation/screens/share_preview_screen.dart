import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../infrastructure/analytics/analytics_service.dart';
import '../theme/app_theme.dart';

class SharePreviewScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final String shareText;

  const SharePreviewScreen({
    super.key,
    required this.imageBytes,
    required this.shareText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('シェア用カード')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Image.memory(
                  imageBytes,
                  // captureRepaintBoundaryImage は pixelRatio: 3.0 でキャプチャしているため、
                  // scale を合わせないと論理サイズが3倍と誤認識され、レイアウトに大きな空白ができる。
                  scale: 3.0,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _shareImage(context),
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: const Text('画像をシェアする'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _copyText(context),
                  icon: const Icon(Icons.content_copy, size: 18),
                  label: const Text('紹介文だけコピーする'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/nihon_future_map_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(file.path)], text: shareText);
      AnalyticsService().logContentShared(contentType: 'loss_card');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('シェアに失敗しました: $e')));
    }
  }

  void _copyText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('紹介文をコピーしました！画像と一緒に投稿しよう')));
  }
}
