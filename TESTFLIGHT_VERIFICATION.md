# TestFlight Build Verification Guide

**App**: 政策投票マップ (Policy Voting Map)  
**Version**: 1.0.1  
**Build**: 13  
**Platform**: iOS 15.0+  
**Date**: September 11, 2026

---

## Quick Start

### Prerequisites
- iPhone 14 Pro or later (or iPad Pro)
- iOS 15.0 or later
- TestFlight app installed
- Apple ID with access to beta testing
- ~2-3 hours for full testing

### Device Setup
1. Open TestFlight app
2. Find "政策投票マップ" in available apps
3. Tap "Install" or update if already installed
4. Launch the app once installed

---

## Test Execution Guide

### Phase 1: Initial Launch & Onboarding (15 minutes)

#### ✅ Test 1.1: App Launch
- [ ] App launches without crashing
- [ ] Splash screen displays
- [ ] No error messages on startup
- [ ] App loads within 3 seconds

**Notes:**
```
Launch time: ___ seconds
Any errors: _______________
Device used: _______________
```

#### ✅ Test 1.2: Onboarding Screen
- [ ] Interest selection screen displays
- [ ] All 8 categories visible:
  - 経済・財政 (Economy & Finance)
  - 福祉・医療 (Welfare & Healthcare)
  - 人口・地域 (Population & Regional)
  - 環境・エネルギー (Environment & Energy)
  - 政治構造 (Political Structure)
  - 教育・科学 (Education & Science)
  - 防衛・外交 (Defense & Diplomacy)
  - その他 (Other)
- [ ] Can tap categories to select/deselect
- [ ] Selected categories highlight visually
- [ ] "次へ" (Next) button appears when ready
- [ ] Tapping "次へ" proceeds to main app

**Notes:**
```
Categories working: [ ] Yes [ ] No
Selection visual feedback: ___________
Any issues: _______________
```

---

### Phase 2: Main Dashboard & Navigation (10 minutes)

#### ✅ Test 2.1: Main Dashboard
- [ ] Dashboard displays without errors
- [ ] Tab bar visible with all navigation options
- [ ] No loading spinners stuck
- [ ] Content loads within 2 seconds
- [ ] Dark mode toggle works (if available)

#### ✅ Test 2.2: Tab Navigation
- [ ] Home/Voting tab accessible
- [ ] Analytics tab accessible
- [ ] Recommendations tab accessible
- [ ] Achievements tab accessible
- [ ] Discussion tab accessible
- [ ] Settings tab accessible (if present)
- [ ] Each tab switches smoothly without lag
- [ ] No crashes when switching tabs

**Notes:**
```
Tab response time: ___ ms
Any lag observed: [ ] Yes [ ] No
Tabs working: ___ / 6
```

---

### Phase 3: Voting Feature (20 minutes)

#### ✅ Test 3.1: Challenge/Voting Screen
- [ ] Voting interface displays
- [ ] Proposal title visible
- [ ] Proposal description visible
- [ ] Category badge shows (経済・財政, etc.)
- [ ] Voting buttons present:
  - [ ] 賛成 (Yes/For)
  - [ ] 反対 (No/Against)
  - [ ] どちらでもない (Abstain/Neither)
- [ ] Button colors are distinct and clear
- [ ] Buttons are easily tappable

#### ✅ Test 3.2: Cast a Vote
- [ ] Tap "賛成" (Yes) button
  - [ ] Button highlights/animates
  - [ ] Vote registers (UI confirms)
  - [ ] No error message
  - [ ] Next proposal loads automatically
  - [ ] Vote count increases

- [ ] Tap "反対" (No) button
  - [ ] Button highlights/animates
  - [ ] Vote registers
  - [ ] Next proposal loads
  - [ ] Vote count increases

- [ ] Tap "どちらでもない" (Abstain) button
  - [ ] Button highlights/animates
  - [ ] Vote registers
  - [ ] Next proposal loads
  - [ ] Vote count increases

#### ✅ Test 3.3: Vote History
- [ ] Progress indicator shows vote count (e.g., "3/50")
- [ ] Vote count increases after each vote
- [ ] No votes are lost
- [ ] Can continue voting without limit

#### ✅ Test 3.4: Data Persistence
- [ ] Close app completely
- [ ] Reopen app
- [ ] Vote count is preserved
- [ ] Voting history is intact

