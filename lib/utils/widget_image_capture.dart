import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// RepaintBoundary で囲んだウィジェットを PNG バイト列としてキャプチャする。
/// 外部パッケージに依存せず、Flutter コアAPI（RenderRepaintBoundary）のみを使用。
Future<Uint8List?> captureRepaintBoundaryImage(
  GlobalKey key, {
  double pixelRatio = 3.0,
}) async {
  final boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;

  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}
