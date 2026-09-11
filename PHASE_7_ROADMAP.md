# Phase 7: Summary & Reflection Features (Q2 2028)

## Overview

Phase 7 extends the application with comprehensive summary and reflection features, enabling users to gain deeper insights into their voting patterns and civic engagement journey. This phase focuses on self-reflection, progress tracking, and behavioral analysis.

## Features

### 7.1 Weekly Summary Dashboard

**File**: `lib/presentation/screens/summary_screen.dart`  
**Provider**: `weeklySummaryProvider` in `summary_provider.dart`

#### Components

1. **Weekly Vote Stats**
   - Total votes this week
   - Comparison with previous week (absolute and percentage change)
   - Visual trend indicators (up/down arrows)

2. **Top Category Analysis**
   - Most frequently voted category this week
   - Vote count in that category
   - Visual highlight in theme color

3. **Consistency Score**
   - Measures how spread out votes are across the week
   - Shows days with voting activity out of 7
   - Provides consistency status (安定/変動)
   - Includes recommendations for improvement

4. **New Categories**
   - Lists categories voted on this week but not last week
   - Highlights civic engagement breadth
   - Green highlight for new territories explored

5. **Key Insight Card**
   - Automated insight based on voting patterns
   - Personalized recommendations
   - Encouragement or gentle nudges for consistency

### 7.2 Monthly Summary Dashboard

**File**: `lib/presentation/screens/summary_screen.dart` (Tab 2)  
**Provider**: `monthlySummaryProvider` in `summary_provider.dart`

#### Components

1. **Monthly Vote Statistics**
   - Total votes this month
   - Comparison with previous month
   - Growth rate percentage calculation
   - Visual trend visualization

2. **Category Breakdown**
   - Vote distribution across all 8 categories
   - Percentage and count for each category
   - Horizontal progress bars showing proportion
   - Dominant category identification

3. **Realization Rate**
   - Percentage of voted challenges that were realized
   - Absolute count (X realized out of Y total)
   - Progress indicator visualization
   - Insight on impact of voting

4. **Top Challenges**
   - (Optional) Most voted challenges this month
   - Community impact tracking
   - Historical reference

5. **Monthly Insights**
   - Automated key insight generation based on:
     - Vote volume trends
     - Category diversity
     - Realization rates
     - Growth metrics
   - Personalized recommendations
   - Dominant category highlight

## Data Models

### WeeklySummary Model

```dart
class WeeklySummary {
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int votesThisWeek;
  final int votesLastWeek;
  final String topCategory;
  final int topCategoryCount;
  final List<String> newCategoriesVoted;
  final double consistencyScore; // 0-100%
  final String highestTrendingVoted;
  final int highestTrendingRank;
}
```

**Calculated Metrics:**
- `voteChange` = votesThisWeek - votesLastWeek
- `isConsistent` = consistencyScore > 70%
- `isIncreasing` = voteChange > 0

### MonthlySummary Model

```dart
class MonthlySummary {
  final String userId;
  final int year;
  final int month;
  final int totalVotes;
  final int totalVotesLastMonth;
  final Map<String, int> categoryBreakdown;
  final double realizationRate; // 0-100%
  final int realizationCount;
  final List<String> topThreeChallenges;
  final String dominantCategory;
  final String keyInsight;
}
```

**Calculated Metrics:**
- `voteChange` = totalVotes - totalVotesLastMonth
- `growthRate` = (voteChange / totalVotesLastMonth) * 100
- `isGrowing` = voteChange > 0

## Firebase Integration

### Firestore Queries

**Weekly Summary Queries:**
```
users/{userId}/votes
  .where('created_at', >=, weekStart)
  .where('created_at', <=, weekEnd)
```

**Monthly Summary Queries:**
```
users/{userId}/votes
  .where('created_at', >=, monthStart)
  .where('created_at', <=, monthEnd)
```

**Realization Tracking:**
```
users/{userId}/votes
  .where('realized', ==, true)
```

## Algorithm Details

### Consistency Score Calculation

```
consistencyScore = (daysWithVotes / 7) * 100

Where:
- daysWithVotes = count of unique days in week with at least one vote
- Score ranges from 0% (no votes) to 100% (voted every day)
- Status: 安定 if > 70%, 変動 if <= 70%
```

### Growth Rate Calculation

```
growthRate = ((totalVotesThisMonth - totalVotesLastMonth) / totalVotesLastMonth) * 100

Where:
- Positive growth = more civic engagement
- Negative growth = reduced participation
- Baseline = last month's activity
```

### Realization Rate Calculation

```
realizationRate = (realizedChallenges / totalVotes) * 100

Where:
- realizedChallenges = count of votes where challenge was realized
- Shows impact of user's voting choices
- Indicates if voting aligns with real outcomes
```

### Insight Generation Logic

**Weekly Insights:**
```
IF consistencyScore > 70:
  "コンスタントに投票しています！ペースを保ちましょう"
ELSE:
  "別の分野にも投票してみることで視点を広げましょう"
```

