# App Store Submission - Next Steps Quick Reference

**Current Status**: 🟡 Documentation Complete, Ready for Final Steps  
**Date**: September 11, 2026  
**Timeline to Launch**: 4 Days to Submission, 8-11 Days to Approval  

---

## Immediate Actions Required (Sept 12-14)

### 1️⃣ Create App Store Screenshots

**What**: Capture 10 screenshots (5 iPhone + 5 iPad) from running app  
**When**: September 12 (ideally)  
**How**:
- Set up iOS Simulator: iPhone 14 Pro (iOS 15.0+)
- Launch app and navigate to each required screen
- Capture 5 screens: (1) Onboarding, (2) Voting, (3) Analytics, (4) Recommendations, (5) Achievements
- Resize to 1242×2688 for iPhone
- Repeat for iPad Pro 12.9" (2048×2732)
- Add captions in semi-transparent overlay at bottom

**Reference**: See `SCREENSHOT_GUIDELINES.md` for detailed specifications  
**Deliverable**: 10 PNG files in `/screenshots/` directory

### 2️⃣ Deploy Privacy Policy

**What**: Publish privacy policy to web  
**Where**: https://seisaku-tohyo-map.jp/privacy-policy  
**When**: September 13  
**How**:
- Use provided `PRIVACY_POLICY.md` content
- Deploy to web hosting (Vercel, GitHub Pages, custom domain)
- Ensure HTTPS/SSL certificate
- Test accessibility on mobile and desktop
- Verify public access

**Reference**: See `PRIVACY_POLICY.md` for bilingual content  
**Deliverable**: Live accessible URL

### 3️⃣ Enter Metadata in App Store Connect

**What**: Input all app information into App Store Connect  
**When**: September 13-14  
**How**:
1. Log in: https://appstoreconnect.apple.com/
2. Select app: "政策投票マップ"
3. Enter metadata (see checklist below)
4. Upload screenshots
5. Set age rating
6. Add support URLs
7. Review and save

**Metadata Checklist**:
- [ ] App Name: 政策投票マップ
- [ ] Subtitle: 国会議案を可視化し、あなたの投票で未来を変える
- [ ] Description: [From APP_STORE_METADATA.md]
- [ ] Keywords: 政治,投票,国会,議案,政策,分析,アプリ,民主主義
- [ ] Promotional Text: Version 1.0.1 promotional text
- [ ] Support URL: https://github.com/zka32101/seisaku_tohyo_map/issues
- [ ] Marketing URL: https://github.com/zka32101/seisaku_tohyo_map
- [ ] Privacy Policy: [URL from step 2]
- [ ] Age Rating: 12+
- [ ] Screenshots: [5 iPhone + 5 iPad from step 1]

**Reference**: See `APP_STORE_METADATA.md` and `FINAL_SUBMISSION_CHECKLIST.md` for details

---

## 4️⃣ Final Verification (Sept 14)

**Checklist**:
- [ ] All screenshots uploaded and preview looks good
- [ ] Metadata is complete and accurate
- [ ] Privacy policy is accessible
- [ ] No typos or errors in text
- [ ] All URLs work correctly
- [ ] Build 1.0.1+13 is selected in App Store Connect
- [ ] Content rating is set to 12+

**Reference**: See `FINAL_SUBMISSION_CHECKLIST.md` Phase 10

---

## 5️⃣ Submit for Review (Sept 15)

**Steps**:
1. Log into App Store Connect
2. Click "Version 1.0.1" → "Submit for Review"
3. Confirm all details are correct
4. Click "Submit"
5. Save confirmation details and date

**Expected Review Timeline**:
- Submission: September 15
- Initial review: 1-2 days
- Decision: 3-5 days
- Expected approval: September 18-22

**Reference**: See `FINAL_SUBMISSION_CHECKLIST.md` Phase 11

---

## Supporting Documents

| Document | Purpose | Key Info |
|----------|---------|----------|
| `APP_STORE_METADATA.md` | Complete metadata reference | All text, descriptions, keywords |
| `SCREENSHOT_GUIDELINES.md` | Screenshot creation guide | Dimensions, content, design specs |
| `PRIVACY_POLICY.md` | Privacy policy template | Bilingual, ready to deploy |
| `PRE_SUBMISSION_TESTING.md` | Testing checklist | 14 phases of testing |
| `FINAL_SUBMISSION_CHECKLIST.md` | Complete submission guide | All 14 phases with detailed tasks |
| `APP_STORE_SUBMISSION_CHECKLIST.md` | Initial submission checklist | Version control and build info |

---

## File Organization

