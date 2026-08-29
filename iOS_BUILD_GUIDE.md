# iOS ビルド・配布ガイド

## プロジェクト概要
- **アプリ名**: 政策投票マップ (nihon_future_map)
- **Bundle ID**: jp.petti-works.nihon-future-map (予定)
- **Platform**: iOS 13.0+
- **フレームワーク**: Flutter + Firebase

## アプリアイコン設定 ✅

### アイコン仕様
- **ソース画像**: `assets/icon/icon.png` (1024x1024 px以上推奨)
- **生成方法**: flutter_launcher_icons (pubspec.yaml に設定済み)
- **配置**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 生成済みアイコンサイズ
- iPhone: 20x20, 29x29, 40x40, 57x57, 60x60 (各1x/2x/3x)
- iPad: 20x20, 29x29, 40x40, 50x50, 72x72, 76x76, 83.5x83.5
- App Store: 1024x1024

### 設定内容
```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  remove_alpha_ios: true  # iOS用に透過を除去
```

## iOSビルド環境の要件

### macOS 環境
- **Xcode**: 16.0 以上 (gRPC template syntax 対応版)
- **CocoaPods**: 1.11 以上
- **iOS Deployment Target**: 13.0

### 依存関係
```bash
# Flutterと関連ツール
flutter --version  # 3.16.0 以上推奨

# 依存パッケージ（pubspec.yamlで管理）
- firebase_core: ^3.6.0
- cloud_firestore: ^5.4.3
- firebase_auth: ^5.3.1
- firebase_analytics: ^11.3.3
- firebase_messaging: ^15.1.3
- flutter_riverpod: ^2.4.0
- その他（詳細は pubspec.yaml 参照）
```

### 既知の対応・パッチ
プロジェクトには以下の対応が含まれています：

1. **Swift Package Manager (SPM) 無効化**
   - ⚠️ Firebase のSPM自動移行対応
   - CocoaPods ベースの構成を保持

2. **Xcode 16 テンプレート構文対応**
   - ⚠️ gRPC-Core/gRPC-C++ の C++ テンプレート修正
   - `basic_seq.h` の template keyword 対応

3. **モジュールヘッダー対応**
   - Firebase umbrella header の非モジュール化対応
   - CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES = YES

4. **デプロイメントターゲット統一**
   - すべてのPod: iOS 13.0 に統一

## ビルド手順 (ローカル macOS)

### 1. 開発環境の準備
```bash
# Flutterバージョン確認
flutter --version

# プロジェクト依存関係の取得
flutter pub get

# iOSビルド用にFlutterを生成
flutter build ios --debug
```

### 2. Cocoa Pods 依存関係の解決
```bash
cd ios
pod install
# または
pod install --repo-update
```

### 3. Xcode でビルド
```bash
# CLI からのビルド
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -sdk iphoneos \
  -derivedDataPath build

# または Xcode GUI で直接ビルド
open Runner.xcworkspace
```

### 4. Simulator でテスト
```bash
flutter run
```

## リリースビルド手順

### 1. ビルドナンバーの更新
```yaml
# pubspec.yaml
version: 1.0.0+12  # build番号をインクリメント
```

### 2. リリース用プロビジョニング
- Apple Developer Program に登録
- Xcode での signing 設定
  - Team ID: 6UWJGP52W5 (設定済み)
  - Code Signing Identity: "Apple Distribution"
  - Provisioning Profile: リリース用を指定

### 3. リリースビルド
```bash
# ビルド
flutter build ios --release

# Xcode でのアーカイブ
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -sdk iphoneos \
  -archivePath build/Runner.xcarchive \
  archive
```

### 4. App Store に提出
```bash
# Xcode から直接提出
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/Runner.ipa
```

> App Store Connect にログインして IPA をアップロード

## トラブルシューティング

### "Include of non-modular header" エラー
- **原因**: Firebase ライブラリが非モジュール化
- **対応**: Podfile の `use_modular_headers!` と Xcode ビルド設定で対応済み

### "The sandbox is not in sync with the Podfile.lock" エラー
- **原因**: SPM と CocoaPods の混在
- **対応**: pubspec.yaml の `enable-swift-package-manager: false` で対応済み

### CocoaPods install 失敗
```bash
# キャッシュクリア
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf Pods/
rm Podfile.lock

# 再インストール
pod install --repo-update
```

### gRPC ビルドエラー
- **原因**: Xcode 16.3+ の C++ テンプレート構文チェック
- **対応**: Podfile の post_install フック で `basic_seq.h` をパッチ適用済み

## アイコン更新手順

### ソース画像の変更
```bash
# 1. 新しいアイコン画像を以下に配置
cp new_icon.png assets/icon/icon.png

# 2. flutter_launcher_icons を実行
flutter pub run flutter_launcher_icons

# 3. 変更をコミット
git add ios/Runner/Assets.xcassets/AppIcon.appiconset/
git add assets/icon/
git commit -m "chore: update app icon"
```

### 確認方法
- Xcode の Assets.xcassets で AppIcon を選択
- プレビューペインで全サイズを確認
- Simulator で実行して表示を確認

## CI/CD (GitHub Actions)

現在、iOS ビルドの自動化は macOS ランナーが必要です。

```yaml
# .github/workflows/ios-build.yml の例
name: iOS Build

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - run: flutter pub get
      
      - run: flutter build ios --release --no-codesign
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ios-build
          path: build/ios/iphoneos/*.app
```

## 参考資料
- [Flutter iOS ビルドドキュメント](https://flutter.dev/docs/deployment/ios)
- [Apple Developer - Signing & Capabilities](https://developer.apple.com/account/resources/certificates/list)
- [Firebase iOS 統合ガイド](https://firebase.google.com/docs/ios/setup)
- [CocoaPods ドキュメント](https://cocoapods.org/)

## チェックリスト

- [x] アイコン画像の準備 (`assets/icon/icon.png`)
- [x] flutter_launcher_icons の設定 (pubspec.yaml)
- [x] iOS アイコンアセットの生成 (AppIcon.appiconset)
- [x] Xcode プロジェクト設定 (AppIcon 参照)
- [x] Podfile の最適化 (Firebase/CocoaPods 対応)
- [x] Info.plist の設定 (アプリ名、言語)
- [x] Xcode 16 対応パッチ (gRPC template 修正)
- [ ] Apple Developer Program 登録
- [ ] Signing Certificate & Provisioning Profile の取得
- [ ] App Store Connect でアプリ登録
- [ ] App Store への提出

---
**最終更新**: 2026-08-06  
**ビルド対応**: Flutter, Xcode 16, iOS 13.0+