**Notes:**
```
Total votes cast during test: ___
Votes registered correctly: [ ] Yes [ ] No
Vote count preserved: [ ] Yes [ ] No
Any voting issues: _______________
```

---

### Phase 4: Analytics Dashboard (15 minutes)

#### ✅ Test 4.1: Analytics Screen Display
- [ ] Analytics tab loads without error
- [ ] Dashboard header visible
- [ ] Stat cards display:
  - [ ] Total votes count
  - [ ] Categories voted on count
  - [ ] Voting streak (if applicable)
  - [ ] Accuracy/preference score (if applicable)

#### ✅ Test 4.2: Voting Distribution Chart
- [ ] Pie chart displays
- [ ] Shows vote distribution:
  - [ ] Yes (賛成) votes %
  - [ ] No (反対) votes %
  - [ ] Abstain (どちらでもない) %
- [ ] Chart is colorful and readable
- [ ] Percentages add up to 100%
- [ ] Chart responds to vote changes (after voting more)

#### ✅ Test 4.3: Category Breakdown
- [ ] Bar chart or table shows categories
- [ ] All voted categories listed:
  - [ ] Category name in Japanese
  - [ ] Vote count per category
  - [ ] Percentage per category
- [ ] Visual representation is clear
- [ ] Data accuracy matches voting history

#### ✅ Test 4.4: Trends & Insights
- [ ] Trend indicators display (if present):
  - [ ] Arrow direction (up/down/flat)
  - [ ] Percentage change
  - [ ] Time period (last 7 days, last 30 days, etc.)
- [ ] Text is readable
- [ ] Numbers make sense

**Notes:**
```
Total votes showing: ___
Charts loading properly: [ ] Yes [ ] No
Data accuracy: [ ] Correct [ ] Incorrect
Missing analytics: _______________
```

---

### Phase 5: Recommendations Feature (15 minutes)

#### ✅ Test 5.1: Recommendations Screen
- [ ] Recommendations tab loads
- [ ] Header/title visible
- [ ] "Based on your interests" message visible
- [ ] No errors or loading errors

#### ✅ Test 5.2: Recommendation Cards
- [ ] At least 1 recommendation visible
- [ ] Each card shows:
  - [ ] Proposal title in Japanese
  - [ ] Category badge
  - [ ] Brief description
  - [ ] Relevance score/percentage (e.g., "82% match")
  - [ ] "詳しく見る" (View Details) button or similar

#### ✅ Test 5.3: Recommendation Quality
- [ ] Recommendations match your interests
- [ ] Relevance scores are reasonable
- [ ] Recommendations are from your selected categories
- [ ] Cards are organized logically

#### ✅ Test 5.4: Interaction with Recommendations
- [ ] Tap on a recommendation
  - [ ] Details screen opens
  - [ ] Full proposal text visible
  - [ ] Can vote on recommendation
  - [ ] Back button returns to recommendations
- [ ] Cards are scrollable
- [ ] No lag when scrolling

**Notes:**
```
Recommendations showing: ___ proposals
Relevance accuracy: [ ] Good [ ] Fair [ ] Poor
Any missing recommendations: _______________
```

---

### Phase 6: Achievements System (15 minutes)

#### ✅ Test 6.1: Achievements Screen
- [ ] Achievements tab opens
- [ ] Achievement list displays
- [ ] No loading errors

#### ✅ Test 6.2: Achievement Badges
- [ ] Unlocked achievements show with:
  - [ ] Badge icon/emoji
  - [ ] Achievement name (Japanese)
  - [ ] Description
  - [ ] Unlock date
  - [ ] Visual indication that unlocked (e.g., highlighted)

- [ ] Expected unlocked achievements:
  - [ ] "投票を始めた" (Started Voting) - After 1 vote ✅
  - [ ] "10投票達成" (10 Votes) - If 10+ votes ✅
  - [ ] "50投票達成" (50 Votes) - If 50+ votes ✅
  - [ ] "100投票達成" (100 Votes) - If 100+ votes ✅
  - [ ] "カテゴリマスター" (Category Master) - If all categories voted ✅

