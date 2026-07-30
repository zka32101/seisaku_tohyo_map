# 日本の未来マップ — ユーザー実施手順

Claude側では完結できない、お手元での作業手順をまとめています。

---

## 0. iOS版のビルドについて（Windows環境では実行不可）

このプロジェクトはWindows環境で開発しているため、iOSアプリのビルドには以下がすべて必要です。
コード側の準備（Bundle ID統一・Info.plist整備・firebase_options.dartのiOS分岐）は完了済みです。

1. **macOS環境の用意**（実機Mac、またはCodemagic/Bitrise等のクラウドMacビルドサービス）
2. **Apple Developer Program登録**（年間$99）とApp Store Connectでのアプリ登録
   （Bundle ID: `com.yourwish.japanfuturemap`で新規App IDを作成）
   - Capabilitiesは「Push Notifications」を有効化（`firebase_messaging`のため必須）。
     In-App Purchase（寄付機能）はApp IDにデフォルトで有効なため追加設定不要
3. **Firebase Consoleに iOS アプリを追加**
   - https://console.firebase.google.com をfunvestment1@gmail.comで開く
   - プロジェクト「petit-works-apps-9029a」→「アプリを追加」→ iOS
   - Bundle ID: `com.yourwish.japanfuturemap`
   - ダウンロードした `GoogleService-Info.plist` を `ios/Runner/` に配置
   - 取得した値（apiKey・appId等）を `lib/firebase_options.dart` の `ios` ブロックに追記
     （ひな形コメントを用意済み）
4. プッシュ通知を使う場合は、Apple Developer ConsoleでAPNs認証キーを発行し、Firebase Consoleに登録
5. アプリアイコン・起動画面（LaunchScreen）は現状Flutterデフォルトのまま。iOS向けに差し替えが必要
6. 上記が揃った状態で、Mac側で `flutter build ios` を実行

### GitHub Actionsで実行する場合
`.github/workflows/flutter_ci.yml` に `build-ios` ジョブを追加済み（`macos-latest`で
`flutter build ios --release --no-codesign` を実行し、コンパイルが通るかを確認するだけの内容）。
リポジトリは`petitworksappsdev-hash/nihon_future_map`にpush済み（軽量アカウント、
コスト最適化のため`build-ios`はPRまたは手動実行`workflow_dispatch`でのみ起動）。
1. GitHubの「Actions」タブでワークフローの実行結果を確認
2. 手動実行する場合は Actions タブ → Flutter CI → 「Run workflow」
3. GoogleService-Info.plist取得後は、内容をBase64化してActions Secretsに登録し、
   ワークフロー内のコメントを参考に配置ステップを追加

---

## 0.1. Appleへのアプリ登録手順

「0. iOS版のビルドについて」の前提となる、Apple側での登録作業を順番にまとめています。
**すべてMac不要でブラウザから行えます**（macOSが必要になるのは実際のビルド・提出時のみ）。

### Step 1: Apple Developer Program登録
1. https://developer.apple.com/programs/ にアクセスし、Apple ID でサインイン
   （個人 or 法人名義を選択。年間 **$99**）
2. 登録には1〜2日かかる場合があります（本人確認・法人の場合は追加審査あり）

### Step 2: App IDの作成（Bundle IDの登録）
1. https://developer.apple.com/account/resources/identifiers/list を開く
2. 「+」→「App IDs」→「App」を選択
3. Description: `Nihon Future Map`（任意の管理用名称）
4. Bundle ID: **Explicit** を選択し、`com.yourwish.japanfuturemap` と入力
   （コード側で既にこの値に統一済み）
5. Capabilities（機能）で以下にチェック:
   - ✅ **Push Notifications**（`firebase_messaging`のため必須）
   - **In-App Purchase**（寄付機能）はチェック不要 — 全App IDにデフォルトで有効
6. 「Continue」→「Register」で登録完了

### Step 3: App Store Connectで新規アプリを登録
1. https://appstoreconnect.apple.com/apps を開く（Apple Developer Program登録完了後に利用可能）
2. 「+」→「新規App」
3. プラットフォーム: iOS
4. 名前: 「日本の未来マップ」（またはApp Store掲載名。他アプリと重複不可）
5. プライマリ言語: 日本語
6. Bundle ID: Step 2で作成した `com.yourwish.japanfuturemap` を選択
7. SKU: 任意の一意な文字列（例: `nihonfuturemap001`。ユーザーには非表示）
8. 「作成」で登録完了