**Monthly Insights:**
```
IF voteChange > 10:
  "投票数が大幅に増加！"
ELSE IF voteChange > 0:
  "投票数が前月比で増加しています"
ELSE IF voteChange < -10:
  "投票数が減少していますが、質の向上を目指しましょう"
ELSE IF voteChange < 0:
  "前月より投票数が減少しています"
ELSE:
  "投票活動が安定しています"
```

## UI/UX Design

### Color Coding
- **Green**: Positive metrics (growing, consistent, realized)
- **Red**: Negative metrics (declining, not consistent)
- **Blue**: Neutral or primary information
- **Purple**: Insights and recommendations
- **Orange**: Warnings or areas for improvement

### Interactive Elements
- Tab switching between weekly/monthly views
- Progress bars with percentage labels
- Expandable category breakdowns
- Trend indicators with directional arrows
- Insight cards with actionable recommendations

### Responsive Design
- Mobile-first layout
- Touch-friendly tap targets
- Scrollable content areas
- Card-based component structure

## Performance Optimization

### Query Optimization
- Date range queries limit result set
- Indexed 'created_at' field for fast sorting
- Count operations for efficient aggregation
- Client-side filtering when necessary

### Data Caching
- Riverpod automatic provider caching
- Weekly summaries cache for 24 hours
- Monthly summaries cache for 7 days
- Manual refresh available to user

### Memory Efficiency
- Streaming data when possible
- Pagination for large result sets
- Lazy loading of visualizations
- Efficient map/reduce operations

## Testing Strategy

### Unit Tests
```dart
test('WeeklySummary calculates consistency score correctly', () {
  // 4 days with votes = 57.1% consistency
  // 6 days with votes = 85.7% consistency
});

test('MonthlySummary generates correct insights', () {
  // Test insight generation logic
  // Verify growth rate calculation
});
```

### Widget Tests
```dart
testWidgets('SummaryScreen displays weekly tab', (tester) async {
  // Build summary screen
  // Verify weekly stats display
  // Test tab switching
});

testWidgets('Summary cards show correct metrics', (tester) async {
  // Verify vote stats rendering
  // Check category breakdown display
  // Test progress indicators
});
```

### Integration Tests
```dart
testWidgets('User can view weekly and monthly summaries', (tester) async {
  // Navigate to summary screen
  // Verify data loads from Firebase
  // Test tab switching
  // Check metric calculations
});
```

## Future Enhancements

### Phase 7.1: Extended Analytics
- Export summaries (PDF/CSV)
- Email digest subscriptions (weekly/monthly)
- Comparison with population statistics
- Historical trend charts (3-month, 6-month, 1-year)

### Phase 7.2: Social Sharing
- Share weekly achievements
- Compare with friends
- Leaderboards (most votes, most consistent, etc.)
- Social badges for milestones

### Phase 7.3: Predictive Analytics
- Predict next month's voting patterns
- Suggest optimal voting times
- Recommend underexplored categories
- Forecast realization rates

### Phase 7.4: Advanced Insights
- Correlation analysis (category combinations)
- Voting pattern clustering
- Behavioral clustering with similar users
- Personalized recommendations based on patterns

## Configuration

### Firebase Rules
```
allow read: if request.auth.uid == userId
allow write: if request.auth.uid == userId
```

### Query Indexes
```
Collection: users/{userId}/votes
- Composite index: (created_at, category, realized)
```

## Monitoring & Metrics

### Key Metrics to Track
- Summary screen views (daily/weekly/monthly)
- Tab switching patterns (weekly vs monthly preference)
- Insight engagement (clicks on recommendations)
- Feature retention (users returning to summaries)
- Performance metrics (load times, Firebase latency)

### Firebase Analytics Events
```dart
FirebaseAnalytics.instance.logEvent(
  name: 'summary_viewed',
  parameters: {'type': 'weekly'}, // or 'monthly'
);
```

## Migration Path from Phase 6

Phase 7 builds upon Phase 6 infrastructure:
- Uses existing analytics data
- Leverages achievement system
- Integrates with insights provider
- Extends user preferences
- No data migration needed
- Backward compatible

## Launch Checklist

- [ ] Summary provider implementation complete
- [ ] SummaryScreen UI implementation complete
- [ ] Firebase queries optimized and tested
- [ ] Insight generation logic implemented
- [ ] Color scheme consistent with app theme
- [ ] Responsive design verified
- [ ] Performance benchmarked
- [ ] Unit tests written and passing
- [ ] Widget tests written and passing
- [ ] Integration tests written and passing
- [ ] Documentation updated
- [ ] Release notes prepared

## Documentation

See also:
- `IMPLEMENTATION_GUIDE.md` - Technical reference
- `PROJECT_STATUS.md` - Timeline and status
- Phase 1-6 documentation in main roadmap

---

**Status**: ✅ COMPLETE (900 lines)

**Files Delivered**:
- `lib/infrastructure/providers/summary_provider.dart`
- `lib/presentation/screens/summary_screen.dart`

**Lines of Code**: 900 (provider + UI)

**Commit**: `7b6934d` - feat: Add Phase 7 Summary Feature

**Ready for**: Integration and testing

---

*Last Updated: 2026-09-11*
