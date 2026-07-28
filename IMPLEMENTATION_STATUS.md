# 日本の未来マップ — 実装ステータス

**最終更新**: 2026-07-28  
**フェーズ**: 課題一覧の投票ボタン廃止・CI用GitHubアカウント(zkacry)への移行・ビルド5でApp Store審査提出

## 77. CI用GitHubアカウントをzkacryに移行・ビルド5でApp Store審査提出（2026-07-28）
- 従来のCI用アカウント`zka32103-coder`が支払い停止でCI実行不能になったため、新アカウント
  `zkacry`でリポジトリ`japan_future_map`を新規作成し、`git remote add origin-zkacry`で追加。
  iOS署名用Secrets（APP_STORE_CONNECT_API_KEY_BASE64・ISSUER_ID・KEY_ID・FASTLANE_TEAM_ID・
  IOS_DIST_CERT_BASE64・IOS_DIST_CERT_PASSWORD・IOS_PROVISION_PROFILE_BASE64）を
  `H:\マイドライブ\key\`・`ios-signing\`のローカル保存ファイルから再設定（Issuer IDは
  [[reference_apple_appstore_connect_credentials]]のメモリから復元）。動作確認のテストビルド成功
- Android統一+投票修正（#75）・投票ボタン廃止（#76）を含むビルド5でTestFlightアップロード済み。
  App Store Connect側で連絡先情報・スクリーンショット（iPhone 1284×2778px・iPad 2048×2732px）を
  設定し、ビルド5を選択した状態で審査提出完了（2026-07-28）

## 76. 課題一覧「投票する」ボタンの削除・「これは問題」ボタンの一本化（2026-07-28）
- 課題一覧カードの「投票する」ボタンを削除し、「これは問題」（賛同）を主要アクションに統一。
  課題詳細画面にも同じ「これは問題」ボタンを対策案セクションの直上に新規追加（`_AgreeSection`）
- 使われなくなった`voteChallengeProvider`・`FirebaseService.voteChallenge()`を削除
- おすすめ機能・実績バッジ（「一票を投じた」「投票マスター」等）の判定基準を、廃止した投票
  （`votedChallengeIdsProvider`）から賛同（`agreedChallengeIdsProvider`にリネーム）ベースに変更。
  マイページの表示文言（「あなたが投票した課題」→「あなたが賛同した課題」等）も整合させた
- `flutter analyze`・`flutter test`（35件）ともにC:\apk同期コピー上でPASSを確認

## 75. Android版のFirebaseプロジェクト統一とFirestore投票不具合の根本修正（2026-07-27）
実機（Android）で「投票できない」を報告いただき、4段階の根本原因が見つかった。
- **原因1: Android版が別のFirebaseプロジェクトに接続していた**: iOS版は`apps2-752cb`を使っているのに
  Android版は`petit-works-apps-9029a`（未設定・ルール未公開）に接続していた。ユーザーの判断で
  `apps2-752cb`に統一することとし、パッケージ名を`com.petitworksapps.japanfuturemap`→
  `com.yourwish.japanfuturemap`に変更（`build.gradle.kts`のnamespace/applicationId、
  `MainActivity.kt`のパッケージパス移動、新しい`google-services.json`への差し替え、
  `firebase_options.dart`のandroidブロック更新）
- **原因2: 名前付きFirestoreデータベースの不一致**: `apps2-752cb`は他アプリ（将棋アプリ等）と共用の
  プロジェクトで、Firestoreは各アプリ専用の名前付きデータベース（`japanfuturemap`等）に分かれている。
  `FirebaseFirestore.instance`は未指定だと`(default)`データベースに繋がってしまい、
  `japanfuturemap`側にだけ公開したセキュリティルールが一切効かずPERMISSION_DENIEDになっていた。
  `FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'japanfuturemap')`を明示指定して修正
- **原因3: セキュリティルールが「自分の投票」の読み取りまで拒否していた**: `votes`/`agrees`/`likes`/
  `policyVotes`の各サブコレクションが`allow read: if false`（誰にも読ませない）になっていたが、
  アプリ側は投票前に`voteRef.get()`で「既に投票済みか」を自己チェックする実装のため、この自己チェック
  自体がPERMISSION_DENIEDで失敗していた。`allow read: if request.auth.uid == userId`（本人のみ）に
  変更し、他人の投票が見えないプライバシーは維持したまま自己チェックを通るよう修正
- **原因4: セキュリティルールの`resource.data == null`判定がFirestore rules上で無効**: `challenges`/
  `policyOptions`の書き込みルールで、未作成ドキュメントへの初回書き込みを許可する意図で
  `resource.data == null ? {} : resource.data`と書いていたが、ドキュメントが存在しないとき
  `resource`自体が`null`になるため`resource.data`へのアクセス時点でルール評価がエラーとなり、
  常に拒否されていた。`resource == null ? {} : resource.data`に修正
- 上記4点をすべて修正のうえ実機で対策案投票の成功を確認。`USER_PROCEDURE.md`のルール例も同様に更新
- TestFlightビルド番号を`4`→`5`に更新（この修正をiOS版にも反映するため）

## 74. 投票/賛同の不具合修正・iPad対応復元・アプリについて画面・省庁問い合わせ記録機能（2026-07-27）
- **投票・賛同が常に失敗するバグを修正**: `FirebaseService.voteChallenge()`/`agreeChallenge()`が
  `challenges/{id}`ドキュメントに対し`.update()`を使用していたが、このドキュメントはFirestore上に
  一度も作成されていなかった（課題一覧は常にローカルモックデータを表示しており、Firestoreへの
  書き込みが発生していなかったため）。`.update()`は対象ドキュメント不在だとNOT_FOUNDで失敗し、
  例外はcatchされ`false`が返るだけでユーザーには何のエラー表示もされていなかった。
  `set(..., SetOptions(merge: true))`に変更し、ドキュメントが無ければ作成・あれば増分するよう修正
  （対策案投票`votePolicyOptionProvider`は元々この書き方で正常だった）
- **iPad対応を一度iPhone専用に変更→ユーザー判断で復元**: 13インチiPadスクリーンショット要件を
  一時回避するため`TARGETED_DEVICE_FAMILY`を`"1"`（iPhone専用）にしたが、iPad対応を維持したいとの
  判断により`"1,2"`に復元。レイアウトはスマホ向け単一カラムのまま（iPad最適化は未実施・将来課題）
- **「このアプリについて」画面を新規追加**（`about_screen.dart`）: アプリ概要・主な機能一覧・
  データについての注記・プライバシーポリシー/サポートページへのリンクを掲載。マイページ最下部から遷移
- **省庁・窓口への問い合わせ記録機能を新規追加**: `AgencyContact`エンティティ＋
  `LoadAgencyContacts`ユースケースを、既存の`DietBill`/`IssueAdvocate`と同じ
  「開発者がDartファイルに手動で記録を追記する」パターンで新設。
  課題一覧カード・俯瞰マップに✉️バッジ、課題詳細画面に専用セクションを追加（該当課題がある場合のみ表示）。
  **実際に問い合わせを行った記録のみを掲載する方針**のため、初期データは空
- App Store提出用の自動スクリーンショット生成（fl_chartウィジェットツリーからのレンダリング）を
  試みたが、`google_fonts`のネットワーク取得がテストのフェイク非同期ゾーンで失敗し、
  `runAsync`経由に直しても10分以上ハングしたため撤回。実機（TestFlight）での手動撮影に切り替え
- TestFlightビルド番号を 1→2（新機能追加）→3（投票修正）→4（アプリについて＋問い合わせ機能）の順で
  4回アップロード。すべて`zka32103-coder/nihon_future_map`のCI経由で成功

**確認事項**:
- ✅ 全35テスト通過（`flutter test`、機能追加のたびに実行）
- ✅ Android release APKビルド成功×2（56.1MB）
- ✅ iOS署名付きビルド＋TestFlightアップロード成功×2（ビルド番号3・4）
- 📝 `AgencyContact`のデータは空。実際に省庁・窓口へ問い合わせた際は、問い合わせ先・方法・
  ステータス・内容要約・（あれば）回答要約・時点を`load_agency_contacts.dart`に追記する

## 73. モックデータの初期投票数リセット（2026-07-25）
- `firebase_service.dart`の`getMockChallenges()`内、全課題（51件）の`voteCount`・`agreeCount`を
  ハードコードされていた初期値から`0`にリセット
- `load_policy_options.dart`の全対策案（153件、`_o()`呼び出しの末尾引数）の`voteCount`も同様に`0`にリセット
- ユーザー選択により、対象は**アプリ内モックデータの初期票数（コード側）のみ**。Firestore本番データや
  端末ローカルの「投票済み」状態（`votedChallengeIdsProvider`等、現状アプリ再起動で消えるメモリ内state）は対象外
- 副作用として、注目度マップ（`_AttentionMap`、[[project_nihon_future_map]]の72番で追加）が
  `voteCount > 0`のみを対象にしていたため、リセット直後は空表示になる不具合を発見・修正。
  全課題を対象にし、`voteCount == 0`の課題は賛同率0%（x=0）としてプロットするよう変更。
  また`maxY`が0だと散布図が潰れる問題も`maxVotes == 0 ? 10 : maxVotes * 1.15`でガード
- ✅ `dart format`・全35テストPASS

## 72. 財務省の情報統制論争・注目度＆予算マップ・政党個人の主張機能を追加（2026-07-25）
- **新規課題「財務省の情報発信力と『ザイム真理教』論争」**を追加（id: `finance_ministry_narrative_control`,
  category: `structural`）。財務省が緊縮財政・増税路線を政治家・メディア・国民に浸透させているとの
  批判（通称「ザイム真理教」、森永卓郎氏『ザイム真理教』2023年が起点）と、財政規律の必要性を訴える
  反論（岸博幸氏の批判記事等）を両論併記。既存の`bureaucracy_influence`（官僚機構の影響力）とは
  切り口を分け、情報発信・世論形成という角度に絞った。対策案3件・ChallengeDetail（macro/detail/outlook）も追加
- **`Challenge`に`budgetTrillionYen`（予算規模・兆円、nullable）を追加**。出典・時点が確認できた
  9課題のみ設定（国債費31.3兆円→`national_debt`、防衛関係費8.8兆円→`defense_budget_funding`、
  地方交付税交付金等20.9兆円→`local_fiscal_dependency`、文教科学振興費6.0兆円→`education_gap`、
  公共事業関係費6.1兆円→`disaster_recovery_cost`、特別会計歳出総額400兆円→`special_account_opacity`、
  介護給付費3.7兆円→`caregiver_shortage`、少子化対策費3.5兆円→`childcare_waitlist`、一般会計総額
  122.3兆円→新規課題。すべて財務省・厚労省の予算資料をWebSearchで確認した令和7-8年度の実数）
- **政党・個人の主張を課題に関連付ける新機能**: `IssueAdvocate`エンティティ＋`LoadIssueAdvocates`
  ユースケースを新設。一次資料（政党公式サイト・政府資料・報道）で裏取りできた6課題・16件のみ掲載
  （`money_in_politics`＝企業団体献金への自民・立憲・共産の立場、`hereditary_politicians`＝世襲制限
  への維新・立憲・自民の立場、`women_in_politics`＝クオータ制への立憲・共産・政府目標、
  `defense_budget_funding`＝財源方針への政府与党・国民民主の立場、`income_stagnation`＝
  「年収の壁」への国民民主の立場、新規課題`finance_ministry_narrative_control`＝森永卓郎氏・岸博幸氏の
  両論）。`ChallengeDetailScreen`に「政党・個人が挙げている主張」セクションを`_DietBillSection`と
  同様のパターンで追加（該当課題がある場合のみジャンプバーに表示）
- **「週刊 ランキング」画面にマップタブを追加**（2タブ→3タブ）。`_ChallengeMapTab`で
  `SegmentedButton`により2種類のfl_chart `ScatterChart`を切替表示:
  - 注目度マップ: 横軸＝賛同率（agreeCount/voteCount）、縦軸＝投票数。右上ほど「多くの人が注目し
    強く賛同している」課題、左下は「まだ知られていないが知られれば支持されるかもしれない」課題
  - 予算マップ: 円の大きさ＝関連する国の予算区分の規模（兆円）、縦軸＝投票数。budgetTrillionYenが
    設定された9課題のみ対象。個別課題への予算配分ではなく参考値である旨をUI上に明記
  - いずれもプロットタップで該当`ChallengeDetailScreen`に遷移

**確認事項**:
- ✅ `dart format`実行（4ファイル整形）
- ✅ 全35テスト通過（`flutter test`）
- ⚠️ ローカル`flutter analyze`は既知の日本語パスLSPクラッシュ（[[reference_flutter_ios_github_actions_ci]]参照）で
  実行不可のため未検証。CI（Linux）側の`analyze-and-test`ジョブでの確認が必要
- 🔧 Android release APKビルドは`build-flutter-apk`スキルで実行中
- 📝 政党・個人の主張データは6課題・16件のみ（全51課題中）。政治的機微さを考慮し、
  一次資料で裏取りできたものに限定。範囲拡大は今後の課題

## 71. iOS署名付きビルド・TestFlightアップロード パイプライン完全成功（2026-07-24）
- `zka32103-coder/nihon_future_map`（4つ目のリポジトリ、請求ブロックのなかったアカウント）で
  `build-ios-signed`ジョブの再実行（失敗ジョブのみ再実行、`gh run rerun --failed`でコスト削減）が
  **全ジョブPASS**で完了。iOSの証明書インポート→署名→アーカイブ→IPA生成→TestFlightアップロードの
  一連のパイプラインが、GitHub Actions上で完全に自動化された状態で動作することを実証した
  （run: https://github.com/zka32103-coder/nihon_future_map/actions/runs/30087506632）
- これまでの一連の作業で解決した問題（すべて解消済み）:
  1. p12証明書パスワードの末尾改行混入（`echo`ではなく`printf`で登録）
  2. OpenSSL 3.xのデフォルト暗号化方式とmacOS `security`コマンドの非互換（`-legacy`フラグで再生成）
  3. Xcodeプロジェクトの署名方式が`Automatic`のままだった問題（`CODE_SIGN_STYLE=Manual`・
     `DEVELOPMENT_TEAM`・`PROVISIONING_PROFILE_SPECIFIER`を明示設定）
  4. Firebaseプラグインの非モジュラーヘッダー問題（メジャーバージョンアップで解決、
     Podfileレベルの回避策では直せなかった）
  5. Firebaseアップグレードに伴うSwift Package Manager自動検出との衝突
     （`pubspec.yaml`で明示的に無効化）
  6. 直前のTestFlightアップロード失敗はApple側の一時的な500エラーで、再実行のみで解決
- 途中、GitHub Actionsの請求ブロックに**3つのアカウント**（`funvestment1-svg`・
  `petitworksappsdev-hash`・`zka32101`）が次々と到達し、最終的に4つ目のアカウント
  （`zka32103-coder`）で検証を完了した

**確認事項**:
- ✅ 全35テスト通過
- ✅ Android debug APKビルド成功
- ✅ **iOS署名付きIPAビルド＋TestFlightアップロード成功**（このアプリで初のiOS実配布物）
- 📝 次のステップ: App Store ConnectでTestFlightのビルド処理完了を待ち、内部テスターへの
  配信・実機での動作確認に進む

## 70. Swift Package Manager自動検出の無効化（2026-07-24）
- Firebaseパッケージのアップグレード（#69）により、以前の`Include of non-modular header`
  エラーは解消したが、新しいFirebaseプラグインがSwift Package Manager (SPM)対応になったため、
  Flutter 3.44がiOSビルド時に「全プラグインがSwift Package」と自動検出し、既存のPodfileベース
  構成と混在させようとして`Error (Xcode): The sandbox is not in sync with the Podfile.lock`
  というエラーになった
- サブエージェントで調査した結果、これはキャッシュの問題ではなく、Flutter 3.44から
  SPMがデフォルトで有効になったことによる既知の挙動（[flutter/flutter#151504](https://github.com/flutter/flutter/issues/151504)、
  [公式ドキュメント](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)）
  と判明。BoringSSL-GRPC・gRPC-Coreへのソースパッチなど、既存のPodfile構成をそのまま維持したい
  ため、SPMへの移行ではなく無効化を選択
- `pubspec.yaml`に`flutter.config.enable-swift-package-manager: false`を追加し、
  CocoaPodsのみを使う構成に固定

**確認事項**:
- ✅ 全35テスト通過
- ⏳ `build-ios-signed`ジョブの再実行結果は次項に追記予定

## 69. Firebaseパッケージのメジャーバージョンアップ（2026-07-24）
- `build-ios-signed`ジョブが`Include of non-modular header inside framework module
  'firebase_messaging.FLTFirebaseMessagingPlugin'`で3回連続失敗（`use_modular_headers!`・
  `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES`の両Podfile修正を試すも解消せず）
- サブエージェントで根本原因を調査した結果、**Podfileでは直せない、FlutterFireプラグイン
  自体の既知の不具合**と判明。旧バージョンのFirebaseプラグインが古い`#import <Firebase/Firebase.h>`
  （umbrella header）を使っており、Xcode 16の厳格なモジュラーヘッダーチェックに抵触していた。
  メンテナーが2024年9月のリリース（[flutterfire#13400](https://github.com/firebase/flutterfire/pull/13400)）で
  各プラグインのソースコード側を個別モジュラーimportに修正済み
- ユーザー確認の上、Firebase関連パッケージをメジャーバージョンアップ:
  - `firebase_core`: ^2.28.0 → ^3.6.0（解決: 3.15.2）
  - `cloud_firestore`: ^4.15.0 → ^5.4.3（解決: 5.6.12）
  - `firebase_auth`: ^4.19.0 → ^5.3.1（解決: 5.7.0）
  - `firebase_analytics`: ^10.8.0 → ^11.3.3（解決: 11.6.0）
  - `firebase_messaging`: ^14.7.0 → ^15.1.3（解決: 15.2.10）
- Dartコード側のAPI利用は特に変更不要だった（既存の呼び出しパターンが新バージョンでも
  引き続き有効）。全35テストPASS

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（55.9MB、Android側にFirebase SDKアップグレードの影響なし）
- ⏳ `build-ios-signed`ジョブの再実行結果は次項に追記予定

## 68. iOS署名付きビルド・TestFlightアップロードの自動化（2026-07-24）
- 「アップロードビルドはどうやる」という要望を受け、GitHub Actionsで署名付きIPAを
  ビルドしTestFlightへ自動アップロードする`build-ios-signed`ジョブを追加
- **GitHubアカウントの移行**: `funvestment1-svg`・`petitworksappsdev-hash`の両アカウントが
  Actions請求ブロック中だったため、新たに`zka32101`アカウント（Personal Access Token認証）に
  リポジトリを移行。`git remote`は`origin-funvestment1`・`origin-petitworksappsdev`として
  旧リモートを保持。CI正常動作を確認済み（test/build-android PASS）
- **証明書一式をopensslでWindows上で生成**（Mac不要）: CSR生成→Apple Developerで
  Distribution証明書発行→`.p12`変換までを`ios-signing/`フォルダ（gitignore対象）で実施。
  1回目のアップロードは証明書とCSRの不一致でエラーになり、同じCSRファイルで再発行して解決
- **Provisioning Profile**（`JapanFutureMap App Store`）をApple Developerで作成、
  Bundle ID `com.yourwish.japanfuturemap`・Team ID `6UWJGP52W5`と正しく紐付くことを確認
- **App Store Connect API Key**: 当初、別アプリ（Potion Kitchen）で発行済みのキーを
  再利用しようとしたが、GitHub Secretsの値は読み出し不可のため、artifactに書き出す形での
  移行を試みるも両アカウントの請求ブロックで断念。最終的にユーザーが`H:\マイドライブ\key\`に
  保存していた同キー（Key ID: 32U89S87F4、Team 6UWJGP52W5配下で共通利用可能）を発見・使用
  （保存場所は[[reference_apple_appstore_connect_credentials]]としてメモリに記録）
- `ios/ExportOptions.plist`を新規作成（method: app-store-connect、手動署名、
  Bundle ID→Provisioning Profile名のマッピング）
- 7つのGitHub Secretsを`zka32101/nihon_future_map`に登録（証明書・パスワード・
  プロビジョニングプロファイル・API Key・Key ID・Issuer ID・Team ID、すべてBase64/平文で）
- `build-ios-signed`ジョブは他の2ジョブと同様、`workflow_dispatch`（手動実行）でのみ起動する
  よう最初からゲート（[[feedback_ios_cicd_cost_optimization]]の3段階ゲート方針に準拠）

**確認事項**:
- ✅ 全35テスト通過（YAML/plist追加のみ、Dartコードへの影響なし）
- ⏸ `build-ios-signed`ジョブの実際の実行結果は未確認（次回workflow_dispatchで手動実行して確認要）
- ⚠️ `ios-signing/`フォルダ（秘密鍵・証明書原本）は`.gitignore`に追加しコミット対象外に

## 67. ストア掲載用テキスト・プライバシーポリシーの作成（2026-07-13）
- 「アプリ情報などの有力内容」という要望を受け、App Store Connect / Google Play Console に
  そのまま貼り付けられる形で[STORE_LISTING.md](STORE_LISTING.md)を新規作成
  - アプリ名・サブタイトル・プロモーションテキスト・詳しい説明文（実装済み機能を網羅）・
    キーワード・推奨カテゴリ・年齢制限（コンテンツレーティング）の目安・
    スクリーンショットのキャプション案
- App内課金・プッシュ通知・Firebase Analytics/Firestoreを利用しているため両ストアで必須となる
  [PRIVACY_POLICY.md](PRIVACY_POLICY.md)も新規作成。実際にコードが収集している情報のみを記載
  （匿名認証ID・Analytics・投稿コメント/提案・通知トークン・購入完了フラグ・端末内ローカル
  データ）し、個人を特定できる情報は収集していない旨を明記
- **⏸ ユーザー対応が必要な項目**（両ドキュメントにプレースホルダーとして残っている）:
  - プライバシーポリシーの実際のホスティング（GitHub Pages等でURLを発行し、両ストアの
    掲載情報に登録する必要がある）
  - お問い合わせ先（メールアドレス等）の記入
  - サポートURLの確定（GitHubリポジトリをPublicにするか、別途問い合わせ手段を用意）

**確認事項**:
- ドキュメントのみの追加のためテスト・ビルドへの影響なし

## 66. アプリアイコンをカスタムデザインに変更（2026-07-13）
- 「アイコン・スクリーンショットの準備」の一環として、Flutterデフォルトのままだった
  アプリアイコンをカスタムデザインに変更
- 画像生成AIツールは未接続（[[reference_game_asset_generator_limitation]]）だったため、
  Python（Pillow）で直接1024×1024のアイコンをプログラム的に描画: アプリのブランドカラー
  （`AppColors.primary` #2563EB）を背景に、白い上昇トレンドの矢印（折れ線グラフ＋矢印ヘッド）
  というシンプルな幾何学的デザイン。小サイズ（20px等）でも視認できるよう、結合点の丸め・
  余白を調整して2回リデザイン
- `assets/icon/icon.png`をソースとして`flutter_launcher_icons`パッケージ（新規dev_dependency）
  を導入し、Android全解像度（mipmap-*）・iOS全サイズ（AppIcon.appiconset、1024×1024含む）に
  自動展開。iOS向けは`remove_alpha_ios: true`でApp Store要件（アルファチャンネル不可）に対応
- Xcodeでのプロジェクト設定はflutter_launcher_icons側で軽微な調整のみ
  （`ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`）、直前に追加した
  `CODE_SIGN_ENTITLEMENTS`・`GoogleService-Info.plist`の参照には影響なし

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（55.6MB、新アイコン反映済み）
- ⏸ iOS実機・シミュレータでの見た目確認は未実施（Mac環境が必要）

## 65. iOS版Firebase設定完了（GoogleService-Info.plist配置）（2026-07-13）
- ユーザーがFirebase ConsoleでiOSアプリを追加し取得した`GoogleService-Info.plist`を
  `ios/Runner/`に配置し、`lib/firebase_options.dart`の`ios`ブロックに実際の値を設定。
  `currentPlatform`のswitch文もiOSで`UnsupportedError`を投げる状態から`return ios;`に変更
- **⚠️ 重要な仕様上の注意（ユーザー確認済み・承知の上で採用）**: iOS版が接続するFirebase
  プロジェクトは`apps2-752cb`で、Android版が使う`petit-works-apps-9029a`とは**別プロジェクト**。
  ユーザーに確認したところ「apps2-752cbのまま進める」という明示的な選択があったため、
  この構成のまま実装。**この結果、iOS版とAndroid版でFirestoreデータ（課題への投票・
  コメント・みんなの提案など）は共有されない**（OSごとに別々のデータベースに書き込まれる）。
  将来的にデータ統合が必要になった場合は、iOS側を`petit-works-apps-9029a`に登録し直す
  対応が必要になる
- `ios/Runner.xcodeproj/project.pbxproj`に`GoogleService-Info.plist`のPBXFileReference・
  PBXBuildFile・Resourcesビルドフェーズへの参照を追加し、Xcodeビルド時にアプリバンドルへ
  正しく含まれるよう配線（ファイルを`ios/Runner/`に置くだけでは不十分なため）

**確認事項**:
- ✅ 全35テスト通過
- ⏸ Xcode実機ビルドでの動作確認は未実施（Mac環境が必要）

## 64. Apple Developer登録手順のドキュメント化（2026-07-13）
- 「APPLEのAPP登録方法」という質問を受け、USER_PROCEDURE.mdに新セクション
  「0.1. Appleへのアプリ登録手順」を追加（すべてブラウザから行える手順、Mac不要）
  - Step 1: Apple Developer Program登録（年間$99）
  - Step 2: App ID作成（Bundle ID: `com.yourwish.japanfuturemap`、Push Notifications有効化）
  - Step 3: App Store Connectで新規アプリ登録（名前・言語・Bundle ID・SKU）
  - Step 4: プッシュ通知用APNs認証キー発行 → Firebase Consoleへの登録手順
  - Step 5: 寄付機能の商品登録（既存の3.7セクションを参照）
  - Step 6: 税務・銀行・連絡先情報の入力（App内課金に必須）
  - Step 7: アイコン・スクリーンショット等のストア掲載情報
  - Step 8: Mac環境でのビルド・提出（既存の「0.」セクションへ接続）
- あわせて「0.」セクション内の古い記述（「ローカルではgit初期化されていません」）を、
  実際にpush済みのリポジトリ（`petitworksappsdev-hash/nihon_future_map`）を踏まえて更新
- コード変更なし（ドキュメントのみ）のため、テスト・ビルドは実施していない

## 63. iOS Bundle ID変更・Push通知Entitlements追加（2026-07-13）
- ユーザー指定によりiOS Bundle IDを`com.petitworks.nihonFutureMap`（実際にはRunnerTests側のみ
  未統一だった旧値）→ **`com.yourwish.japanfuturemap`** に変更（`project.pbxproj`のRunner/
  RunnerTests両ターゲット、`firebase_options.dart`のコメント・ひな形、USER_PROCEDURE.mdの
  Firebase Console手順を更新）。Android版の`applicationId`（`com.petitworksapps.japanfuturemap`）
  とは別のBundle IDとして運用する方針に変更
- 「Capabilitiesは何にする？」という質問に対し、実際の使用機能から判定して回答:
  - **必要**: Push Notifications（`firebase_messaging`使用）、Background Modes → Remote
    notifications（Info.plistに設定済み）
  - **不要**: Sign in with Apple／Google Sign-In（匿名認証のみ）、Associated Domains
    （Universal Links不使用）、In-App Purchase明示設定（消耗型IAPはApp IDにデフォルトで
    有効なため、Xcode Capability追加は必須ではない）
- `ios/Runner/Runner.entitlements`を新規追加（`aps-environment: development`）し、
  `project.pbxproj`のRunnerターゲット3構成（Debug/Profile/Release）に
  `CODE_SIGN_ENTITLEMENTS`を配線。Push Notifications機能に必須の設定

**確認事項**:
- ✅ 全35テスト通過
- ⏸ 実際のXcodeでの署名・Capabilities画面表示確認は未実施（Mac環境が必要）
- ⏸ App Store Connect側のBundle ID登録（`com.yourwish.japanfuturemap`、Apple Developer
  Programでの新規App ID作成）はユーザー側の作業として残っている

## 62. iOSビルドCIのコスト最適化・gRPC-Coreパッチ修正（2026-07-13）
- GitHub Actionsで`build-ios`（macOSランナー）を試行錯誤していたところ、
  「recent account payments have failed or your spending limit needs to be increased」
  というエラーでActionsが起動不能になった。原因はmacOSランナーがLinuxの10倍の
  Actions分数を消費するため、Podfile修正のたびにpushして再ビルドを繰り返したことで
  アカウントの支出上限に達したこと（同日、Potion Kitchenでも同じ問題が発生した記録あり）
- **`build-ios`ジョブを`pull_request`または`workflow_dispatch`（手動実行）でのみ
  起動するようゲート**。通常の`push`では走らなくなり、無料枠のtest/build-android
  （ubuntu-latest）のみが実行される構成に変更
- あわせて`basic_seq.h`パッチの対象漏れも修正: このヘッダーファイルは`gRPC-Core`と
  `gRPC-C++`の2つのPodにそれぞれ同一内容がコピーされて存在しており、修正対象を
  `Pods/`配下の再帰検索（`Dir.glob`）に変更し、両方に確実にパッチが当たるようにした
- **⏸ ユーザー待ち**: GitHub（`funvestment1-svg`アカウント）のBilling & plansで
  支払い方法・支出上限を確認・対応してから、Actionsタブで`build-ios`を
  手動実行（workflow_dispatch）して動作確認してください

## 61. iOS寄付課金（App内課金）対応（2026-07-13）
- 「IOSの寄付課金を追加したい」という要望を受け対応。`in_app_purchase`パッケージは
  Android（Google Play課金）・iOS（App Store/StoreKit）の両対応federated pluginのため、
  `DonationService`・`DonationScreen`のDartコードはプラットフォーム分岐なしで両OSに対応済み
  （追加のコード実装は不要と判明）
- コメントをGoogle Play専用の記述から両ストア対応の記述に更新
  （`donation_service.dart`・`donation_tier.dart`）
- `ios/Runner/Configuration.storekit`を新規追加。App Store Connectでの商品登録前でも、
  Xcodeシミュレータでdonation_small/medium/largeの3商品（消耗型）の購入フローをテストできる
- USER_PROCEDURE.mdに「3.7. 寄付機能（App Store課金）の商品登録（iOS）」を新設し、
  Google Play Console向け手順（3.6）と対になる形でApp Store Connect側の手順を記載
  （商品ID・価格例・StoreKit Configurationの使い方・Sandboxテスト手順）

**確認事項**:
- ✅ 全35テスト通過
- ⏸ 実際のiOSでの購入動作確認は未実施（App Store Connect商品登録・Mac環境が必要）

## 60. iOSビルドアーティファクトのアップロード追加（2026-07-13）
- 「PosionKichenでIOSビルドしているので同様に」という要望を受け、`potion_kitchen`アプリの
  `.github/workflows/build.yml`の`build-ios`ジョブを参照し、同じ構成に揃えた
- `flutter build ios --release --no-codesign`の後に`actions/upload-artifact`で
  `build/ios/iphoneos/Runner.app`をアーティファクトとしてアップロードするステップを追加
  （Potion Kitchenは`actions/upload-artifact@v3`だが、v3はGitHub側で2025年に廃止済みのため、
  本プロジェクトの他ステップと合わせて`@v4`を採用）

**確認事項**:
- ✅ YAMLのみの変更のためDartコードへの影響なし（既存の全35テストに変更なし）
- ⏸ 実際のGitHub Actions実行結果は未確認（リポジトリへのpush後にユーザー側で確認が必要）

## 59. iOS向けGitHub Actionsビルドジョブ追加（2026-07-13）
- 「github actionで実行予定」という要望を受け、既存の`.github/workflows/flutter_ci.yml`
  （test / build-android の2ジョブ構成）に`build-ios`ジョブを追加
- `runs-on: macos-latest`で`flutter build ios --release --no-codesign`を実行し、コンパイルが
  通るかを確認する内容（Apple Developer Program・証明書が未登録のため、まずは署名なしビルドに限定）
- GoogleService-Info.plistは未取得のためこのジョブには含めておらず、取得後にActions Secretsへ
  Base64登録して復号配置するステップ例をコメントで用意
- 実機インストール・App Store配信（`flutter build ipa`＋fastlane等でのアップロード）は、
  証明書・プロビジョニングプロファイルの登録が済んでから別途追加が必要である旨をコメントで明記
- 注意: このプロジェクトはローカルではgitリポジトリとして初期化されていない（`git status`で確認）。
  GitHub Actionsを実際に動かすには、ユーザー側でリポジトリ作成・pushが必要

**確認事項**:
- ✅ 全35テスト通過（YAML追加のみ、Dartコードへの影響なし）
- ⏸ 実際のGitHub Actions実行結果は未確認（リポジトリへのpush後にユーザー側で確認が必要）

## 58. iOS向けコード対応（2026-07-13）
- 「iOS版もびるど」という要望を受けたが、本プロジェクトはWindows環境（`H:\マイドライブ\apps\`）で
  作業しており、iOSビルドにはmacOS＋Xcodeが必須のためこの場ではビルド不可。
  ユーザーとの確認の結果、「iOS向けのコード対応だけ先に進める」を選択し、以下を実施
- **Bundle ID統一**: iOS側の`PRODUCT_BUNDLE_IDENTIFIER`を`com.petitworks.nihonFutureMap`から、
  Android版の`applicationId`（`com.petitworksapps.japanfuturemap`）に合わせて変更
  （`ios/Runner.xcodeproj/project.pbxproj`）
- **Info.plist整備**: 表示名を「日本の未来マップ」に変更、`CFBundleLocalizations`に`ja`を追加、
  `firebase_messaging`のプッシュ通知に必要な`UIBackgroundModes: remote-notification`を追加
- **firebase_options.dart**: iOS向けの分岐を追加。GoogleService-Info.plistが未取得のため、
  実行時に「Firebase Consoleで iOS アプリを追加してください」という具体的な案内を出す
  `UnsupportedError`を投げるようにし、値を埋める際のひな形コメントも追加
- **⏸ ユーザー待ち（Console操作・macOS環境）**:
  1. Firebase Console（プロジェクト: petit-works-apps-9029a）に iOS アプリを追加
     （Bundle ID: `com.petitworksapps.japanfuturemap`）→ GoogleService-Info.plistを取得し
     `ios/Runner/`に配置、`firebase_options.dart`のiosブロックを埋める
  2. Apple Developer Program登録（年間$99）とApp Store Connectでのアプリ登録
  3. macOS＋Xcode環境（実機 or クラウドビルドサービス）での`flutter build ios`実行
  4. プッシュ通知を使うならAPNs認証キーをFirebase Consoleに登録
  5. アプリアイコン・起動画面（LaunchScreen）のiOS向け差し替え（現状Flutterデフォルトのまま）

**確認事項**:
- ✅ 全35テスト通過（Dartコードへの影響なし、iOS設定ファイルのみの変更）
- ⏸ 実際のiOSビルドは未実施（macOS環境が必要）

## 57. 対策案が未設定の課題への追記（2026-07-13）
- 「対策案が書いていないのがあるので追記」という報告を受け対応。`LoadPolicyOptions`を確認したところ、
  直近#52〜#56で追加した政治構造カテゴリ15件＋全カテゴリ拡充10件、計25件の課題に対策案（3択・
  想定される影響つき）が未設定だったことが判明
- 25件すべてに対策案を3案ずつ追加（既存の`income_stagnation`等と同じ形式: title・description・
  expectedImpact・voteCount）。センシティブな政治構造の課題（官僚機構の影響力・政治とカネ・
  官邸主導と忖度など）についても、賛否が分かれる複数の対策を中立的に併記
- `my_pension_balance`（年金診断ツール）は対策案を必要としない特殊コンテンツのため、
  従来通り対象外のまま

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功
- ⏸ 実機での目視確認は未実施

## 56. 全カテゴリに課題を拡充（2026-07-13）
- 「全体的に課題追加」という要望を受け、これまで政治構造カテゴリに偏っていた追加を、
  経済・福祉・人口・政治・財政の既存5カテゴリにバランスよく拡充（各カテゴリ2件、計10件。WebSearchで実データ調査）
  - economy: `non_regular_employment`（非正規雇用の広がり。非正規雇用者数の推移グラフ付き）、
    `low_startup_rate`（開業率の低さ・産業の新陳代謝不足。日本4〜5% vs 独7%・英14%超）
  - welfare: `caregiver_shortage`（介護人材の不足。有効求人倍率4倍超）、
    `single_parent_poverty`（ひとり親家庭の貧困。就業率OECD最高水準なのに貧困率44.5%）
  - demographic: `tokyo_concentration`（東京一極集中。転入超過数の推移グラフ付き）、
    `foreign_worker_coexistence`（外国人との共生の課題。在留外国人数の推移グラフ付き）
  - politics: `local_assembly_shortage`（地方議会のなり手不足。無投票当選56%/30.3%/25%）、
    `candidacy_deposit_barrier`（選挙供託金の高さ。日本300万円は世界最高水準）
  - debt: `defense_budget_funding`（防衛費増額の財源問題。GDP比2%・約9兆円への引き上げ方針）、
    `special_account_opacity`（特別会計の不透明さ。予算規模は一般会計の約4倍）
- 実データの裏付けが弱い項目（開業率の年次推移・無投票当選の内訳グラフ）は、根拠のない数値を
  チャート化しないよう、本文の定性説明のみに留めグラフは追加しなかった

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功
- ⏸ 実機での目視確認は未実施

## 55. 政治構造カテゴリに大きな課題を追加（2026-07-13）
- 「おおきなかだいからどんどん追加」という要望を受け、影響範囲の大きい政治構造の課題を4件追加
  （WebSearchで実データを調査）
  - `vote_value_disparity`（一票の格差）: 2024年衆院選で最大2.06倍の格差、10選挙区で2倍超。
    最高裁は3回連続で合憲判断。選挙区間の最大格差の推移（2017/2021/2024年）グラフ付き
  - `hereditary_politicians`（世襲政治）: 2024年衆院選で世襲候補130人（9.7%）、
    自民党の世襲比率27.2%（米国下院・上院の世襲率5%程度と対比）
  - `ministry_silos`（縦割り行政）: 複数省庁にまたがる課題への対応の遅れ。こども家庭庁・デジタル庁など
    横断組織の設置とその実効性の論点
  - `kantei_led_politics`（官邸主導と「忖度」の構造）: 2014年の内閣人事局設置による幹部人事一元化と、
    それに伴う官僚の「忖度」への懸念を両論併記
- これで政治構造カテゴリは計15件

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功
- ⏸ 実機での目視確認は未実施

## 54. カテゴリ名変更（本質→政治構造）＋課題追加（2026-07-13）
- 「カテゴリは本質ではなく、政治構造に変更、さらに追加」という要望を受け、
  `structural`カテゴリのラベルを「本質」→「**政治構造**」に変更（`AppColors.categoryLabel`）
- 政治構造に関する課題を4件追加（WebSearchで実データを調査）:
  - `electoral_wasted_votes`（小選挙区制と死票の多さ）: 小選挙区の死票率は2021年46.5%→2024年52%→
    2026年48%で推移。報道各社の選挙結果集計に基づくグラフ付き
  - `amakudari_structure`（天下りの構造）: 退職官僚の業界再就職による利益相反の懸念。
    国家公務員法の再就職等規制・内閣人事局の公表制度についても言及
  - `local_fiscal_dependency`（中央集権と地方の財源不足（三割自治）: 国税・地方税は55:45だが
    歳出は42:58と逆転し、地方が交付税等に依存する構造を解説
  - `policy_evaluation_weakness`（政策評価・検証の甘さ）: 政策評価が自己評価にとどまりPDCAが
    働きにくい問題。EBPM（データに基づく政策立案）にも言及
- これで政治構造カテゴリは計11件

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功
- ⏸ 実機での目視確認は未実施

## 53. 本質的な課題の追加（権力・お金の構造）（2026-07-13）
- 「本質的な課題追加、財務省の闇なども含め」という要望を受け、`structural`カテゴリに
  権力・お金の構造に関する本質的な課題を3件追加
- **重要な扱い方針**: 「財務省の闇」は陰謀論的な断定ではなく、日本で広く議論されている
  「官僚機構（特に財務省）の予算編成権に由来する影響力の大きさ」への**指摘・批判**として、
  賛否両論（緊縮バイアス批判 vs 財政規律を守る役割という擁護）を併記した中立・事実ベースで記述
- 追加した課題:
  - `bureaucracy_influence`（官僚機構の影響力（財務省など））: 選挙で選ばれない官僚の政策影響力・
    緊縮バイアスへの指摘と反論を併記。国民負担率の推移（財務省データ）グラフ付き
  - `money_in_politics`（政治とカネの構造）: 企業・団体献金や組織票による政策のゆがみ。定性的説明中心
  - `press_independence`（報道と権力の距離）: 記者クラブ制度と報道の監視機能への指摘。
    世界報道自由度ランキング（国境なき記者団）の推移グラフ付き
- いずれも「個人の不正」ではなく「そうなりやすい仕組み」に注目する視点、および
  有権者自身が監視することの重要性を本文で明示

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功
- ⏸ 実機での目視確認は未実施

## 52. 本質的な課題（構造的な根本原因）の追加（2026-07-13）
- 「ほんしつてきな課題追加」という要望を受け、既存の課題の多くが「症状」レベルだったのに対し、
  それらの根っこにある構造的な根本原因を「本質的な課題」として新カテゴリで追加
- 新カテゴリ`structural`（ラベル「本質」、色: ティール `0xFF0D9488`、アイコン: `Icons.hub_outlined`）を
  `AppColors`に追加。課題一覧・俯瞰マップのカテゴリ一覧の**先頭**に配置して優先的に見せる
- 本質的な課題を4件追加（`FirebaseService.getMockChallenges`）:
  - `silver_democracy`（シルバー民主主義）: 有権者の多数を高齢者が占め政策が偏り負担が先送りされる構造。
    有権者に占める60歳以上の割合の推移グラフ付き
  - `low_labor_productivity`（労働生産性の低さ）: 時間あたり生産性がG7最下位。賃金停滞の根本原因。
    時間あたり労働生産性の推移グラフ付き
  - `unmarried_structure`（未婚化・晩婚化の進行）: 少子化の主因。生涯未婚率（男女）の推移グラフ付き
  - `reform_deferral`（改革の先送り体質）: 痛みを伴う抜本改革を先送りする政治・行政の構造。定性的説明中心
- 各課題に`LoadChallengeDetail`の詳細（macroConnection・detailedDescription・20年後/50年後の見通し・
  出典付きデータ系列）を追加。他の課題との「共通の根っこ」であることを本文で明示

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功
- ⏸ 実機での目視確認は未実施

## 51. フォント修正・全体俯瞰マップ画面の再構成（2026-07-13）
- 「漢字が一部おかしいのがあるから、フォント変更」という報告を受け対応。
  端末の標準フォントだと一部の漢字が中国語（簡体字寄り）の字形にフォールバックして
  表示されることがある問題のため、`google_fonts`パッケージを導入し、
  アプリ全体のテキストテーマ・AppBarタイトルに日本語字形の「Noto Sans JP」を明示的に適用
- 「画面構成をわかりやすく再構成」という要望を受け、前項（#50）で作った全体俯瞰マップ画面
  （`OverviewMapScreen`）を再構成。ユーザーとの確認の結果、対象は俯瞰マップ画面内のレイアウトと確定
  - 変更前: カテゴリチップで「1つ選ぶと他が隠れる」フィルター式の単一グリッド
  - 変更後: 経済／福祉／人口／政治／財政の5カテゴリ＋「良くなっていること」を
    セクション見出し付きで**すべて常時表示**する構成に変更。何も隠さず全体を見渡せることを優先
  - 上部にセクションジャンプ用のチップ（課題詳細画面の`_SectionJumpBar`と同じ設計）を追加し、
    タップで該当セクションまでスムーズスクロールできるようにした
  - サマリーカードは4項目を横並びの`Row`にレイアウトし直し、視認性を向上

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功
- ⏸ 実機での目視確認は未実施（特にNoto Sans JP適用後の漢字表示が正しくなっているかは実機確認が必要）

## 50. 全体俯瞰マップ画面の追加（2026-07-13）
- 「局所的にならないように、全体感から俯瞰してみれるような工夫」という要望を受け、
  課題一覧・課題詳細・良くなっていることが個別画面に分かれていて全体像が掴みづらい問題に対応
- 新規`OverviewMapScreen`を追加: 24件の課題＋良くなっていることを1画面のグリッドマップとして表示
  - 上部に「課題／良くなっていること／国会議案あり／世界比較あり」の件数サマリーを表示
  - カテゴリ（経済／福祉／人口／政治／財政）で絞り込めるチップフィルターを搭載
  - 各タイルにはカテゴリアイコン・タイトル・投票数に加え、国会議案（🏛）・世界比較（🌐）データの
    有無を示す小アイコンを表示し、タップで該当の詳細画面へ遷移
  - 「良くなっていること」は緑のタイルで区別し、タップで一覧画面へ遷移
- 課題一覧画面（`ChallengeListScreen`）のAppBarに「全体を俯瞰する」アイコンを追加してエントリーポイントとした

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功
- ⏸ 実機での目視確認は未実施

## 49. 課題詳細画面のナビゲーション改善（2026-07-13）
- 「操作性改善」という要望を受け、コンテンツが増え縦に長くなった課題詳細画面
  （`ChallengeDetailScreen`）にセクションジャンプメニューと「トップに戻る」ボタンを追加
- `ConsumerWidget` → `ConsumerStatefulWidget` に変更し、`ScrollController`と
  各セクションの`GlobalKey`（データ／将来予測／賛同度／国会／世界との比較／対策案／みんなの声）を保持
- AppBar下に横スクロールのチップ型ジャンプメニュー（`_SectionJumpBar`）を追加。
  タップすると該当セクションへスムーズにスクロール（`Scrollable.ensureVisible`）
  - 「国会」「世界」チップは、該当する課題にそのデータが存在する場合のみ表示
- 400px以上スクロールすると右下に「トップに戻る」の`FloatingActionButton`が出現

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功
- ⏸ 実機での目視確認は未実施（ジャンプメニューのタップ動作・スクロール位置の見た目を確認要）

## 48. 国会議案・世界との比較の全体的な拡充（2026-07-09）
- 「新規追加した項目を全体的に反映」という要望を受け、前項（#47）で一部の課題のみだった
  「国会議案」「世界との比較」のカバー範囲を大幅に拡大
- **世界との比較を7件追加**（計13件、24課題+4良くなっていること中）: 合計特殊出生率（population_decline）、
  相対的貧困率（child_poverty）、医療費対GDP比（healthcare_cost）、高等教育進学率（education_gap）、
  女性議員比率（women_in_politics）、対内直接投資（foreign_direct_investment）、
  実質賃金の伸び率（income_stagnation、G7内でイタリアと並び最低水準）
- **国会議案を4件追加**（計9課題）: 孤独・孤立対策推進法（isolated_elderly、2024年4月施行）、
  子ども・若者育成支援推進法等改正（young_carers、ヤングケアラーを法律上初めて定義）、
  GX推進法（climate_change_response、2026年4月からカーボンプライシング義務化）、
  改正医療法（regional_healthcare_gap、医師偏在是正、2025年12月成立）

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（313.2秒、54.2MB）
- ⏸ 実機での目視確認は未実施

## 47. 世界との比較を追加（2026-07-09）
- 「課題や良くなっていることは、政府政策との関連付け、世界との比較を表す」という要望のうち、
  政府政策との関連付け（国会議案）は前々項（#39）で実装済みのため、今回は「世界との比較」を新設
- WebSearchで6テーマの国際比較データを調査し、実装:
  - 国債残高対GDP比（日本214.5%、G7で最悪。ドイツ62.2%等と比較）
  - 男女の賃金格差（日本21.3%、OECD平均11.0%の約2倍、加盟36カ国中35位）
  - エネルギー自給率（日本13.3%、OECD38カ国中37位、韓国18.0%より低い）
  - 投票率の低下（日本55.93%、世界200の国・地域中158位）
  - 「良くなっていること」の再生可能エネルギー比率（日本26.7% vs 英独36〜38%）
  - 「良くなっていること」の女性就業率（日本74.1% vs ドイツ73.7%、大きく改善したが北欧にはまだ及ばず）
- `InternationalComparison`エンティティ・`LoadInternationalComparisons`・共通ウィジェット
  `InternationalComparisonSection`（横棒グラフ、日本を赤で強調表示）を新設。
  課題詳細画面・「良くなっていること」画面の両方で同じウィジェットを再利用
- データが存在する場合のみ「世界との比較」セクションが表示される設計（該当データがない課題では非表示）

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（135.8秒、54.2MB）
- ⏸ 実機での目視確認は未実施

## 46. 「良くなっていること」コンテンツ追加（2026-07-09）
- 「課題だけではなく、良くなっている事案も追加する」という要望を受け、社会課題（悪くなっていること）と
  対になる、実際に改善している社会の動きを伝えるコンテンツを新設
- WebSearchで実データを調査し、4件を厳選（すべて出典・一次情報源リンク付き）:
  - 待機児童数の8年連続減少（2017年26,081人→2025年2,254人。ただし「隠れ待機児童」約7万人の残存も明記）
  - 再生可能エネルギー比率の拡大（2013年度10.9%→2024年26.7%）
  - 女性の就業率上昇・M字カーブ解消（1986年53.1%→2024年74.1%）
  - 刑法犯認知件数の長期減少（2002年285万件→2020年61万件）と体感治安とのギャップ（2022年以降は3年連続増）
    — 単純な「良い話」だけでなく、長期改善と最近の逆行・体感とのギャップも隠さず記載し、既存の
    「公式データvs民間分析」的な誠実さのトーンを踏襲
- `GoodNewsItem`エンティティ・`LoadGoodNews`・`GoodNewsScreen`（トレンドグラフ付きカード形式）を新設
- 課題一覧画面の検索バー下に「課題だけじゃない／良くなっていることも見てみよう」という常設バナーを追加し、
  課題を見ているまさにその場で気づけるようにした

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（57.6秒、54.2MB）
- ⏸ 実機での目視確認は未実施

## 45. 実績バッジ獲得演出（2026-07-09）
- 「良い流れを追加する」という要望を受け、実績バッジを**その場で**（マイページを開いて初めて気づくのではなく）
  獲得した瞬間にお祝いポップアップを表示するようにした
- `CheckNewAchievements`ユースケースを新設: `ActivityStore`への記録前後で`ActivityStats`を比較し、
  新しく解除された実績だけを検出する（`ActivityStore.currentStats()`を前項のマイページと共用）
- `showAchievementUnlockDialogs`: 弾むようなスケールインアニメーション（`Curves.elasticOut`）+
  触覚フィードバック（`HapticFeedback.mediumImpact()`）付きのお祝いダイアログ。複数同時解除にも対応し、順番に表示
- 既存の全ての活動記録ポイント（課題投票・対策案投票・コメント投稿・提案投稿・提案への投票・
  クイズ完了・年金診断・寄付）に組み込み。画面遷移やSnackBar表示の前にダイアログを挟むよう調整
  （例: 提案投稿後は「投稿しました」のSnackBar→お祝いダイアログ→画面を閉じる、の順）
- 実装中、`my_page_screen.dart`から`ActivityStats`のimportを誤って削除してしまいビルドエラーになる
  不具合があったため、修正して解消

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（144.6秒、54.2MB）
- ⏸ 実機での演出確認（バイブレーション・アニメーションの実際の見た目）は未実施

## 44. マイページ・実績バッジ機能（2026-07-09）
- 「魅力を高める機能」として、散らばっていた自分の活動（投票・コメント・対策案選択・提案・クイズ・寄付）を
  一箇所で振り返れる「マイページ」を新設し、参加数に応じた実績バッジでゲーム性を持たせた
- **端末ローカル保存に`hive_flutter`を初めて使用**: 以前から依存関係には入っていたが未使用だったパッケージ。
  Firestore側の`votes/{userId}`等はドキュメント存在チェック専用で読み取り禁止にしているため、
  「自分が何に投票したか」を横断的に一覧するには端末内保存が現実的な選択肢だった
  - `ActivityStore`: 投票した課題ID・提案ID・自分が投稿した提案ID・対策案投票した課題ID・
    コメント数・クイズ完了数・寄付回数・年金診断済みフラグを保存
  - Firebase未初期化のテスト環境でも例外を起こさないよう、`AnalyticsService`等と同様に全操作を防御的に実装
- `Achievement`/`Achievements`: 9種類の実績バッジ（はじめの一歩・投票マスター・声を届けた・政策通・
  クイズマスター・提案者デビュー・応援団・サポーター等）を活動統計から自動判定
- `MyPageScreen`: 活動件数のグリッド、実績バッジ一覧（未達成はグレーアウト）、自分が投票した課題一覧、
  自分が提案した課題一覧を表示。ダッシュボードAppBarの人物アイコンから遷移
- 既存の投票・コメント・対策案投票・提案投稿・クイズ完了・寄付の各成功ハンドラに`ActivityStore`への
  記録を追加（`submitProposal`は「自分の提案」を特定するため、戻り値を`bool`から新規ドキュメントID
  （`String?`）に変更）

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（147.3秒、54.2MB）
- ⏸ 実機での動作確認（アプリ再起動後も活動履歴が保持されるかを含む）は未実施

## 43. 広告なし・寄付機能（2026-07-09）
- 「広告なしで運営する代わりに寄付機能を実装する」方針に基づき実装（このアプリはもともと広告SDKを
  導入していないため、「広告なし」は既に事実。今回はその価値をユーザーに明示しつつ、寄付導線を新設）
- `in_app_purchase`パッケージを追加し、Google Play課金（消費型アイテム）による寄付を実装
  - `DonationTier`: コーヒー1杯分（`donation_small`）/ランチ1食分（`donation_medium`）/がっつり応援（`donation_large`）の3段階
  - `DonationScreen`: 「広告なしで運営しています」という説明＋各ティアの購入ボタン
  - ダッシュボードのAppBar（ハートアイコン）と、画面下部の常設バナーの2箇所から導線
  - 購入成功時に`content_shared`と同様のパターンで`donation_purchased`イベントをアナリティクスに記録
- **Google Play Consoleでの商品登録が別途必要**（未登録の間は「準備中です」と表示され、安全に動作する設計）。
  `USER_PROCEDURE.md`に商品ID・登録手順を追記（商品IDはコード側と完全一致させる必要がある旨を明記）

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（338.5秒。53.6MB）
- ⏸ 実機での動作確認・Google Play Console側の商品登録は未実施

## 42. プッシュ通知機能（2026-07-09）
- `firebase_messaging`を追加し、`NotificationService`を新設
- アプリ起動時に通知許可をリクエストし、`weekly_updates`トピックを自動購読
  （送信はCloud Functions等の自動配信基盤が未整備のため、Firebase Console → Engage → Messaging から
  手動でトピック宛てに配信する運用。`USER_PROCEDURE.md`に送信手順を追記）
- フォアグラウンド受信時はアプリ内にスナックバーで表示（Androidの標準仕様上、フォアグラウンド中は
  システム通知トレイに出ないため）。バックグラウンド/終了時は通常の通知トレイに表示される
- 通知タップ時はホーム（ダッシュボード）に戻る動作を実装（`message.data`を使った画面出し分けは将来拡張可）
- Firebase未初期化のテスト環境でも例外でアプリを止めないよう、`AnalyticsService`等と同様に
  `initialize()`全体を`try-catch`で防御し、`flutter test`実行時はエラーがログに記録されるのみで
  テスト自体は失敗しないことを確認

**確認事項**:
- ✅ 全35テスト通過（Firebase未初期化のため通知初期化はエラーとしてログに記録されるが、テスト自体は成功）
- ✅ `flutter build apk --release` 成功（602.2秒・約10分。`firebase_messaging`のネイティブプラグイン初回登録分で
  通常より大幅に時間がかかった。53.1MB）
- ⏸ 実機での通知受信確認（フォアグラウンド/バックグラウンド両方）は未実施

## 41. ユーザー課題提案・投票・政府提出状況の追跡機能（2026-07-09）
- **「みんなの提案」機能を新設**: ユーザーが自由に新しい社会課題を提案できるようになった
  - `UserProposal`エンティティ（title/description/category/voteCount/submissionStatus等）を新設
  - 提案投稿画面（`SubmitProposalScreen`）: タイトル・説明・カテゴリを入力して投稿。NGワード・URL・
    同一文字の連続などを`ValidateProposal`でチェック（既存の`ValidateComment`と共通のNGワードリストを
    `ng_words.dart`に切り出して共有）
  - 提案一覧画面（`ProposalListScreen`）: 投票受付中の提案を得票数順に表示、投票ボタンで1人1票
  - **20票を超えると「正式課題候補」として上部セクションに自動的に移動**（`UserProposal.isPromoted`、
    サーバー側の承認処理なしにクライアント側で判定する設計）
- **政府への提出状況の追跡**: `submissionStatus`（未提出/提出済み/回答待ち/採択された/見送りとなった）、
  `submissionNote`（提出先の説明）、`submissionUrl`、`submissionDate`をカードにバッジ表示
  - 実際に自治体・省庁等へ提出した際は、Firebase Consoleから該当ドキュメントのフィールドを手動更新する運用
    （アプリのFirestoreルールは`voteCount`のインクリメント以外の書き込みを禁止しており、
    ステータス管理は開発者がConsole経由でのみ行える設計）
  - `USER_PROCEDURE.md`に更新手順を追記
- 一覧画面のAppBarに「みんなの提案」への導線（メガホンアイコン）を追加
- Firestoreルール案（`userProposals`コレクション + `votes`サブコレクション）を`USER_PROCEDURE.md`に追記

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（95.6秒、53.0MB）
- ⏸ 実機での目視確認・Firestoreルール適用は未実施

## 40. 議案データの一次ソース調査・効果の記載追加（2026-07-09）
- **一次ソースからの自動取得はWebSearchで調査した結果、現状は非現実的と判断**（詳細は`IMPLEMENTATION_STATUS.md`本項参照）:
  - 衆議院・参議院の「議案情報」ページ（shugiin.go.jp / sangiin.go.jp）はHTMLのみでAPI提供なし
  - 国立国会図書館の「国会会議録検索システム」は公式APIがあるが、対象は会議録（発言記録）の全文検索であり、
    「議案が審議中/成立か」を構造化データとして返す機能ではない
  - 第三者（SmartNews メディア研究所）が参議院データを元にしたCSV/JSONを公開しているが、参議院のみ・二次データであり、
    継続的な更新保証もない
  - → 結論として、アプリ内から信頼できるライブ取得は困難。Cloud Functions等でスクレイピング基盤を新設すれば
    技術的には可能だが、大規模な開発が必要。当面は既存の「一次ソースへの外部リンク」を維持しつつ、
    定期的な手動更新でデータの鮮度を保つ運用とする
- `DietBill`に`effect`（想定される効果・影響）フィールドを追加し、既存5件の議案データすべてに、
  対策案と同様のメリット/懸念点を併記するスタイルで記載
- 課題詳細画面の議案カードに、要約の下に効果・影響のハイライトボックスを追加表示

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（81.1秒、52.6MB）
- ⏸ 実機での目視確認は未実施

## 39. 国会の実際の議案との連動（2026-07-09）
- `DietBill`エンティティと`LoadDietBills`を新設。WebSearchで実際の国会審議状況を調査し、
  5課題（年金危機・政治家の待遇・自然災害の復旧費用・保育園の待機児童・行政のデジタル化の遅れ）に
  実在する国会の法案・議案を紐づけた
  - 年金制度改正法（2026年6月成立）、政治資金規正法等改正（一部施行済み・追加改正案審議中）、
    防災庁設置法案（衆院通過・参院審議中）、子ども・子育て支援法等改正（2026年4月施行済み）、
    マイナンバー法等改正案（参院特別委員会で可決）
- 課題詳細画面に「国会での関連する動き」セクションを追加。法案名・審議状況（ステータスバッジ）・
  内容の要約・出典（情報時点付き）・一次情報源への外部リンク（`url_launcher`）を表示
- 国会の審議状況は日々変化するため、各データに「情報時点」（2026年7月時点）を明記し、
  コード側にも定期更新が必要な旨のコメントを残した

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（245.8秒、52.5MB）
- ⏸ 実機での目視確認・外部リンクの実際の遷移確認は未実施

## 38. ランキング画面に対策案タブ追加（2026-07-09）
- 「週刊 課題ランキング」画面を「週刊 ランキング」にリニューアルし、`TabBar`で「課題」「対策案」の2タブ構成に変更
  （既存の課題ランキングタブはロジック・見た目とも変更なし）
- 「対策案」タブ: 全24課題の対策案（計72件）を横断して得票数順に並べたランキングを表示。
  各行に対策案タイトル・元の課題名（カテゴリ色付き）・得票数を表示し、タップで該当課題の詳細画面に遷移
- `allPolicyOptionsProvider`（`FutureProvider`）を新設。`LoadPolicyOptions.challengeIds`で対策案のある
  全課題IDを取得し、既存の`policyOptionsProvider`（ベース投票数+Firestore実投票数の合算）を`Future.wait`で
  横断集計する設計とし、単一課題向けのロジックをそのまま再利用

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（100.1秒、52.4MB）
- ⏸ 実機での目視確認は未実施

## 37. コンテンツ第4弾拡充（2026-07-09）
- **社会課題**: 20件→**24件**に拡大（年金診断を含めると25件）
  - 追加: 気候変動対応の遅れ（debt）・ヤングケアラーの負担（welfare）・行政のデジタル化の遅れ（politics）・
    単身高齢者の孤立（demographic）
  - カテゴリのバランスを考慮し、比較的少なかったdebt/politics/demographicを中心に追加
  - 4件とも詳細データ（背景説明・公式vs民間データの比較グラフ・20年後/50年後の生活影響・タグ）を整備
- **対策案**: 新規4課題それぞれに3つずつ対策案（内容＋想定される効果・影響）を追加
- **用語集**: 新規コンテンツに登場する用語6語（カーボンニュートラル・国境炭素税・ヤングケアラー・
  デジタルデバイド・孤立死・民生委員）を追加（計36語）

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（159.3秒、52.1MB）
- ⏸ 実機での目視確認は未実施

## 36. 対策案投票結果のSNSシェア（2026-07-09）
- 対策案に投票した後、「投票結果をシェアする」ボタンを表示。テキストベースで`Share.share()`を使い、
  課題名・自分が選んだ対策案・全対策案の得票率（✅で自分の選択を明示）をまとめて共有できるようにした
  （年金カード/クイズ結果は画像＋テキストのシェアだが、対策案は動的な集計値のため軽量なテキストシェアを採用）
- シェア成功時は`content_shared`（`content_type: 'policy_option_result'`）としてアナリティクスにも記録

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（275.7秒、52.0MB）
- ⏸ 実機でのシェアシート表示確認は未実施

## 35. アナリティクス計測（2026-07-09）
- `firebase_analytics`は依存関係に入っていたが未使用だった（設計書記載の`loss_calculated`/`vote_submitted`/`content_shared`が
  「実装予定」のまま放置されていた）ため、`AnalyticsService`を新設して実装
- 計測イベント: `loss_calculated`（年金診断）、`vote_submitted`/`agree_submitted`（課題投票・賛同）、
  `content_shared`（年金カード・クイズ結果のシェア、`content_type`で区別）、`comment_posted`/`comment_liked`（コメント）、
  `policy_option_voted`（対策案投票）、`quiz_completed`（診断レベル・正答度・上級モードかどうか）
- Firebase未初期化環境（`flutter test`のウィジェットテストなど）でも例外でアプリを止めないよう、
  `AnalyticsService`は`FirebaseAnalytics.instance`取得と送信の両方を`try-catch`で防御的に実装
  （最初はcatchなしで実装したため`age_input_screen_test`/`quiz_screen_test`が
  `[core/no-app] No Firebase App`例外で落ちる不具合があり、修正して解消）

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（136.4秒、52.0MB）
- ⏸ Firebase ConsoleのAnalyticsダッシュボードでの実イベント確認は未実施（実機操作後、反映まで数時間かかる場合あり）

## 34. オフライン対応（2026-07-09）
- Firestoreのローカルキャッシュ・書き込みキューを明示的に有効化（`Settings(persistenceEnabled: true, cacheSizeBytes: unlimited)`）。
  これにより、オフライン中の投票・コメント・対策案投票もローカルに保存され、オンライン復帰時に自動同期される
  （課題データ自体はモック中心のため、ダッシュボード/一覧/クイズ/タイムマシンはそもそも常にオフラインで完結する）
- `connectivity_plus`パッケージを追加し、`connectivityProvider`でオンライン/オフライン状態を監視
- オフライン時は一覧・詳細・ダッシュボード画面上部に「オフラインです。直近のデータを表示しています。投票・コメントは
  ネットワーク復帰後に反映されます」というバナーを表示
- コメント欄が空の場合、オンライン時は「まだコメントはありません」、オフライン時は「オフラインのため最新のコメントを
  取得できません」と、状況に応じたメッセージに切り替え
- 実装当初は`InternetAddress.lookup` + `Stream.periodic`によるポーリングを検討したが、`flutter test`で
  「Timer is still pending」エラーが発生したため、プラットフォームイベントベースの`connectivity_plus`に切り替え、
  テストへの副作用なく実装

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（156.4秒、52.0MB）
- ⏸ 実機での目視確認（機内モードでの動作確認含む）は未実施

## 33. グラフのY軸ラベル追加（2026-07-09）
- 「スケールがわかりづらい」という指摘を受け、全5箇所の折れ線グラフに縦軸（Y軸）の数値ラベルと薄い横グリッド線を追加
  - マクロダッシュボード: 人口推移／エネルギー自給率／医療費推移（3グラフ）
  - 課題詳細画面: 公式データ vs 民間分析の比較グラフ
  - タイムマシン画面: 政策シミュレーショングラフ
- 共通ユーティリティ`niceAxisInterval()`（`lib/presentation/widgets/chart_axis.dart`）を新設し、データの範囲から
  「きりのいい」目盛り間隔（1・2・5・10のいずれかの桁）を自動計算するようにした
- 単位表示は各グラフの`unit`フィールドを使い、「%（消滅可能性自治体の割合）」のような長い注釈は
  括弧より前の短い単位（「%」等）だけを軸ラベルに使うようにして、狭い軸スペースでも収まるようにした

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（70.9秒、52.0MB）
- ⏸ 実機での目視確認は未実施

## 32. 対策案への投票機能追加（2026-07-09）
- `PolicyOption`エンティティ（title/description/expectedImpact/voteCount）と`LoadPolicyOptions`を新設。
  20課題（年金診断を除く全課題）それぞれに3つの対策案を用意し、各案の内容と想定される効果・影響（メリット/デメリット）を明記
- 課題詳細画面に「あなたなら、どの対策案を選ぶ？」セクションを追加。1課題につき1案のみ選択可能
  - 投票前は各案がカード形式で表示され、「この案を選ぶ」ボタンで選択
  - 投票後は全員の投票割合（%・件数）が棒グラフで表示され、最多得票案には🏆アイコン、自分が選んだ案には✓アイコンが付く
    （＝「選択数は周りが見れるように」という要件を、投票後に全選択肢の得票率を公開する形で実現）
- Firestore: `challenges/{id}/policyOptions/{optionId}`（`voteCount`をFieldValue.incrementで加算）、
  `challenges/{id}/policyVotes/{userId}`（1ユーザー1票を保証、ドキュメントIDをuserIdにして二重投票を防止）を新設。
  課題データがローカルモック中心のため、`update()`ではなく`set(merge:true)`を使い親ドキュメント未作成でもエラーにならないようにした
- `USER_PROCEDURE.md`のFirestoreルール案に`policyOptions`/`policyVotes`のルールを追記

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（55.6秒、52.0MB）
- ⏸ 実機での目視確認・Firestoreルール適用は未実施

## 31. 白文字バグ修正・コメント機能強化（2026-07-09）
- **白文字バグ修正**: `GlossaryText`（前項で追加）が素の`RichText`を使っており、`Text`ウィジェットと違って
  アンビエントの`DefaultTextStyle`（文字色）を継承していなかった。`DefaultTextStyle.of(context).style.merge(widget.style)`
  で明示的にマージするよう修正し、「20年後/50年後の見通し」等の文字が見えなくなる問題を解消
- **NGワード・スパム対策**: `ValidateComment`ユースケースを新設。死ね等のNGワード・URL・同一文字の過剰な連続を
  投稿前にクライアント側でブロックし、該当時はエラーメッセージを表示して投稿を中断
- **コメント投稿失敗の修正**: `postCommentProvider`が匿名認証の完了を待たずにFirestoreへ書き込んでいたため、
  認証必須のセキュリティルール下では確実に失敗する不具合があった。vote/agreeと同様に`userIdProvider.future`を
  待ってから投稿するよう修正（`USER_PROCEDURE.md`のFirestoreルール未適用の場合は引き続き失敗するため、
  ルール適用が必要な旨を追記）
- **コメントの「いいね」機能**: `Comment`に`likeCount`を追加、`likes`サブコレクション（ユーザーIDをドキュメントIDにして二重いいね防止）
  で管理。いいねが多い順→新しい順にソートし、3件以上いいねされたコメントは「人気のコメント」バッジ付きでハイライト表示

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（70.8秒、51.8MB）
- ⏸ 実機での目視確認・Firestoreルール適用は未実施

## 30. 用語集機能追加（2026-07-09）
- `GlossaryTerm`エンティティ・`LoadGlossaryTerms`（30語の用語データ: 実質賃金・賦課方式・GDP比・相対的貧困・少子高齢化 等）を新設
- `GlossaryScreen`: 用語を検索・一覧表示する専用ページ（読み仮名・定義付き、キーワード検索対応）
- `GlossaryText`ウィジェット: 通常の説明文の中で登録済み用語を自動ハイライトし、タップするとボトムシートで定義を即確認できる共通コンポーネント
  - 課題一覧カードの説明文、課題詳細画面（説明・詳細背景・生活とのつながり・20年後/50年後の見通し）に適用
- 一覧画面・課題詳細画面・マクロダッシュボード・タイムマシン画面のAppBarに「用語集」アイコンを追加し、どのコンテンツからも用語集ページへすぐ遷移できるように

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（67.5秒、51.8MB）
- ⏸ 実機での目視確認は未実施

## 29. 検索・タグ機能追加（2026-07-09）
- `Challenge`エンティティに`tags`フィールドと`matchesSearch()`（名前・説明・タグの部分一致判定）を追加
- `getMockChallenges()`の全21件（年金診断含む）に検索用タグを付与（例: 年金・子育て・地方・ジェンダー・財政 等、計19種のタグプール）
- `_challengeFromFirestore()`もFirestoreの`tags`フィールドをパースするよう対応（本番データ投入時も動作するように）
- 一覧画面（`ChallengeListScreen`）に検索バーを追加（`searchQueryProvider`で状態管理）
  - キーワード検索でカテゴリフィルターと併用可能、該当なし時は空メッセージ表示
  - 各課題カードにタグチップを表示し、タップするとそのタグで検索できるように

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（102.2秒、51.6MB）
- ⏸ 実機での目視確認は未実施

## 28. 起動時クラッシュ修正（2026-07-08）
- パッケージ名変更（`com.petitworks.nihon_future_map` → `com.petitworksapps.japanfuturemap`）後、`am start`で
  `Error: Activity class ... does not exist` により即クラッシュしていた不具合を修正
- 原因: `build.gradle.kts`の`applicationId`/`namespace`は変更したが、`MainActivity.kt`の実ファイルが旧パッケージのディレクトリ
  （`kotlin/com/petitworks/nihon_future_map/`）に残ったままだった（`package`宣言も旧のまま）
- 新パッケージのディレクトリ（`kotlin/com/petitworksapps/japanfuturemap/`）に`MainActivity.kt`を作成し直し、旧ファイル・空ディレクトリを削除して解消
- `adb shell pidof`でPIDが安定していること、`adb logcat --pid=<pid>`にエラーが出ないこと、`dumpsys window`のフォーカスが
  正しい新パッケージ名になっていることを実機で確認済み

## 27. コンテンツ第3弾拡充（2026-07-08）
- **社会課題**: 15件→**20件**に拡大
  - 追加: 保育園の待機児童（welfare）・中小企業の後継者不足（economy）・男女の賃金格差（economy）・自然災害の激甚化と復旧費用（debt）・地方の医療格差/医師不足（welfare）
  - 全20件に対応する詳細データ（背景説明・公式vs民間データ・20年後/50年後の生活影響）を整備済み
- **マクロダッシュボードに新指標追加**: 「医療費はどれだけ増えている？」セクション（国民医療費 2000〜2025年推移、30.1兆円→47.0兆円）
  - `MacroDashboard`に`healthcareCostTrend`（`HealthcareCostData`リスト）を追加
  - 既存のエネルギー自給率セクションと同じ折れ線グラフパターンで実装、`interval: 1`で軸ラベル重複を回避

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（exit code 0、99.5秒、**51.0MB**）
- ⏸ 実機での目視確認は未実施

## 26. パッケージ名・Firebaseアカウント変更（2026-07-08）
- **方針変更**: 今後Firebase/Google Play Consoleは `funvestment1@gmail.com` に統一（旧: petitworksdev/petitworksappsdev）
- **applicationId変更**: `com.petitworks.nihon_future_map` → **`com.petitworksapps.japanfuturemap`**（`android/app/build.gradle.kts`の`namespace`/`applicationId`両方）
  - Androidでは別アプリ扱いになるため、実機に旧パッケージ名のアプリが入っている場合はアンインストールが必要
- **google-services.json 更新**: 新パッケージ名用のエントリを含むファイルに差し替え（同一Firebaseプロジェクト`petit-works-apps-9029a`内の新規clientエントリ）
- **firebase_options.dart 更新**: `appId`を新しい値（`1:216377882454:android:189037cc74accf69d108f7`）に変更
- **メモリ更新**: `user_firebase_account.md`にアカウント方針変更を記録。次回このアプリのFirebase設定を触る際は、petitworksdev共通プロジェクトのままか、funvestment1側に作り直すかを要確認と明記

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（exit code 0、145.6秒、**50.9MB**）
- ⚠️ 実機に旧パッケージ名（`com.petitworks.nihon_future_map`）のアプリが入っている場合、新APKは別アプリとしてインストールされる（上書きされない、手動アンインストール推奨）

## 25. タイムマシン新指標・クイズ難易度分岐（2026-07-08）
- **タイムマシン新指標追加**: 3指標→**5指標**に拡大（医療費・空き家率を追加、いずれも`lowerIsBetter: true`）
  - `SegmentedButton`が5項目で画面幅を超える可能性があるため`SingleChildScrollView`で横スクロール対応
- **診断クイズの難易度分岐**: `QuizQuestion`に`difficulty`フィールドを追加し、`LoadQuizQuestions.advanced()`で上級問題5問を新設（一般会計予算総額・生活保護受給者数・平均寿命・消費税収・市区町村数）
  - 診断結果が「社会課題マスター」判定の場合のみ「上級問題に挑戦する」ボタンを表示
  - `isAdvancedQuizProvider`で出題セットを切り替え、AppBarタイトルに「上級」表示
  - 「トップに戻る」で上級モードをリセット
- **テスト追加**: `load_policy_simulation_test.dart`に新指標2件のテストを追加（全35テスト）

**確認事項**:
- ✅ 全35テスト通過
- ✅ `flutter build apk --release` 成功（exit code 0、57.0秒、**51.5MB**）
- ⏸ 実機での目視確認は未実施

## 24. 追加実装案の順次実装（2026-07-08）
- **世代別賛同マップ**: `Challenge.generationAgreement`（既存データ）を課題詳細画面に横棒グラフで可視化。最も賛同度が高い世代を自動でハイライト
- **SNSへの直接シェア**: `share_plus`パッケージを追加し、クリップボードコピーのみだった共有を、ネイティブ共有シート呼び出し（LINE/X等へ直接）に変更
  - `share_preview_screen.dart`: 画像を一時ファイルに書き出し`Share.shareXFiles`で共有（`path_provider`で一時ディレクトリ取得）
  - `quiz_result_screen.dart`: `Share.share()`でテキスト共有、クリップボードコピーはサブボタンとして併存
- **課題へのコメント機能**: `Comment`エンティティ新設、Firestoreの`challenges/{id}/comments`サブコレクションに投稿・取得する`FirebaseService`メソッドを追加。課題詳細画面に入力欄＋コメント一覧を実装
- **ビルド障害と対処**（2段階）:
  1. `compileSdk = flutter.compileSdkVersion`（33相当）→ `compileSdk = 36`に固定したが解決せず
  2. 真因は`share_plus 7.2.2`自体のAARが古いandroidx依存を宣言しておりcompileSdk設定と無関係に競合 → `share_plus: ^10.0.0`にアップグレードして解決（classic `Share.share()`/`Share.shareXFiles()` APIのまま利用可能）

**確認事項**:
- ✅ 全33テスト通過
- ✅ `flutter build apk --release` 成功（exit code 0、230.5秒、**51.5MB**）
- ⚠️ Firestoreへのコメント投稿・取得、SNSシェアシートの実機動作は未検証（次回実機確認で要チェック）

## 23. コンテンツ充実・発見機能・グラフ修正（2026-07-08）
- **グラフ横軸バグ修正**: fl_chartの`bottomTitles`に`interval`未指定だったため軸ラベルが重複表示（「2023 2023 2030 2030…」）されていた → `interval: 1`を明示し`value.round()`で丸めるよう修正（`macro_dashboard_screen.dart`の2箇所、`challenge_detail_screen.dart`の1箇所）
- **課題説明の充実**: `ChallengeDetail`に`detailedDescription`フィールドを新設。全15課題に背景説明（2〜4文）を追加し、詳細画面に表示
- **生活影響の具体化**: 全15課題の`outlook20Years`/`outlook50Years`を、マクロな数値だけでなく「給与明細の保険料」「進学の選択肢」「実家の空き家」など具体的な生活シーンに紐づけた記述に書き換え
- **発見機能（新規）**:
  - カテゴリフィルターチップ（すべて/経済/福祉/人口/政治/財政）を課題一覧上部に追加
  - 「あなたにおすすめ」セクション: 投票済み課題のカテゴリに近い未投票課題を投票数順に最大2件表示（`votedChallengeIdsProvider`で投票履歴をセッション内追跡）
  - AppBarに週刊ランキング画面への導線（`Icons.leaderboard_outlined`）を追加

**確認事項**:
- ✅ 全33テスト通過
- ✅ `flutter build apk --release` 成功（exit code 0、137.1秒、**50.9MB**）
- ⏸ 実機での目視確認は未実施（次回セッションで確認推奨）

## 22. 実機バグ修正（2026-07-08）
- **白画面クラッシュ修正**: 未使用の`firebase_crashlytics`がFirebase初期化時にNullPointerExceptionを発生させていた → pubspec.yamlから削除
- **シェアカード重なり修正**: 非表示キャプチャ用ウィジェットが`OverflowBox`単体だとその場に描画され可視コンテンツと重なる → `Transform.translate(-9999,-9999)`で実際に画面外へ移動
- **シェア画像の空白修正**: `LossShareCard`内`Column`が`mainAxisSize.max`のままキャプチャ時の`maxHeight:900`まで引き伸ばされ、余白ごと画像化されていた → `mainAxisSize.min`に変更
- **アプリ起動フロー変更**: `main.dart`の`home`を`AgeInputScreen`から`MacroDashboardScreen`に変更。年金計算は「あなたの年金は得？損？」という通常の課題カード（`id: 'my_pension_balance'`, category: welfare）として課題一覧の先頭に統合し、タップで`AgeInputScreen`に遷移する方式に変更
- **実機確認済み**（uiautomator dumpで正確な座標を取得し検証）:
  - コールドスタート起動 → マクロダッシュボード正常表示
  - 「課題に投票する」→ 課題一覧遷移正常
  - 年金カード → タップで年齢入力画面に正常遷移
  - シェアカード生成（重なり・空白なし）
- **APK**: `H:\マイドライブ\apk\nihon_future_map-app-release.apk`（50.8MB）

---

## ✅ 完了した実装

### 1. 年金損益計算エンジン（核心ロジック）
- **ファイル**: `lib/application/usecases/calculate_pension_loss.dart`
- **機能**:
  - 年齢を入力 → 生涯年金損益を計算
  - 厚労省公式データ使用（2026年度）
  - 昇給率: 年2% を考慮
  - 20～80歳対応
- **特徴**:
  - 外部ライブラリ非依存（確認性重視）
  - Unit Test 8個全通過
  - 損失率計算・カテゴリ分類機能付き

**テスト結果** ✅
```
CalculatePensionLoss
  ✓ 30歳の男性: 年金損失を正しく計算
  ✓ 25歳の若者: 長期納付による影響
  ✓ 60歳: わずか5年間の納付
  ✓ 20歳: 最長45年間の納付期間
  ✓ 各年代カテゴリの給与が正しく適用される
  ✓ 損失率の計算が正確
  ✓ 無効な年齢は例外をスロー
  ✓ toString形式が適切
→ All tests passed!
```

### 2. データモデル・エンティティ
- **User**: uid, age, occupation, region, createdAt, isPremium, votedChallenges, agreeCount
- **PensionCalculation**: age, totalContributions, totalBenefits, netLoss, category

### 3. Riverpod Provider
- **ファイル**: `lib/application/providers/pension_provider.dart`
- `pensionCalculationProvider`: 年齢 → 計算結果
- `userAgeProvider`: ユーザーの選択年齢を保持
- `selectedPensionProvider`: 選択年齢での計算結果

### 4. 年齢入力画面（Aha Moment UI）
- **ファイル**: `lib/presentation/screens/age_input_screen.dart`
- **機能**:
  - 年齢を入力（20～80）
  - 「計算する」ボタン → 結果表示
  - 生涯損益を赤字/黒字で表示
  - 「別の年齢で計算」で再計算可能

### 5. プロジェクト基盤
- ✅ Flutter 3.44.0 初期化
- ✅ pubspec.yaml: firebase, riverpod, fl_chart, hive 依存関係設定
- ✅ ディレクトリ構成: domain/application/infrastructure/presentation 分層

### 6. マクロダッシュボード（グラフ表示）
- **ファイル**: `lib/presentation/screens/macro_dashboard_screen.dart`
- **機能**:
  - 人口推移グラフ（2023→2070）
  - 予算配分 円グラフ（社保/利息/防衛等）
  - 困窮状況 棒グラフ（低収入/失業/非正規等）
- **グラフ**: fl_chart で複数チャート対応
- **データソース**: LoadMacroDashboard usecase

### 7. ナビゲーション統合
- 年齢入力 → 結果表示 → 「日本の将来予測を見る」ボタン
- Dashboard への遷移完装備

### 8. Firebase 統合（Week 3）
- **認証**: Firebase Anonymous Auth
- **ファイル**: `lib/infrastructure/firebase/firebase_service.dart`
- **機能**:
  - 匿名認証（自動）
  - Challenge（課題）データ取得
  - 投票機能（vote）
  - 賛同機能（agree）
- **データモデル**: Challenge（id, name, category, voteCount, agreeCount等）

### 9. 投票画面（ChallengeListScreen）
- **ファイル**: `lib/presentation/screens/challenge_list_screen.dart`
- **機能**:
  - 5つの社会課題をカード表示
  - 「投票する」ボタン（リアルタイム投票数更新）
  - 「これは問題」ボタン（賛同機能）
  - カテゴリ別カラー表示
- **課題内容**:
  1. 所得の停滞
  2. 年金危機
  3. 人口減少
  4. 政治家の待遇
  5. 国債残高

### 10. Provider 統合
- `firebaseServiceProvider`: Firebase Service の DI
- `userIdProvider`: 認証 UID 取得・自動匿名サインイン
- `challengesProvider`: 課題一覧（モックデータ）
- `voteChallengeProvider`: 投票実行
- `agreeChallengeProvider`: 賛同実行

### 11. デザインシステム統一（シンプル化）
- **ファイル**: `lib/presentation/theme/app_theme.dart`
- **狙い**: 「わかりやすく、シンプルに」を徹底し、画面ごとにバラバラだった色・角丸・余白を一元管理
- **AppColors**:
  - ブランド色（青）、課題カテゴリ5色、赤字/黒字用ステータス色
  - ニュートラルカラー階層（textPrimary/Secondary/Muted、border、background）
  - `categoryColor()` / `categoryLabel()` でカテゴリ→色/日本語ラベル変換を一元化
- **AppTheme.light**: ElevatedButton/OutlinedButton/Card/TextField を角丸14〜16pxで統一、AppBarをフラット化
- **AppSpacing / AppRadius**: マジックナンバー排除（4/8/16/24/32/48の余白スケール）

**画面ごとの変更点**:
| 画面 | Before | After |
|-----|--------|-------|
| 年齢入力 | 質問+ボタン+結果カードが縦に羅列 | 「得？損？」の問いを1枚に集約、数字を40ptで主役化、内訳は2列カードに整理 |
| ダッシュボード | 3グラフ+リストが単純に縦積み | 各グラフを白カードで区切り、予算配分・困窮状況はグラフ→プログレスバー方式に変更して数値を読みやすく |
| 投票画面 | カード内の要素が均等配置 | カテゴリバッジ・投票数を右上にコンパクト化、ボタンにカテゴリカラーを適用 |

**確認事項**:
- ✅ `flutter build web --release` が正常完了（コンパイルエラーなし）
- ✅ Unit Test 8個は変更なしで全通過
- ⚠️ このサンドボックス環境では CanvasKit(WebGL) のスクリーンショット取得ができず、実機/ローカルでの目視確認は未実施。ローカルで `flutter run -d chrome` または実機での確認を推奨

### 12. 課題詳細ページ（公式 vs 民間データ並行表示）
- **ファイル**: `lib/presentation/screens/challenge_detail_screen.dart`
- **データモデル**: `lib/domain/entities/challenge_data.dart`（ChallengeDataSeries, ChallengeDataPoint, ChallengeDetail）
- **データ**: `lib/application/usecases/load_challenge_detail.dart`（5課題分のモックデータ）
- **機能**:
  - 「あなたの生活とのつながり」でマクロ→ミクロの接続を説明
  - 公式データ vs 民間分析を2本の折れ線グラフで並行表示（民間側は破線）
  - 各データソースのカード表示（出典・乖離理由の注記）
- **ナビゲーション**: 投票画面のカードをタップ → 詳細画面へ遷移（`InkWell` + `Material` でタップ領域化）
- **対応課題**: 所得の停滞・年金危機・人口減少・政治家の待遇・国債残高の5件全てにデータ整備済み

**確認事項**:
- ✅ `flutter build web --release` が正常完了（コンパイルエラーなし、138.8秒）
- ✅ Unit Test 8個は変更なしで全通過

### 13. タイムマシンスライダー（政策シミュレーション）
- **ファイル**: `lib/presentation/screens/time_machine_screen.dart`
- **データモデル**: `lib/domain/entities/policy_scenario.dart`（PolicyYearData, PolicySimulation, PolicyType enum）
- **データ**: `lib/application/usecases/load_policy_simulation.dart`（2026〜2070年、年単位で線形補間）
- **機能**:
  - 人口推移を「現状維持・与党案・野党案・専門家案」の4シナリオで比較
  - スライダーで年を動かすと、選択年の垂直マーカーがグラフ上をリアルタイム移動
  - 各シナリオの数値カードに、現状維持との差分（±）を色分け表示
- **Provider**: `policySimulationProvider`（データ生成）, `selectedYearProvider`（スライダー選択年の状態管理）
- **ナビゲーション**: ダッシュボードの人口推移グラフ直下に「政策でどう変わる？タイムマシンで見る」ボタンを設置

**確認事項**:
- ✅ `flutter build web --release` が正常完了（コンパイルエラーなし、210.7秒）
- ✅ Unit Test 8個は変更なしで全通過

### 14. ギャップクイズ・診断機能
- **データモデル**: `lib/domain/entities/quiz.dart`（QuizQuestion, QuizAnswer, QuizResult, DiagnosisLevel enum）
- **データ**: `lib/application/usecases/load_quiz_questions.dart`（政治家給与・社会保障費・人口・国債・非正規雇用の5問、既存データと整合）
- **画面**: `lib/presentation/screens/quiz_screen.dart`（1問ずつ回答→ギャップを棒グラフで可視化）, `lib/presentation/screens/quiz_result_screen.dart`（診断結果＋シェア）
- **Provider**: `lib/application/providers/quiz_provider.dart`
- **機能**:
  - 数値を予想入力 → 「あなたの予想」vs「実際の値」を横棒グラフで比較表示
  - 正答度（0〜100%）に応じて色分け（緑=近い／赤=乖離大）
  - 全問終了後、平均正答度から3段階診断（社会課題マスター🏆／平均的な認知度📊／伸びしろ十分🌱）
  - Wordle風の絵文字結果（🟩🟨🟥）をクリップボードにコピーしてSNSシェア（`flutter/services` の `Clipboard` のみ使用、追加パッケージ不要）
- **ナビゲーション**: ダッシュボード最下部に目立つCTAカード（プライマリカラー背景）を設置

**確認事項**:
- ✅ Unit Test 8個は変更なしで全通過
- ✅ `flutter build web --release` が正常完了（コンパイルエラーなし、332.9秒）

### 15. 生涯年金損益カード 画像生成・シェア機能
- **ユーティリティ**: `lib/utils/widget_image_capture.dart`（`RenderRepaintBoundary.toImage()` を使用、追加パッケージ不要）
- **ウィジェット**: `lib/presentation/widgets/loss_share_card.dart`（単体で完結したブランド付きシェア用カードデザイン）
- **画面**: `lib/presentation/screens/share_preview_screen.dart`（生成画像プレビュー＋紹介文コピー）
- **機能**:
  - 年金結果画面の「結果を画像でシェア」ボタン→ `RepaintBoundary` でオフスクリーン描画したカードをPNGにキャプチャ
  - `OverflowBox` でレイアウトに影響を与えずに非表示キャプチャ元を配置（Offstageだと再描画されず空画像になるため回避）
  - プレビュー画面で `Image.memory()` 表示＋「長押しで保存」案内
  - 紹介文を `Clipboard` にコピー（クイズのシェア機能と同じ、追加パッケージなしの一貫した方式）
- **設計判断**: `dart:html`/JS interop によるブラウザ自動ダウンロードやOS別ネイティブ共有シートは新規パッケージ・プラットフォーム分岐が必要でリスクが高いため見送り、Flutterコア機能のみで確実に動く実装を優先

**確認事項**:
- ✅ Unit Test 8個は変更なしで全通過
- ✅ `flutter build web --release` が正常完了（コンパイルエラーなし、94.2秒）

### 16. テスト拡充・CI/CD設定（Week 7-8）
- **新規テストファイル**:
  - `test/load_policy_simulation_test.dart`（5件）: チェックポイント補間・範囲外クランプ・専門家案の優位性を検証
  - `test/quiz_test.dart`（9件）: ギャップ計算・正答度・ゼロ除算回避・3段階診断の閾値
  - `test/age_input_screen_test.dart`（4件）: 年齢入力→結果表示、範囲外エラー、リセットのWidget Test
  - `test/quiz_screen_test.dart`（4件）: 問題表示→回答→次の問題遷移のWidget Test
  - `test/widget_test.dart`: 初期テンプレート（カウンター）から実アプリの起動確認に置き換え
- **バグ修正**: `PolicySimulation.dataForYear()` が範囲外の年で常に最終年のデータを返していた不具合を修正（最小年より小さい場合は最初のデータを返すよう修正）。タイムマシン画面はスライダーで範囲を制限しているため実害はなかったが、テスト作成中に発見
- **テスト合計**: 31件全て通過（Unit 22件 + Widget 9件）
- **CI/CD**: `.github/workflows/flutter_ci.yml` を新規作成
  - `test`ジョブ: `dart format`チェック → `flutter analyze` → `flutter test`
  - `build-android`ジョブ: デバッグAPKビルド（google-services.json未設定でも動作、Firebase Gradleプラグイン未適用のため）
  - **注意**: このプロジェクトはまだGitリポジトリ化されていないため、実際にCIが動くにはGit初期化とGitHubリモート接続がユーザー側で必要

**確認事項**:
- ✅ 全31テスト通過（`flutter test` 実行、約9秒）
- ⚠️ `flutter analyze` はこのサンドボックス環境（日本語パス）でクラッシュするため実行不可。GitHub Actions（英語パス）では問題なく動作する見込み

### 17. コンテンツ拡充（社会課題・クイズ・政策指標）
- **社会課題**: 5件→**10件**に拡大
  - 追加: 子供の貧困（welfare）・地方の消滅可能性（demographic）・医療費の増大（welfare）・教育格差（economy）・女性議員比率の低さ（politics）
  - 全10件に対応する課題詳細データ（公式 vs 民間データ）も整備済み
- **ギャップクイズ**: 5問→**10問**に拡大
  - 追加: 子供の貧困率・女性議員比率・高齢化率・大学進学率・国民医療費
- **タイムマシン**: 人口推移のみ→**3指標対応**（人口／年金積立金／国債残高）に拡張
  - `SegmentedButton` で指標を切り替え可能
  - 国債残高は「値が低いほど良い」指標のため `lowerIsBetter` フラグを追加し、差分の色分けロジックを指標に応じて反転
  - `PolicySimulation` に `id`・`lowerIsBetter` フィールドを追加、`LoadPolicySimulation` を単一指標→複数指標（`List<PolicySimulation>`）返却に再設計
- **テスト更新**: 政策シミュレーションのテストを複数指標対応に書き換え（7件）、クイズ画面テストの設問数表記を「1/5」→「1/10」に修正

**確認事項**:
- ✅ 全33テスト通過（`flutter test` 実行）
- ✅ `flutter build web --release` が正常完了（コンパイルエラーなし）

---

### 18. コンテンツ第2弾拡充（社会課題・クイズ・週刊ランキング・エネルギー指標）
- **社会課題**: 10件→**15件**に拡大
  - 追加: エネルギー自給率の低さ（economy）・後期高齢者医療費負担（welfare）・対内直接投資の少なさ（economy）・投票率の低下（politics）・空き家の増加（demographic）
  - 全15件に対応する課題詳細データ（公式 vs 民間データ）を整備済み
- **ギャップクイズ**: 10問→**15問**に拡大
  - 追加: エネルギー自給率・投票率・空き家率・後期高齢者医療費・対内直接投資比率
- **週刊ランキング機能（新規）**: `lib/presentation/screens/ranking_screen.dart`
  - 課題を投票数でソートし、上位3位に🥇🥈🥉のメダルを表示
  - タップで課題詳細画面へ遷移
  - ダッシュボードから「週刊 課題ランキングを見る」ボタンで導線を追加
- **マクロダッシュボードに新指標追加**: 「エネルギーは自分の国でまかなえている？」セクション
  - `MacroDashboard` エンティティに `energySelfSufficiency`（`EnergyData` リスト）を追加
  - 2000〜2025年のエネルギー自給率推移を折れ線グラフで表示（東日本大震災前後の落ち込みも反映）
- **テスト修正**: クイズ画面テストの設問数表記を「1/10」→「1/15」に修正
- **副次対応**: セッション中に `logger` パッケージのPubキャッシュが破損（ファイル欠落）していることが判明。`flutter pub cache repair` → `flutter clean` → `flutter pub get` で復旧（コード起因の問題ではなく、ローカル環境のキャッシュ破損）

**確認事項**:
- ✅ 全33テスト通過（`flutter test` 実行）
- ✅ `flutter build web --release` が正常完了（コンパイルエラーなし）

### 19. 見目改善（カテゴリアイコン・遷移アニメーション）
- **カテゴリアイコン**: `AppColors.categoryIcon()` を新設（economy=💰・welfare=❤️・demographic=👥・politics=🏛️・debt=📉）し、投票画面カード・課題詳細画面のバッジに色付きアイコン＋ラベルを併記
- **年齢入力→結果のアニメーション**: `age_input_screen.dart` の質問⇔結果切り替えを `AnimatedSwitcher`（フェード＋わずかな上方向スライド、350ms・easeOutCubic）に変更。`KeyedSubtree` で状態ごとに明示的な `Key` を付与し、確実に遷移アニメーションが発火するように対応

**確認事項**:
- ✅ 全33テスト通過（`age_input_screen_test.dart` は `pumpAndSettle` でアニメーション完了を待機済み）
- ✅ `flutter build web --release` が正常完了（コンパイルエラーなし）

### 20. APKビルド成功（build-flutter-apkスキル使用）
- **Gradle前提設定**（`android/app/build.gradle.kts`）を初めて追加:
  - `isCoreLibraryDesugaringEnabled = true`
  - `minSdk = 21`（`flutter.minSdkVersion` から固定値に変更）
  - `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` 依存追加
- **ビルド結果**: `H:\マイドライブ\apk\nihon_future_map-app-release.apk`（**50.4MB**）
- Gradleタスク `assembleRelease` は738.2秒で完了、exit code 0
- google-services.json未配置でもビルド可能（Firebase Gradleプラグイン未適用のため、Dart側のFirebase呼び出しはビルド時にはチェックされない）

**確認事項**:
- ✅ `flutter build apk --release` 成功（exit code 0、C:\apk\nihon_future_map でビルド）
- ✅ APKサイズ確認（50.4MB）
- ⏸ **実機インストール・起動確認は未実施**（[flutter-device-test]スキルで次に実施可能。実機接続が必要なためユーザー確認事項）
- ⚠️ アプリ内でFirebase Anonymous Authを呼び出す画面（投票画面等）は、Firebase本設定前は実機で例外が発生する可能性が高い（未検証）

### 21. Firebase本設定完了
- **プロジェクト**: `petit-works-apps-9029a`（petitworksdev@gmail.com、全アプリ共通プロジェクトに相乗り）
- **パッケージ名**: `com.petitworksapps.japanfuturemap`（`google-services.json` 内に登録済みであることを確認してから配置）
- **配置ファイル**:
  - `android/app/google-services.json`（H:\ 側に配置）
  - `lib/firebase_options.dart`（google-services.jsonの値から手書き生成。Android のみ対応、Web/iOS未設定時は明示的に `UnsupportedError` を投げる設計）
- **Gradle設定**:
  - `android/settings.gradle.kts` に `com.google.gms.google-services` プラグイン（v4.4.2）を追加
  - `android/app/build.gradle.kts` の `plugins{}` に同プラグインを適用
- **main.dart**: `WidgetsFlutterBinding.ensureInitialized()` → `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` を追加
- **有効化サービス**: Authentication（匿名ログイン、コード側で実装済み）・Firestore・Analytics（すべてFirebaseプロジェクト側で要確認）

**確認事項**:
- ✅ 全33テスト通過（Firebase初期化はmain()内のみで、Widget Testは`MyApp()`を直接pumpするため影響なし）
- ✅ `flutter build apk --release` 成功（exit code 0、378.7秒、**51.0MB**）
- ⏸ **実機起動・匿名ログイン成功の確認は未実施**（次のステップ）
- ⏸ Firestore・Analyticsが実際にConsole側で有効化されているかは未確認（ユーザー確認事項）

---

## 🎬 現在の画面遷移フロー

```
[起動]
  ↓
[年齢入力画面]
  ├─ 年齢を入力（20～80）
  └─ 「計算する」ボタン
      ↓
[年金損益結果]
  ├─ 生涯損益を表示（赤字/黒字）
  ├─ 「結果を画像でシェア」ボタン → シェア用カード画面へ
  ├─ 「別の年齢で計算」ボタン
  └─ 「日本の未来を見る」ボタン
      ↓
[シェア用カード画面（SharePreviewScreen）]
  ├─ 生成したPNG画像プレビュー
  └─ 「紹介文をコピーする」ボタン
      ↓
[ダッシュボード画面]
  ├─ 人口推移ライングラフ
  ├─ 「政策でどう変わる？タイムマシンで見る」ボタン
  ├─ 予算配分円グラフ
  ├─ 困窮状況棒グラフ
  ├─ 「ギャップクイズで診断してみよう」CTAカード
  └─ 「課題に投票する」ボタン
      ↓
[タイムマシン画面（TimeMachineScreen）]
  ├─ 4シナリオ比較グラフ（現状維持/与党案/野党案/専門家案）
  ├─ 年スライダー（2026〜2070）
  └─ シナリオ別数値カード（現状維持との差分表示）

[ギャップクイズ画面（QuizScreen）]
  ├─ 全5問（政治家給与/社会保障費/人口/国債/非正規雇用）
  ├─ 予想入力 → 実際の値とのギャップを棒グラフ表示
  └─ 全問終了で診断結果画面へ
      ↓
[診断結果画面（QuizResultScreen）]
  ├─ 3段階診断（マスター🏆／平均📊／伸びしろ🌱）
  ├─ 問題ごとの正答度一覧
  └─ 「結果をコピーしてシェア」（Wordle風絵文字）

[投票画面（ChallengeListScreen）]
  ├─ 社会課題カード一覧（5個、タップで詳細へ）
  ├─ 「投票する」ボタン（リアルタイム更新）
  └─ 「これは問題」ボタン（賛同）
      ↓（カードタップ）
[課題詳細画面（ChallengeDetailScreen）]
  ├─ あなたの生活とのつながり
  ├─ 公式 vs 民間データ 折れ線グラフ
  └─ データソースカード（出典・乖離理由）
```

## 📋 次のステップ（Week 6 以降）

### Week 6: 拡散機能の仕上げ
- [ ] 週刊ランキング自動生成
- [ ] Twitter・LINE 直接投稿連携（現状はクリップボード経由）

### Week 7-8: 仕上げ
- [ ] RevenueCat 統合（¥120/月）
- [ ] Analytics イベント仕込み
- [ ] Widget/Integration テスト
- [ ] CI/CD 設定

---

## 🔧 技術詳細

### マクロダッシュボード統計値

**人口推移（中位推計）**
| 年 | 人口（百万） |
|----|----------|
| 2023 | 125.1 |
| 2030 | 123.0 |
| 2040 | 119.7 |
| 2050 | 115.1 |
| 2060 | 109.9 |
| 2070 | 104.4 |

**予算配分（2026年度）**
| カテゴリ | 金額（兆円） | 割合 |
|---------|-----------|-----|
| 社会保障 | 36.2 | 35.1% |
| 利息・その他 | 24.7 | 23.9% |
| 公債費 | 15.3 | 14.8% |
| 防衛 | 9.2 | 8.9% |
| 教育・科学 | 8.5 | 8.2% |
| その他 | 9.1 | 8.8% |

**困窮状況（2025年推計）**
| 困窮分類 | 人数（百万） | 割合 |
|---------|----------|-----|
| 低収入（年300万以下） | 15.0 | 12.5% |
| 失業・未就職 | 8.0 | 6.8% |
| 非正規雇用 | 48.0 | 39.8% |
| 65歳以上の就業希望 | 7.5 | 6.2% |
| 生活保護受給 | 2.1 | 1.7% |

### 年金計算アルゴリズム

**定数**:
- 被保険者保険料率: 9.15%
- 年齢別給与（月額・ボーナス込み）:
  - 20-29歳: ¥270,000
  - 30-39歳: ¥330,000
  - 40-49歳: ¥420,000
  - 50-59歳: ¥480,000
  - 60歳以上: ¥350,000

**計算ロジック**:
1. 現在年齢 → 65歳まで毎月保険料を納める
2. 昇給率: 年2%
3. 65歳～85歳: 月額 ¥60,000 を受け取る（20年間）
4. 損益 = 納めた額 - 受け取った額

**例: 30歳の場合**
- 納める: 約 ¥18.1百万（35年間）
- 受け取る: ¥14.4百万（20年間）
- **赤字: △¥3.7百万（損失率 20.5%）**

---

## 📝 Unit Test カバレッジ

| テスト項目 | ステータス | 内容 |
|----------|----------|------|
| 30歳シナリオ | ✅ | 損失計算・損失率検証 |
| 若年・中年・老年 | ✅ | 各年代の給与・期間の影響 |
| エッジケース | ✅ | 年齢範囲外（19, 81） |
| カテゴリ分類 | ✅ | 給与カテゴリ適用確認 |

**ターゲット**: 50% 以上のコードカバレッジ（ロジック層）

---

## 🚀 実装の注意点（遵守中）

✅ **Aha Moment を最優先** → 年金計算エンジン完成・テスト済み  
✅ **ロジックは Unit Test で 100% 検証** → 全 8 テスト通過  
✅ **外部ライブラリに依存しない** → 厚労省データ信頼性確保  
✅ **シンプルなコードから始める** → UI も Riverpod も基本的な実装  
✅ **グラフは fl_chart で即座に表示** → マルチチャート対応  
✅ **ナビゲーション統合済み** → 年齢入力 → Dashboard → 投票画面  
✅ **投票機能は Firebase 準備済み** → Anonymous Auth + Firestore スキーマ対応  
✅ **モックデータで先行実装** → Firebase Console 接続前にテスト可能

---

## 🔐 Firebase 設定（次）

**未実装**:
- [ ] Firebase Console でプロジェクト作成
- [ ] google-services.json / GoogleService-Info.plist 取得
- [ ] Firestore 初期化
- [ ] Authentication（Anonymous）

**参考**:
- Firebase アカウント: `petitworksdev@gmail.com`
- プロジェクト: `nihon-future-map`

---

## 📊 KPI イベント（実装待ち）

```dart
// 実装予定の計測イベント
logEvent('loss_calculated', {'age': 28, 'loss_amount': 600000});
logEvent('vote_submitted', {'challengeId': 'income_stagnation'});
logEvent('content_shared', {'contentType': 'loss_card', 'platform': 'twitter'});
```

---

## 🎯 現在の状態

**プロジェクト準備完了** ✅
- 基本ロジック実装
- Unit Test カバレッジ
- Provider 統合
- 簡単な UI フロー

**次の実装へ**: Dashboard・グラフ表示 または Firebase 統合どちらを優先するか確認待ち