### Step 4: プッシュ通知用のAPNs認証キーを発行
1. https://developer.apple.com/account/resources/authkeys/list を開く
2. 「+」→ キー名を入力（例: `Nihon Future Map APNs Key`）
3. 「Apple Push Notifications service (APNs)」にチェック → 「Continue」→「Register」
4. `.p8`ファイルをダウンロード（**再ダウンロード不可のため必ず保管**）。
   あわせて画面に表示される **Key ID** と、Apple Developerアカウントの **Team ID**
   （右上のメンバーシップ詳細で確認可）も控えておく
5. Firebase Console → プロジェクト設定 → Cloud Messaging → Apple アプリの設定 →
   「APNs 認証キー」に、上記の`.p8`ファイル・Key ID・Team IDをアップロード

### Step 5: 寄付機能（App内課金）の商品登録
「3.7. 寄付機能（App Store課金）の商品登録（iOS）」を参照（Step 3のアプリ登録完了後に実施）

### Step 6: 税務・銀行・連絡先情報の入力（有料機能を使う場合は必須）
App Store Connect → 契約/税金/口座情報（Agreements, Tax, and Banking）で、
銀行口座・税務情報を入力しないと、Step 5のApp内課金が承認されません
（アプリ自体を無料で審査提出するだけならこの手順は不要）

### Step 7: アプリアイコン・スクリーンショット等のストア掲載情報を準備
- アプリアイコン: 1024×1024px（現状Flutterデフォルトのまま、差し替えが必要）
- スクリーンショット: 主要デバイスサイズ（6.9インチ・6.5インチ等）ごとに数枚
- プライバシーポリシーURL、アプリの説明文、キーワード等

### Step 8: Mac環境でのビルド・提出
「0. iOS版のビルドについて」の手順（`flutter build ipa`、Xcode/Transporterでのアップロード、
または上記GitHub Actionsのworkflow_dispatch実行）に進む
4. 実機インストール・App Store配信まで行うには、Apple Developer証明書・プロビジョニング
   プロファイルをSecretsに登録し、`flutter build ipa` ＋ fastlane等でのアップロード工程を追加

---

## 1. 実機での動作確認（最優先）

**APKファイル**: `H:\マイドライブ\apk\nihon_future_map-app-release.apk`（51.5MB）

### 手順
1. Androidスマホを **USBケーブルでPCに接続**
2. スマホ側で「USBデバッグを許可しますか？」のダイアログが出たら **許可**
3. 私（Claude）に「インストールして」と伝えていただければ、`adb install` で自動インストールします
   - または手動でAPKファイルをスマホに転送してインストールも可能

### 確認していただきたいポイント
- [ ] 起動直後にマクロダッシュボード（人口グラフ等）が表示される
- [ ] 「課題に投票する」→ 一覧に「あなたの年金は得？損？」カードが最上部に表示される
- [ ] 年金カードをタップ→年齢入力→結果表示→「結果を画像でシェア」で正しい画像が生成される
- [ ] 「結果を画像でシェア」→「画像をシェアする」でLINE等の共有シートが開く
- [ ] 課題詳細画面で「みんなの声」欄にコメント投稿できる（Firestore書き込みの実地確認）
- [ ] コメントの「いいね」ボタンを押すと件数が増え、3件以上で「人気のコメント」表示になる
- [ ] コメント欄に「死ね」等のNGワードやURLを入力すると投稿がブロックされる
- [ ] 課題詳細画面の「あなたなら、どの対策案を選ぶ？」で対策案を1つ選ぶと、全員分の投票割合（%）が表示される
- [ ] 機内モードにすると画面上部に「オフラインです」バナーが表示され、機内モード解除で消える
- [ ] 一覧画面のメガホンアイコン →「みんなの提案」→「提案する」で新しい課題を投稿できる
- [ ] 提案に投票すると得票数が増え、20票を超えると「正式課題候補」セクションに移動する
- [ ] 起動時に通知の許可ダイアログが表示され、「許可」するとプッシュ通知を受け取れる
- [ ] ダッシュボード右上のハートアイコン、または「応援する」ボタンから寄付画面が開く（※Google Play課金の商品未登録の間は「準備中です」と表示されるのが正しい挙動）
- [ ] ギャップクイズで正答度70%以上を取ると「上級問題に挑戦する」ボタンが出る
- [ ] タイムマシン画面で5指標（人口/年金積立金/国債残高/医療費/空き家率）が横スクロールで選べる
- [ ] ダッシュボード右上の人物アイコン →「マイページ」で、投票・提案などの活動件数と実績バッジが表示される
- [ ] 年金診断・課題投票・コメント投稿などを行うと、マイページの件数と実績バッジがリアルタイムで増える
- [ ] 初めて実績バッジを獲得する操作（例: 初めての年金診断）を行うと、その場でお祝いポップアップが表示される
- [ ] 課題一覧画面の「課題だけじゃない」バナーから「良くなっていること」画面が開き、4件のグラフ付き改善事例が表示される
- [ ] 「国債残高」「男女の賃金格差」「エネルギー自給率」「投票率の低下」の課題詳細画面、および「良くなっていること」の
      再エネ・女性就業率の項目に「世界との比較」（他国との横棒グラフ）が表示される