```
Project Root/
├── APP_STORE_METADATA.md ✅
├── SCREENSHOT_GUIDELINES.md ✅
├── PRIVACY_POLICY.md ✅
├── PRE_SUBMISSION_TESTING.md ✅
├── FINAL_SUBMISSION_CHECKLIST.md ✅
├── NEXT_STEPS_QUICK_REFERENCE.md 📄 (this file)
└── screenshots/
    ├── iphone/
    │   ├── 01_onboarding_interest_selection.png ⏳
    │   ├── 02_voting_interface.png ⏳
    │   ├── 03_analytics_dashboard.png ⏳
    │   ├── 04_recommendations.png ⏳
    │   └── 05_achievements_community.png ⏳
    └── ipad/
        ├── 01_onboarding_interest_selection.png ⏳
        ├── 02_voting_interface.png ⏳
        ├── 03_analytics_dashboard.png ⏳
        ├── 04_recommendations.png ⏳
        └── 05_achievements_community.png ⏳
```

---

## Key URLs to Remember

**App Store Connect**: https://appstoreconnect.apple.com/  
**Privacy Policy URL**: https://seisaku-tohyo-map.jp/privacy-policy (to be deployed)  
**Support URL**: https://github.com/zka32101/seisaku_tohyo_map/issues  
**GitHub Repository**: https://github.com/zka32101/seisaku_tohyo_map  
**Bundle ID**: com.nihon-future-map.app  

---

## App Details Summary

| Field | Value |
|-------|-------|
| App Name | 政策投票マップ |
| Version | 1.0.1 |
| Build Number | 13 |
| Bundle ID | com.nihon-future-map.app |
| Platform | iOS 15.0+ |
| Primary Category | 政治 (Politics) |
| Age Rating | 12+ |
| Pricing | Free (no in-app purchases) |
| Territory | Japan (日本) |
| Release Date | September 15, 2026 |

---

## Critical Path Timeline

```
Today (Sept 11) ✅
├── Documentation preparation complete
├── Code formatted and ready
└── Build 1.0.1+13 in TestFlight

Tomorrow (Sept 12) ⏳
├── Capture iPhone screenshots (5)
└── Capture iPad screenshots (5)

Sept 13 ⏳
├── Deploy privacy policy to web
└── Enter metadata in App Store Connect

Sept 14 ⏳
├── Upload screenshots to App Store Connect
├── Final verification
└── Ready for submission

Sept 15 📝
└── Submit for App Store review

Sept 18-22 🔮
└── Expected approval and launch
```

---

## Common Issues & Solutions

### Issue: Screenshot dimensions incorrect
**Solution**: Use exact dimensions (1242x2688 for iPhone, 2048x2732 for iPad)

### Issue: Privacy policy URL not accessible
**Solution**: Ensure HTTPS and public access, test before submitting

### Issue: Metadata text too long
**Solution**: Use character counter tools, trim to limits (Description: 4,000 chars, Keywords: 100 chars, Promo: 170 chars)

### Issue: Build not appearing in App Store Connect
**Solution**: Wait 5-10 minutes after upload, check build status in Xcode

### Issue: Screenshots not showing in preview
**Solution**: Ensure PNG/JPEG format, correct dimensions, and proper file naming

---

## Success Criteria

✅ **Definition of Ready for Submission**:
1. All 5 iPhone screenshots captured (1242×2688)
2. All 5 iPad screenshots captured (2048×2732)
3. Privacy policy deployed to public URL
4. All metadata entered in App Store Connect
5. Age rating set to 12+
6. Support URLs verified
7. No typos or errors in text
8. Build 1.0.1+13 selected

✅ **Definition of Done (Launch)**:
1. App approved by Apple
2. App appears in App Store
3. App can be downloaded and installed
4. Monitoring active (Crashlytics, Analytics)
5. Launch announcement published

---

## Questions?

Refer to:
- **Screenshots**: `SCREENSHOT_GUIDELINES.md`
- **Metadata**: `APP_STORE_METADATA.md`
- **Privacy**: `PRIVACY_POLICY.md`
- **Full Checklist**: `FINAL_SUBMISSION_CHECKLIST.md`
- **Testing**: `PRE_SUBMISSION_TESTING.md`

---

**Status**: 🟡 READY FOR NEXT PHASE  
**Next Action**: Capture screenshots (Sept 12)  
**Target Submission**: September 15, 2026  
**Expected Launch**: September 22-25, 2026

---

*Last Updated: September 11, 2026*  
*App Version: 1.0.1 (Build 13)*  
*Platform: iOS 15.0+*
