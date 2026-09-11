# App Store Submission Checklist

## Pre-Submission Requirements

### ✅ Code Requirements
- [x] All Phase 1-6 features implemented and tested
- [x] iOS build version 1.0.1+13 completed
- [x] Signed build uploaded to TestFlight
- [ ] Run final automated tests and linters
- [ ] Perform manual testing on multiple devices

### ✅ App Signing & Provisioning
- [x] iOS signing certificates configured
- [x] Provisioning profiles set up correctly
- [x] Build successfully uploaded to App Store Connect

### ⚠️ Deployment Target (iOS 13.0 → 15.0 needed by Spring 2027)
- [ ] Current: iOS 13.0
- [ ] Update to iOS 15.0+ before Spring 2027 deadline
- [ ] Not blocking for current submission, but plan upgrade

## App Store Connect Metadata

### Basic Information
- [ ] App Name: 政策投票マップ
- [ ] Subtitle: 国会議案を可視化し、あなたの投票で未来を変える
- [ ] Bundle ID: Verify correct identifier
- [ ] Version Number: 1.0.1 ✓
- [ ] Build Number: 13 ✓

### Description & Keywords

#### App Description (Required - 4000 characters max)
```
政策投票マップは、国会議案を可視化し、あなたの投票で日本の未来を変えるアプリです。

【主な機能】

🗳️ 投票
- 国会議案に簡単に投票できます
- 複数の分野から興味のある議案を選択
- あなたの意見を日本の政策に反映させましょう

📊 分析
- あなたの投票パターンを分析します
- 関心分野の推移をトラッキング
- 実現率やトレンドを可視化

🎯 パーソナライズ
- あなたの興味に基づいたおすすめ議案
- 関連分野の自動提案
- より関心のある議案に出会えます

🏆 アチーブメント
- 投票マイルストーン達成時に自動解放
- カテゴリマスター達成
- トレンドボターの認定

💬 ディスカッション
- 議案について他のユーザーと対話
- コメント機能でリアルタイム議論
- 多様な視点を共有

📈 インサイト
- 詳細な投票分析とレポート
- 政治的傾向分析
- 投票パターン予測

【対応分野】
- 経済・財政
- 福祉・医療
- 人口・地域
- 環境・エネルギー
- 政治構造
- 教育・科学
- 防衛・外交

政策投票マップで、民主主義にもっと参加しましょう！
```

#### Keywords (100 characters max)
```
政治,投票,国会,議案,政策,分析,アプリ,民主主義
```

### Promotional Information
- [ ] Promotional Text (170 characters max): Brief update description
- [ ] Support URL: Add project GitHub or support page
- [ ] Marketing URL: Optional
- [ ] Privacy Policy URL: Add privacy policy document URL

### Screenshots (Required)

#### iPhone Screenshots (at least 2, max 10)
Create 5 screenshots at 1242x2688px (iPhone 14 Pro):

1. **Onboarding/Interest Selection**
   - Show interest setup screen with category selection
   - Caption: "あなたの興味分野を選択してカスタマイズ"

2. **Challenge Voting**
   - Show voting interface
   - Caption: "国会議案に投票して意見を反映"

3. **Personal Analytics Dashboard**
   - Show analytics with pie charts and trends
   - Caption: "あなたの投票パターンを分析"

4. **Recommendations**
   - Show personalized recommendations
   - Caption: "興味に基づいたおすすめ議案"

5. **Achievements & Social**
   - Show achievements and discussion
   - Caption: "アチーブメント達成とコミュニティ参加"