- [ ] アプリを再起動しても、マイページの活動履歴が消えずに残っている（端末ローカル保存の確認）
- [ ] 課題詳細画面のAppBar下に「データ／将来／賛同度／国会／世界／対策案／声」のチップメニューが表示され、
      タップすると対応するセクションまでスムーズにスクロールする（該当データがない課題では「国会」「世界」チップが非表示になる）
- [ ] 課題詳細画面を下にスクロールすると、右下に「トップに戻る」の丸いボタンが出現し、押すと画面上部に戻る
- [ ] 課題一覧画面のグリッドアイコン（「全体を俯瞰する」）から、経済／福祉／人口／政治／財政の
      カテゴリ見出し＋「良くなっていること」がすべて常時表示され、上部のジャンプチップから
      該当セクションへスムーズスクロールできる
- [ ] アプリ全体で、漢字が中国語風の字形（例: 直・骨など）にならず、正しい日本語の字形で表示される
      （Noto Sans JPフォント適用の確認。初回起動時はフォントのダウンロードに数秒かかる場合がある）
- [ ] 課題一覧・俯瞰マップの先頭に「政治構造」カテゴリ（ティール色）が表示され、15件の課題
      （シルバー民主主義／労働生産性の低さ／未婚化・晩婚化／改革の先送り体質／官僚機構の影響力（財務省など）／
      政治とカネ／報道と権力の距離／小選挙区制と死票の多さ／天下りの構造／中央集権と地方の財源不足／
      政策評価・検証の甘さ／一票の格差／世襲政治／縦割り行政／官邸主導と「忖度」の構造）が並び、
      詳細画面でグラフ・見通し・賛否両論の記述が表示される
- [ ] 「官僚機構の影響力（財務省など）」など政治的にセンシティブな課題の詳細が、陰謀論調ではなく
      批判と擁護の両論併記になっていることを確認（公開前のトーンチェック）
- [ ] 経済・福祉・人口・政治・財政の各カテゴリに新規課題が2件ずつ追加されていることを確認
      （非正規雇用／開業率の低さ／介護人材不足／ひとり親家庭の貧困／東京一極集中／外国人との共生／
      地方議会のなり手不足／選挙供託金の高さ／防衛費増額の財源／特別会計の不透明さ）
- [ ] 直近追加した政治構造・全カテゴリ拡充の課題（計25件）すべてで「あなたなら、どの対策案を選ぶ？」
      に3つの選択肢が表示され、投票できることを確認（年金診断ツールを除く）

**⚠️ 実機操作中は、私が同時にadb操作をすると誤タップの原因になります。** 実機を触っている間は「今操作中です」とお知らせいただけると助かります。

---

## 2. Firebase Console 確認

**アカウント**: funvestment1@gmail.com（2026-07-08〜、全アプリ共通の新方針）
**プロジェクト**: `petit-works-apps-9029a`（当面はこのまま。将来funvestment1側に移行する可能性あり）