#### ✅ Test 6.3: Locked Achievements
- [ ] Locked achievements show with:
  - [ ] Grayed out appearance
  - [ ] Achievement name
  - [ ] Description
  - [ ] Progress indicator (e.g., "3/10 votes")
  - [ ] Unlock condition clearly stated

#### ✅ Test 6.4: Progress Tracking
- [ ] Progress bars show for locked achievements
- [ ] Progress updates after voting
- [ ] Percentages/counts accurate
- [ ] Time remaining or votes needed clear

#### ✅ Test 6.5: Achievement Unlock
- [ ] Vote enough to unlock a new achievement
  - [ ] New achievement appears
  - [ ] Notification/animation shows (if present)
  - [ ] Achievement updates from locked to unlocked
  - [ ] Progress is saved

**Notes:**
```
Achievements unlocked: ___
Progress tracking accuracy: [ ] Good [ ] Fair [ ] Poor
Animation smooth: [ ] Yes [ ] No
```

---

### Phase 7: Discussion/Community Feature (15 minutes)

#### ✅ Test 7.1: Discussion Screen
- [ ] Discussion/Comment tab opens
- [ ] Comment threads or discussion list shows
- [ ] No loading errors
- [ ] Interface is clean and readable

#### ✅ Test 7.2: View Comments
- [ ] Can see existing comments
- [ ] Each comment shows:
  - [ ] User name/avatar
  - [ ] Comment text (Japanese)
  - [ ] Timestamp
  - [ ] Like/reaction buttons (if present)
  - [ ] Reply option (if present)

#### ✅ Test 7.3: Comment Quality
- [ ] Comments are appropriate
- [ ] Comments relate to proposals
- [ ] No spam or offensive content
- [ ] Comments load quickly

#### ✅ Test 7.4: User Interactions (if available)
- [ ] Can read comments without error
- [ ] Comments are sorted logically (newest, most popular, etc.)
- [ ] Comment count is accurate
- [ ] Scrolling through comments is smooth

#### ✅ Test 7.5: Comment Moderation
- [ ] No offensive/inappropriate comments visible
- [ ] Moderation policy being followed
- [ ] User community feels safe

**Notes:**
```
Comments loading: [ ] Yes [ ] No
Comment quality: [ ] Good [ ] Fair [ ] Poor
Any moderation issues: _______________
```

---

### Phase 8: Dark Mode Testing (10 minutes)

#### ✅ Test 8.1: Dark Mode Activation
- [ ] Open Settings (or system settings)
- [ ] Toggle dark mode on
  - [ ] App switches to dark theme
  - [ ] Colors are appropriate for dark background
  - [ ] Text is still readable
  - [ ] No white text on white background
  - [ ] No black text on black background

#### ✅ Test 8.2: Dark Mode Visual Check
- [ ] All screens display correctly in dark mode:
  - [ ] Voting interface
  - [ ] Analytics dashboard
  - [ ] Recommendations
  - [ ] Achievements
  - [ ] Discussions
  - [ ] Settings

#### ✅ Test 8.3: Dark Mode Readability
- [ ] Text contrast is adequate (WCAG AA compliant)
- [ ] All elements are visible
- [ ] Buttons are clearly distinguishable
- [ ] Icons are visible
- [ ] Charts/graphs are readable

#### ✅ Test 8.4: Light Mode Return
- [ ] Toggle light mode back on
- [ ] App switches back to light theme
- [ ] All elements display correctly

**Notes:**
```
Dark mode works: [ ] Yes [ ] No
Text readability: [ ] Good [ ] Fair [ ] Poor
Any dark mode issues: _______________
```

---

### Phase 9: Performance & Stability (15 minutes)

#### ✅ Test 9.1: App Responsiveness
- [ ] All buttons respond immediately to taps
- [ ] No frozen UI
- [ ] Transitions between screens are smooth
- [ ] No noticeable lag
- [ ] Animations are fluid

#### ✅ Test 9.2: Memory & Crashes
- [ ] App doesn't crash during testing
- [ ] No unexpected restarts
- [ ] App remains stable after extended use
- [ ] Memory usage reasonable (not constantly increasing)

#### ✅ Test 9.3: Network Handling
- [ ] Voting requests complete successfully
- [ ] Comments load without error
- [ ] Data syncs properly with backend
- [ ] No network timeout errors

