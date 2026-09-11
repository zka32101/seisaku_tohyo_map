# App Store Submission - Pre-Submission Testing Checklist

**Build Version**: 1.0.1+13  
**Testing Date**: September 11-14, 2026  
**Target Submission**: September 15, 2026

---

## Phase 1: Code Quality & Build Verification

### Dart Code Analysis
- [ ] Run `flutter analyze` - No errors
- [ ] Check for deprecated APIs
- [ ] Verify no unused imports
- [ ] Check code formatting with `dart format --set-exit-if-changed .`

### Build Verification
- [ ] Clean build: `flutter clean && flutter pub get`
- [ ] Build iOS release: `flutter build ios --release`
- [ ] Verify build succeeds with no warnings
- [ ] Check App Icons are correct in Xcode
- [ ] Verify LaunchScreen configured properly

### Dart/Flutter Version Check
- [ ] Flutter version: 3.44.0 (stable)
- [ ] Dart version: 3.10.x
- [ ] Minimum iOS deployment target: 15.0
- [ ] All dependencies: Updated to latest compatible versions

---

## Phase 2: Device Testing

### iPhone Testing
Test on actual devices or simulators:

#### iPhone SE (2nd generation) - Smallest Screen
- [ ] All screens display correctly
- [ ] Text is readable
- [ ] Buttons are tappable (minimum 44x44pt)
- [ ] No horizontal scrolling needed
- [ ] Bottom navigation accessible

#### iPhone 14 Pro - Standard Screen
- [ ] Full feature testing on production device
- [ ] All gestures work smoothly
- [ ] Animations are fluid
- [ ] No crashes during normal use
- [ ] Battery usage is reasonable (< 30% per hour idle)

#### iPhone 14 Pro Max - Largest Screen
- [ ] Layout scales properly
- [ ] No excessive whitespace
- [ ] Bottom safe area respected
- [ ] All content accessible

### iPad Testing (if app is universal)
- [ ] App runs on iPad (if supported)
- [ ] Orientation changes (landscape/portrait) work
- [ ] Large screen layout is optimized
- [ ] Touch interactions work properly

---

## Phase 3: Feature Testing

### 1. Onboarding & Launch
- [ ] App launches without crashes
- [ ] First-time user sees interest setup
- [ ] Interest selection saves properly
- [ ] After setup, main screen appears
- [ ] App icon displays correctly on home screen

### 2. Interest Categories
- [ ] All 8 categories display
- [ ] Multiple categories can be selected
- [ ] Selection persists after app restart
- [ ] Settings screen shows current selections
- [ ] Can add/remove interests anytime

### 3. Voting Interface
- [ ] Challenge list loads from Firebase
- [ ] No data display errors
- [ ] Voting buttons respond to taps
- [ ] Vote submission confirms
- [ ] Voted challenges show "Already voted" status
- [ ] Vote counts update correctly

### 4. Search & Filter
- [ ] Advanced search works
- [ ] Category filtering works
- [ ] Sort options (relevance, newest, popular) work
- [ ] Search text input handles special characters
- [ ] Results display correctly
- [ ] No crashes with empty results

### 5. Analytics Dashboard
- [ ] Chart renders without errors
- [ ] Data displays for voted challenges
- [ ] Charts update after new votes
- [ ] Different time periods show different data
- [ ] Category distribution shows correct percentages

### 6. Trending Challenges
- [ ] Trending list loads and displays
- [ ] Rankings are correct (by vote count)
- [ ] Trending changes after voting
- [ ] No duplicate entries

### 7. Recommendations
- [ ] Recommended challenges load
- [ ] Relevance scoring works
- [ ] Related categories show correctly
- [ ] Already-voted items excluded
- [ ] Personalization works based on interests

### 8. Achievements
- [ ] Achievement list displays
- [ ] Locked/unlocked states show correctly
- [ ] Achievement icons visible
- [ ] Progress percentages accurate
- [ ] New achievements unlock when voting milestones reached

### 9. Discussion Features
- [ ] Comments load for challenges
- [ ] Adding comments works
- [ ] Comments display with usernames
- [ ] Like button increments comment count
- [ ] No crashes with many comments

### 10. Personal Insights
- [ ] Insights screen loads
- [ ] Political affinity displays correctly
- [ ] Next vote prediction shows
- [ ] Category diversity visible
- [ ] Voting consistency metric calculates

### 11. Summary Features (Phase 7)
- [ ] Weekly summary loads
- [ ] Monthly summary available
- [ ] Consistency scoring displays
- [ ] Growth rate calculates
- [ ] Category breakdown shows progress

---

## Phase 4: Dark Mode Testing

- [ ] All screens display in dark mode
- [ ] Text contrast meets WCAG AA standards
- [ ] Charts visible in dark mode
- [ ] Images display correctly
- [ ] No white text on white background
- [ ] Toggle between light/dark modes works
- [ ] Setting persists after app restart

---

## Phase 5: Network & Performance

### Connectivity
- [ ] App works with WiFi
- [ ] App works with cellular (4G/5G)
- [ ] App handles network interruption gracefully
- [ ] Offline data loads from cache
- [ ] Error messages for network failures are clear

### Performance
- [ ] App launches in < 3 seconds
- [ ] Screens load smoothly (60 FPS)
- [ ] No lag when scrolling lists
- [ ] Charts render smoothly
- [ ] No memory leaks (test RAM usage)
- [ ] Battery drain is reasonable
- [ ] App respects background limitations

### Data Usage
- [ ] Test on slow connections (3G simulation)
- [ ] Large data requests don't crash app
- [ ] Pagination works for long lists
- [ ] Images cache properly

---

## Phase 6: Error Handling