### 確認手順
1. https://console.firebase.google.com を funvestment1@gmail.com でログインして開く
   - もしこのアカウントにプロジェクト `petit-works-apps-9029a` が見えない場合は、petitworksdev@gmail.com側にアクセス権があるままの可能性があります。どちらのアカウントで管理すべきか教えてください
2. プロジェクト `petit-works-apps-9029a` を選択
3. 左メニュー **Authentication** → 「Sign-in method」で **匿名（Anonymous）** が有効になっているか確認
   - 無効なら「有効にする」をクリック
4. 左メニュー **Firestore Database** →実機で投票・コメントを試した後、`challenges` コレクション配下にデータが実際に書き込まれているか確認
   - 現在は**テストモード**のセキュリティルールの可能性が高いです。本番運用前には制限が必要です（後述）

---

## 2.5. プッシュ通知の送信方法

週刊ランキング更新のお知らせなど、運営からユーザーへの通知は **Firebase Console から手動送信** する運用です
（Cloud Functionsによる自動配信は今回未実装のため、送信したいタイミングで都度Consoleから送る形になります）。

### 手順
1. Firebase Console → 左メニュー **Engage** → **Messaging** を開く
2. 「最初のキャンペーンを作成」→「通知」を選択
3. タイトル・本文を入力
4. 配信対象で **「トピック」** を選び、`weekly_updates` を指定
   （アプリ起動時に全ユーザーがこのトピックを自動購読する設計）
5. 即時配信 or 予約配信を選んで送信

### 注意点
- アプリが**フォアグラウンド（起動中）**の場合、システム通知トレイには表示されず、アプリ内に
  スナックバー（画面下部の帯）で表示される仕様です（Androidの標準挙動に合わせた実装）
- アプリが**バックグラウンド/終了状態**の場合は、通常の通知トレイに表示されます
- Android 13以降は初回起動時に通知許可ダイアログが表示され、ユーザーが拒否すると通知は届きません

---

## 3. Firestoreセキュリティルールの設定（本番前に必須）

**「コメントの投稿に失敗しました」と出る場合、ほぼ確実にこのルール未設定が原因です。**
（コメント投稿前に匿名認証を確実に待つよう2026-07-09にコード側は修正済みですが、
Firestore側のルールが `request.auth != null` を要求する設定になっている、または
コレクション自体へのアクセスが許可されていない場合は、Console側の設定が必要です）