#### iPad Screenshots (at least 2, max 10)
Create 5 screenshots at 2048x2732px (iPad Pro 12.9"):
- Same content as iPhone but optimized for tablet layout

### Privacy Policy & Legal

- [ ] Privacy Policy URL (Required)
  - Must include:
    - What data is collected
    - How data is used
    - User rights and data deletion
    - Cookie usage
    - Third-party sharing (Firebase Analytics, Crashlytics)
    
- [ ] Terms of Service (Optional but recommended)
  - User conduct guidelines
  - Dispute resolution
  - Liability limitations

### Rating Information

- [ ] Medical/Health Claims: No
- [ ] Unrestricted Web Access: Yes (opens external links)
- [ ] Gambling: No
- [ ] Contests/Lotteries/Sweepstakes: No
- [ ] Alcohol/Tobacco: No
- [ ] Drugs: No
- [ ] Violence: No
- [ ] Mature Content: No
- [ ] Sexual Content: No
- [ ] Graphic Violence: No
- [ ] Scary/Horrorifying: No
- [ ] Profanity/Crude Humor: Infrequent/Mild

### Age Rating
- Recommended: 12+
- Apple Content Rating ID: [Will be assigned]

## Build Preparation

### Pre-Build Testing
- [ ] Clean Xcode build folder
- [ ] Run Flutter analysis: `flutter analyze`
- [ ] Run tests: `flutter test`
- [ ] Check for warnings and deprecations
- [ ] Test on multiple iOS versions (minimum: iOS 15.0)
- [ ] Test on multiple devices (iPhone, iPad)

### Build Checklist
- [ ] Update version to 1.0.1
- [ ] Update build number to 13
- [ ] Verify all signing certificates and profiles
- [ ] Run final `flutter build ios --release`
- [ ] Verify app signature in Xcode
- [ ] Test TestFlight version thoroughly

### Release Notes
```
Version 1.0.1 - 政策投票マップ初版

【新機能】
✨ 直感的な投票インターフェース
📊 個人向け分析ダッシュボード
🎯 興味に基づいたおすすめ機能
🏆 アチーブメントシステム
💬 ユーザーディスカッション機能
📈 詳細なインサイト分析

【改善】
- ダークモード対応
- 複数言語対応の準備
- パフォーマンス最適化

【今後の予定】
- より詳細な政治分析
- ソーシャルシェア機能
- オフライン対応

フィードバックをお待ちしています！
support@nihon-future-map.jp
```

## App Store Review Compliance

### Content Guidelines
- [ ] No misleading information about voting
- [ ] Clear disclaimer about voting being non-binding
- [ ] Neutral stance on political issues
- [ ] No hate speech or discrimination
- [ ] Proper handling of user-generated content (comments)

### Privacy & Security
- [ ] GDPR compliance (if applicable)
- [ ] CCPA compliance (if applicable)
- [ ] Clear privacy policy
- [ ] Secure data transmission (HTTPS)
- [ ] No tracking without consent
- [ ] Firebase integration disclosed

### Network & Performance
- [ ] Handles network errors gracefully
- [ ] Appropriate loading indicators
- [ ] Responsive to slow connections
- [ ] Proper error messages

### Features & Functionality
- [ ] All advertised features work correctly
- [ ] No crashes or hangs
- [ ] Proper state restoration
- [ ] Navigation works as expected

## Submission Process

### Step 1: Prepare in App Store Connect
- [ ] Log into App Store Connect
- [ ] Select "Build" → Upload new build
- [ ] Wait for processing (usually 5-10 minutes)
- [ ] Add version info (release notes, what's new)

### Step 2: Fill App Information
- [ ] Complete all metadata as listed above
- [ ] Add screenshots
- [ ] Set age rating
- [ ] Add privacy policy link

### Step 3: Set Pricing & Distribution
- [ ] Select countries/regions
- [ ] Set price (free recommended for initial launch)
- [ ] Choose pricing tier if paid
- [ ] Set availability date

### Step 4: Review & Submit
- [ ] Review all information
- [ ] Check for compliance
- [ ] Submit for review

### Step 5: Track Review Status
- [ ] Check review status in App Store Connect
- [ ] Respond to any reviewer questions within 24 hours
- [ ] Be prepared to resubmit if rejected

## Common Rejection Reasons & Solutions

### Version Number Issues
- ❌ Version 1.0.0 already submitted
- ✅ Solution: Bump to 1.0.1 (already done)

### Missing Metadata
- ❌ Screenshots or privacy policy missing
- ✅ Solution: Complete all required fields

### Functionality Issues
- ❌ App crashes or features don't work
- ✅ Solution: Thorough testing before submission

### Misleading Information
- ❌ Claims about voting power unclear
- ✅ Solution: Clear disclaimer about app purpose

### User-Generated Content
- ❌ No moderation of comments
- ✅ Solution: Implement content moderation if needed

## Post-Launch Actions

### Day 1
- [ ] Monitor App Store ratings and reviews
- [ ] Check Crashlytics for any crashes
- [ ] Monitor Firebase Analytics usage
- [ ] Respond to user reviews (positive and negative)

### Week 1
- [ ] Analyze user behavior and feature usage
- [ ] Identify any bugs or issues
- [ ] Collect feedback from early users
- [ ] Plan bug fix release if needed

### Month 1
- [ ] Plan Phase 1 post-launch features
- [ ] Analyze retention and engagement metrics
- [ ] Update app store listing based on user feedback
- [ ] Release 1.0.2 patch if needed

## Timeline

```
Current Status:
✅ iOS 1.0.1 build complete
✅ TestFlight upload successful  
⏳ App Store metadata preparation
⏳ App Store submission

Estimated Timeline:
- Today: Complete metadata & submit
- 2-5 days: App Store review
- Day 6: Launch on App Store
- Week 1: Monitor and respond to feedback
```

## Resources

- [App Store Connect](https://appstoreconnect.apple.com/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Privacy Policy Template](https://www.privacypolicies.com/blog/app-privacy-policy/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/)

## Contact & Support

- App Support Email: [Set up]
- Privacy Questions: [Set up]
- Bug Reports: GitHub Issues
- Feature Requests: GitHub Discussions

---

**Last Updated**: 2026-09-11
**Next Review**: After App Store submission