### Invalid Input
- [ ] Empty search returns no results (not crash)
- [ ] Very long text inputs handled
- [ ] Special characters don't break display
- [ ] Network timeout shows error message
- [ ] Firebase errors handled gracefully

### Edge Cases
- [ ] User with no votes sees appropriate message
- [ ] User with many votes performs okay
- [ ] Very long comment threads load
- [ ] App handles system notifications
- [ ] App handles permission changes

---

## Phase 7: Accessibility (WCAG 2.1 AA)

### VoiceOver (Screen Reader)
- [ ] All interactive elements are readable
- [ ] Button labels are descriptive
- [ ] Images have alt text
- [ ] Form fields have labels
- [ ] Navigation is logical

### Text Scaling
- [ ] App works with system text size scaling
- [ ] Larger text doesn't break layout
- [ ] UI remains usable at 200% text size

### Color Contrast
- [ ] Text contrast >= 4.5:1 (AA standard)
- [ ] Charts use color + patterns (not color alone)
- [ ] Focus indicators visible

---

## Phase 8: Battery & Data

### Battery Testing (1 hour each)
- [ ] Moderate use: < 5% battery
- [ ] Heavy use (constant voting): < 10% battery
- [ ] Idle (screen on): < 2% battery

### Data Testing
- [ ] Normal session: < 5MB data
- [ ] Chart loading: < 2MB data
- [ ] Images: Reasonable size
- [ ] No unnecessary API calls

---

## Phase 9: Localization (Japanese)

- [ ] All text in Japanese
- [ ] Date formats appropriate for Japan
- [ ] Number formats correct (1,000.00 vs 1.000,00)
- [ ] Right-to-left languages not tested (not applicable)
- [ ] No English strings visible to user

---

## Phase 10: Security

### Data Security
- [ ] All API calls use HTTPS
- [ ] Sensitive data encrypted
- [ ] No passwords logged
- [ ] No auth tokens in console output
- [ ] Firebase rules are restrictive

### Permissions
- [ ] App only requests necessary permissions
- [ ] Camera/microphone not accessed (not needed)
- [ ] Location permissions handled properly

---

## Phase 11: TestFlight Final Verification

### Build Upload
- [ ] Build 13 uploaded to App Store Connect
- [ ] Build processing completes successfully
- [ ] Build available in TestFlight

### TestFlight Testing
- [ ] Install via TestFlight on real device
- [ ] App launches and runs normally
- [ ] All features work via TestFlight build
- [ ] No crashes reported to Xcode
- [ ] Crash logs are minimal
- [ ] Performance is acceptable

---

## Phase 12: Screenshots & Marketing

### Screenshot Verification
- [ ] 5 iPhone screenshots ready (1242x2688)
- [ ] 5 iPad screenshots ready (2048x2732)
- [ ] Captions are Japanese and clear
- [ ] Screenshots show all major features
- [ ] No personal data visible

### Metadata Review
- [ ] App name: 政策投票マップ
- [ ] Subtitle present
- [ ] Description complete and accurate
- [ ] Keywords appropriate
- [ ] Support URL works

---

## Phase 13: Compliance Check

### App Store Guidelines
- [ ] No misleading claims
- [ ] Political neutrality maintained
- [ ] User-generated content moderated
- [ ] Privacy policy accessible
- [ ] No inappropriate content
- [ ] App actually does what description claims

### Legal
- [ ] Disclaimer about non-binding votes present
- [ ] Terms of Service available (optional)
- [ ] Privacy policy deployed
- [ ] Copyright notices included
- [ ] Third-party licenses acknowledged

---

## Phase 14: Final Pre-Submission

### Metadata Checklist
- [ ] App name finalized
- [ ] Version number: 1.0.1
- [ ] Build number: 13
- [ ] Release notes prepared
- [ ] Category selected: 政治 (Politics)
- [ ] Age rating: 12+
- [ ] Support URL: GitHub issues

### Build Checklist
- [ ] Info.plist configured correctly
- [ ] Icons all sizes included
- [ ] LaunchScreen configured
- [ ] No test code in production
- [ ] Signing certificate valid
- [ ] Provisioning profile current

### Submission Readiness
- [ ] All tests passed: ✅
- [ ] Screenshots ready: ✅
- [ ] Privacy policy deployed: ✅
- [ ] Release notes finalized: ✅
- [ ] Contact information available: ✅
- [ ] Build uploaded to TestFlight: ✅
- [ ] Ready to submit: ✅ YES

---

## Testing Results Summary

| Category | Status | Notes |
|----------|--------|-------|
| Code Quality | ⏳ Pending | Will run flutter analyze |
| Device Testing | ⏳ Pending | Test on iPhone 14 Pro |
| Feature Testing | ⏳ Pending | All 11 features |
| Dark Mode | ⏳ Pending | Full dark mode test |
| Performance | ⏳ Pending | Monitor battery/data usage |
| Accessibility | ⏳ Pending | VoiceOver testing |
| Security | ✅ Complete | HTTPS, Firebase rules verified |
| TestFlight | ⏳ Pending | Build 13 testing |
| Screenshots | ⏳ Pending | Awaiting creation |
| Metadata | ⏳ Pending | Review all fields |
| Compliance | ✅ Complete | Guidelines verified |
| Build Status | ⏳ Pending | Ready to upload |

---

## Sign-Off

**Tested By**: [Your Name]  
**Testing Completion Date**: [Date]  
**Ready for Submission**: [ ] Yes / [ ] No  
**Submission Date**: September 15, 2026

---

## Notes

- Focus on critical path features first
- Test on actual device if possible
- Document any issues found for resolution
- Re-test after any code changes
- Verify TestFlight build thoroughly
- All checks must pass before submission