#### ✅ Test 9.4: Stress Testing
- [ ] Rapid voting (vote 10+ times quickly)
  - [ ] All votes register
  - [ ] No data loss
  - [ ] App remains responsive
- [ ] Rapid tab switching
  - [ ] No crashes
  - [ ] Data integrity maintained
- [ ] Prolonged use (30+ minutes)
  - [ ] App remains stable
  - [ ] No memory leaks
  - [ ] Performance consistent

**Notes:**
```
App crashes: [ ] Yes [ ] No (number: ___)
Performance issues: _______________
Network reliability: [ ] Good [ ] Fair [ ] Poor
Stability rating: ___ / 10
```

---

### Phase 10: Accessibility Testing (Optional but Recommended - 10 minutes)

#### ✅ Test 10.1: VoiceOver (Screen Reader)
- [ ] Enable VoiceOver in Accessibility settings
- [ ] Navigate through app using VoiceOver
  - [ ] All elements are announced
  - [ ] Button labels are clear
  - [ ] Navigation is logical
  - [ ] No silent/unlabeled elements

#### ✅ Test 10.2: Text Size
- [ ] Adjust text size in Accessibility settings
  - [ ] All text remains readable
  - [ ] Layout doesn't break
  - [ ] No text cutoff
  - [ ] Information is still accessible

#### ✅ Test 10.3: Color Contrast
- [ ] Check text contrast in both light and dark modes
  - [ ] All text meets WCAG AA (4.5:1 for normal text)
  - [ ] Buttons are distinguishable
  - [ ] Important information isn't conveyed by color alone

**Notes:**
```
VoiceOver support: [ ] Good [ ] Fair [ ] Poor
Text size scaling: [ ] Works [ ] Issues
Contrast ratio: [ ] Good [ ] Fair [ ] Poor
```

---

## Summary Checklist

### Critical Features (Must Pass)
- [ ] App launches and doesn't crash
- [ ] Voting feature works (can cast and record votes)
- [ ] Vote data persists after app restart
- [ ] Analytics dashboard displays vote data
- [ ] Dark mode functions properly

### Important Features (Should Pass)
- [ ] Recommendations generate correctly
- [ ] Achievements unlock and display
- [ ] Comments load and display
- [ ] Navigation between tabs is smooth
- [ ] All UI elements are responsive

### Quality Standards (Nice to Have)
- [ ] Performance is smooth throughout
- [ ] Dark mode looks polished
- [ ] Accessibility features work
- [ ] Visual design is consistent
- [ ] App feels professional

---

## Overall Assessment

### Test Results
**Date Tested**: _____________  
**Device**: _____________  
**iOS Version**: _____________  
**Tester Name**: _____________  

### Summary
- **Total Tests**: 50+
- **Passed**: ___ / 50+
- **Failed**: ___ / 50+
- **Issues Found**: ___

### Critical Issues Found
```
1. ___________________________
2. ___________________________
3. ___________________________
```

### Minor Issues Found
```
1. ___________________________
2. ___________________________
```

### Overall Assessment
- [ ] ✅ **PASS** - Ready for App Store submission
- [ ] ⚠️ **CONDITIONAL PASS** - Ready with minor fixes
- [ ] ❌ **FAIL** - Needs significant work before submission

### Pass/Fail Reasoning
```
_______________________________________
_______________________________________
```

---

## Next Steps

### If PASS or CONDITIONAL PASS:
1. ✅ Proceed with screenshot capture (Sept 12)
2. ✅ Deploy privacy policy (Sept 13)
3. ✅ Enter metadata in App Store Connect (Sept 13-14)
4. ✅ Submit to App Store (Sept 15)

### If FAIL:
1. Document all issues found
2. Create bug report in GitHub Issues
3. Fix critical issues before submission
4. Retest before proceeding
5. Contact development team

---

## Testing Notes Section

Use this space to document any observations, issues, or notes during testing:

```
_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________
```

---

**Testing Complete!**  
*Thank you for thorough verification of the app before submission.*

**Estimated Time**: 2-3 hours  
**Estimated Completion**: September 11, 2026  
**Next Action**: Review results and proceed with screenshots (Sept 12)

---

*App Version: 1.0.1 (Build 13)*  
*TestFlight Build: Ready for verification*  
*Expected App Store Submission: September 15, 2026*