現在ルールが未設定/テストモードの場合、**誰でも自由に読み書きできる状態**です。以下を目安に、Firebase Console → Firestore Database → ルール タブで設定してください。

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /challenges/{challengeId} {
      allow read: if true;
      // voteCount/agreeCountの増分更新のみ、認証済みユーザーに許可する。
      // 当初は「Cloud Functions経由に変更推奨」としてクライアントからの書き込みを
      // 全面禁止していたが、Cloud Functionsが未実装のままだと投票・賛同が常に
      // PERMISSION_DENIEDになってしまうため、policyOptions/userProposalsと同じ
      // 「特定フィールドのみの増分更新を許可する」パターンに変更（2026-07-27）。
      allow write: if request.auth != null
        && request.resource.data.diff(resource == null ? {} : resource.data)
            .affectedKeys().hasOnly(['voteCount', 'agreeCount']);

      // votes/agrees/likes/policyVotes は「自分の投票かどうか」をアプリ側が
      // voteRef.get() で事前チェックしてから書き込む実装になっているため、
      // allow read: if false だと自分の投票すら読めずPERMISSION_DENIEDになり
      // 投票自体が失敗する（2026-07-27に発覚）。「本人のみ読める」に変更することで
      // 他人の投票内容は見えないプライバシーは維持したまま、自己チェックを通す。
      match /votes/{userId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
      match /agrees/{userId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
      // 投稿の削除（即時削除機能）・通報／ブロック機能のために、投稿者UIDを
      // request.auth.uidと一致させることを作成時に必須化し、本人のみ削除できるようにした
      // （2026-07-28、UGC関連のApp Store審査対応）。
      match /comments/{commentId} {
        allow read: if true;
        allow create: if request.auth != null
          && request.resource.data.text is string
          && request.resource.data.text.size() <= 140
          && request.resource.data.userId == request.auth.uid;
        allow update: if request.auth != null
          && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['likeCount']);
        allow delete: if request.auth != null
          && request.auth.uid == resource.data.userId;

        match /likes/{userId} {
          allow read: if request.auth != null && request.auth.uid == userId;
          allow write: if request.auth != null && request.auth.uid == userId;
        }
      }

      match /policyOptions/{optionId} {
        allow read: if true;
        allow write: if request.auth != null
          && request.resource.data.diff(resource == null ? {} : resource.data)
              .affectedKeys().hasOnly(['voteCount']);
      }
      match /policyVotes/{userId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow create: if request.auth != null && request.auth.uid == userId;
        allow update, delete: if false;
      }
    }

    match /userProposals/{proposalId} {
      allow read: if true;
      allow create: if request.auth != null
        && request.resource.data.title is string
        && request.resource.data.title.size() <= 40
        && request.resource.data.description is string
        && request.resource.data.description.size() <= 300
        && request.resource.data.userId == request.auth.uid;
      // voteCount はいいねと同様の増分更新のみ許可。submissionStatus 等の管理項目は
      // Firebase Console から手動更新する運用のため、アプリからは変更できないようにする
      allow update: if request.auth != null
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['voteCount']);
      allow delete: if request.auth != null
        && request.auth.uid == resource.data.userId;

      match /votes/{userId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // 不適切な投稿の通報（App Store/Google Playガイドライン対応、2026-07-28）。
    // 通報内容は本人にも他人にも読めないようにし（Firebase Console経由でのみ運営が確認・対応する）、
    // 誰が通報したかを偽装できないようreportedByをauth.uidと一致させる。
    match /reports/{reportId} {
      allow read: if false;
      allow create: if request.auth != null
        && request.resource.data.reportedBy == request.auth.uid;
      allow update, delete: if false;
    }
  }
}
```

適用は私が代行できます。「Firestoreルールを設定して」とお伝えください（ただしConsole上での最終確認はお願いします）。
なお、このセッションで確認したところ `firebase` CLI（firebase-tools）がローカル環境で壊れており
（`MODULE_NOT_FOUND`エラー）、CLI経由の自動デプロイはできません。Console上での手動設定をお願いします。

---

## 3.5. ユーザー提案の「政府への提出状況」を更新する手順

「みんなの提案」機能で投票数が集まった提案（正式課題候補）を、実際に自治体・省庁等へ提出した場合、
アプリ上に状況を表示するには **Firebase Console から手動で** ステータスを更新してください
（アプリからは投票以外の書き込みができない設計にしています）。

### 手順
1. Firebase Console → Firestore Database → `userProposals` コレクション → 対象の提案ドキュメントを開く
2. 以下のフィールドを追加・編集する:
   - `submissionStatus`（string）: `submitted`（提出済み） / `responded`（回答待ち） / `adopted`（採択された） / `declined`（見送りとなった）
   - `submissionNote`（string、任意）: 提出先や経緯の説明文（例:「〇〇市の市民提案制度に提出しました」）
   - `submissionUrl`（string、任意）: 提出先の受付ページ等のURL
   - `submissionDate`（timestamp、任意）: 提出日
3. アプリの「みんなの提案」一覧で、該当カードにステータスバッジが表示されることを確認

---

## 3.6. 寄付機能（Google Play課金）の商品登録

「広告なし・寄付で応援」機能はコード実装済みですが、**実際に購入できるようにするには
Google Play Consoleでのアプリ登録・商品登録が必須**です（未登録の間は「準備中です」と表示され、
アプリはクラッシュせず安全に動作します）。

### 前提条件
- Google Play Consoleにアプリ（`com.yourwish.japanfuturemap`）が登録済みであること
  （未登録の場合は「5. Google Play ストア公開準備」を先に進めてください）

### 手順
1. Google Play Console → 対象アプリ → **収益化** → **商品** → **アプリ内アイテム**
2. 「アイテムを作成」で、以下の3つを **消費型（Consumable）** として登録:

   | 商品ID（正確に一致させる） | 商品名の例 | 価格の例 |
   |---|---|---|
   | `donation_small` | コーヒー1杯分の応援 | ¥120 |
   | `donation_medium` | ランチ1食分の応援 | ¥500 |
   | `donation_large` | がっつり応援 | ¥1,000 |

3. 各商品を「有効」にする
4. アプリ内テスト（内部テストトラック）で実機からアプリ内購入をテストする
   （テスト購入は実際に課金されない設定にできます。Play Console → 設定 → ライセンステスト）
5. テスト完了後、寄付画面（ダッシュボードのハートアイコン）で商品が表示・購入できることを確認

### 注意点
- 商品IDはコード側（`lib/domain/entities/donation_tier.dart`）で固定されているため、
  Play Console側の商品IDと**完全に一致させる**必要があります

---

## 3.7. 寄付機能（App Store課金）の商品登録（iOS）

Dart側のコードは`in_app_purchase`パッケージ（Android/iOS両対応のfederated plugin）を
使っているため、iOS向けの追加コード実装は不要です。**App Store Connectでの商品登録のみ**が必要です。

### 前提条件
- Apple Developer Program登録・App Store Connectでのアプリ登録が済んでいること
  （「0. iOS版のビルドについて」参照）

### 手順
1. App Store Connect → 対象アプリ → **機能** → **App内課金**
2. 「+」で、以下の3つを **消耗型（Consumable）** として登録:

   | 商品ID（正確に一致させる） | 参照名の例 | 価格の例 |
   |---|---|---|
   | `donation_small` | コーヒー1杯分 | ¥120 |
   | `donation_medium` | ランチ1食分 | ¥500 |
   | `donation_large` | がっつり応援 | ¥1,000 |

3. 各商品にローカライズ（表示名・説明文、日本語）を設定し、「送信準備完了」にする
4. 税務・銀行・連絡先情報（Agreements, Tax, and Banking）がApp Store Connect側で
   完了していないと、App内課金がテスト・審査に進めない点に注意
5. Xcodeでの動作確認には、`ios/Runner/Configuration.storekit`（用意済み）を使うと、
   App Store Connectの登録前でもシミュレータでローンチ・購入フローをテストできます
   （Xcode → Product → Scheme → Edit Scheme → Run → Options →
   StoreKit Configuration で選択）
6. 実際にApp Store Connect登録後は、Sandboxテスターアカウントで実機購入をテスト

### 注意点
- 商品IDはAndroid版（Google Play Console）と**完全に同じ文字列**で登録してください
  （コード側は1つの商品IDリストをOS問わず共通で使っています）
- 価格は自由に変更可能です（Play Console側で設定するだけでアプリ側の変更は不要）

---

## 4. RevenueCat課金の導入（該当する場合のみ）

設計書にある ¥120/月 のペイウォールを実装する場合:

1. https://app.revenuecat.com でアカウント作成（未作成の場合）
2. プロジェクト作成 → Android アプリ追加（パッケージ名: `com.yourwish.japanfuturemap`）
3. Google Play Console で商品（サブスクリプション）を先に作成する必要があります（Play Console未登録ならこちらが先）
4. API キーを取得し、私に共有いただければ `purchases_flutter` の実装を進めます

**Google Play Consoleへのアプリ登録がまだの場合、この手順は保留で問題ありません。**

---

## 5. Google Play ストア公開準備（リリース段階になったら）

- [ ] Google Play Console にアプリ登録（開発者アカウント必要、未登録なら$25の登録料）
- [ ] ストア掲載情報（説明文・スクリーンショット・プライバシーポリシー）準備
- [ ] リリース署名（keystore）作成

→ この段階になったら `flutter-play-release` スキルで手順を進めます。

---

## 優先順位のおすすめ

| 順番 | 項目 | 誰が実施 |
|-----|------|---------|
| 1 | 実機動作確認 | ユーザー様（スマホ操作）+ Claude（adb） |
| 2 | Firebase Authentication有効化確認 | ユーザー様（Console） |
| 3 | Firestoreセキュリティルール設定 | Claude（代行可）+ ユーザー様（最終確認） |
| 4 | RevenueCat / Play Console | ユーザー様の判断待ち（リリース時期次第） |

まずは **1. 実機動作確認** から始めることをお勧めします。
