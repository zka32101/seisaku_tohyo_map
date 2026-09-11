# 政策投票マップ - Implementation Guide

## Project Overview

政策投票マップ is a Flutter mobile application that enables citizens to visualize and vote on Japanese Diet (国会) legislation, fostering civic engagement and political participation.

## Architecture

### Technology Stack
- **Frontend**: Flutter 3.12+ with Material Design 3
- **State Management**: Riverpod 2.4+
- **Backend**: Firebase (Firestore, Auth, Analytics, Messaging, Performance, Crashlytics)
- **Local Storage**: Hive 2.2+ for persistent preferences
- **Charts**: FL Chart 0.69+ for data visualization
- **Internationalization**: Ready for multiple language support

### Project Structure

```
lib/
├── application/           # App-level setup and configuration
├── domain/               # Business logic and models
│   └── models/
│       └── user_analytics.dart
├── infrastructure/       # Data layer and providers
│   ├── analytics/
│   ├── donation/
│   ├── firebase/
│   ├── local_storage/
│   ├── notifications/
│   └── providers/        # Riverpod state management
│       ├── analytics_provider.dart
│       ├── achievement_provider.dart
│       ├── discussion_provider.dart
│       ├── insights_provider.dart
│       ├── recommendation_provider.dart
│       ├── search_provider.dart
│       ├── trending_provider.dart
│       └── user_preferences_provider.dart
├── presentation/         # UI layer
│   ├── screens/         # Screen implementations
│   │   ├── interest_setup_screen.dart
│   │   ├── advanced_search_screen.dart
│   │   ├── my_analytics_screen.dart
│   │   ├── trending_challenges_screen.dart
│   │   ├── recommendations_screen.dart
│   │   ├── achievements_screen.dart
│   │   ├── challenge_discussion_screen.dart
│   │   └── insights_screen.dart
│   └── theme/
│       └── app_theme.dart
└── utils/
```

## Feature Implementation Details

### Phase 1: UX & Personal Interest Analysis Foundation

#### 1.1 Interest Setup Onboarding
- **File**: `lib/presentation/screens/interest_setup_screen.dart`
- **Provider**: `selectedInterestsProvider` in `user_preferences_provider.dart`
- **Features**:
  - Multi-select categories with CheckboxListTile
  - Automatic persistence via Hive
  - Validates at least one category selected before completion

```dart
// Usage
ref.watch(selectedInterestsProvider);
ref.read(selectedInterestsProvider.notifier).toggle(category);
```

#### 1.2 Dark Mode Theme
- **Files**: 
  - `lib/presentation/theme/app_theme.dart` - Theme definitions
  - `lib/infrastructure/providers/user_preferences_provider.dart` - ThemeModeNotifier
- **Features**:
  - Light and dark ThemeData with Material Design 3
  - Automatic persistence of user preference
  - System-aware fallback when set to 'system'

```dart
// Theme usage in main.dart
themeMode: ThemeMode.light,
theme: AppTheme.light,
darkTheme: AppTheme.dark,
```

#### 1.3 Advanced Search & Filtering
- **Files**:
  - `lib/presentation/screens/advanced_search_screen.dart` - UI
  - `lib/infrastructure/providers/search_provider.dart` - Logic
- **Features**:
  - Keyword-based search with client-side filtering
  - Multi-select category filters
  - Sort options: relevance, newest, popular
  - Real-time search results

```dart
// Usage
final results = ref.watch(searchProvider(SearchParams(
  query: 'keyword',
  categories: ['経済・財政'],
  sortBy: 'relevance',
)));
```

### Phase 2: Personal Interest Analytics Dashboard

#### 2.1 Analytics Dashboard
- **File**: `lib/presentation/screens/my_analytics_screen.dart`
- **Provider**: `analyticsProvider` in `analytics_provider.dart`
- **Visualizations**:
  - Pie chart: Category vote distribution
  - Line chart: 3-month vote trends
  - Progress indicator: Realization rate
  - Trend cards: Month-over-month comparison

#### 2.2 Trending Challenges
- **Files**:
  - `lib/presentation/screens/trending_challenges_screen.dart` - UI
  - `lib/infrastructure/providers/trending_provider.dart` - Logic
- **Features**:
  - Top 10 challenges by weekly vote count
  - Rank-based visual hierarchy (Gold/Silver/Bronze)
  - Vote change indicators with color coding

### Phase 3: Recommendation Engine & Personalization

#### 3.1 Personalized Recommendations
- **Files**:
  - `lib/presentation/screens/recommendations_screen.dart` - UI
  - `lib/infrastructure/providers/recommendation_provider.dart` - Logic
- **Algorithm**:
  - Weighted scoring: category (50%), recency (25%), popularity (25%)
  - Category relevance: exact matches (1.0), related (0.6), other (0.2)
  - Excludes challenges user already voted on
  - Supports up to 20 recommendations per request

```dart
// Algorithm formula
relevanceScore = (categoryWeight * 0.5) +
                 (recencyWeight * 0.25) +
                 (popularityWeight * 0.25)
```

### Phase 4: Achievement & Gamification

#### 4.1 Achievement System
- **Files**:
  - `lib/presentation/screens/achievements_screen.dart` - UI
  - `lib/infrastructure/providers/achievement_provider.dart` - Logic
- **Achievement Types**:
  - Vote milestones: 1st, 10th, 50th, 100th vote
  - Category master: Vote in all 8 categories
  - Trending voter: Vote on #1 trending challenge
  - Voting streak: 7 consecutive voting days
- **Features**:
  - Automatic unlock on achievement conditions
  - Progress tracking and completion percentage
  - Visual grid layout with emoji icons

### Phase 5: Social Features & Discussion

#### 5.1 Challenge Discussion
- **Files**:
  - `lib/presentation/screens/challenge_discussion_screen.dart` - UI
  - `lib/infrastructure/providers/discussion_provider.dart` - Logic
- **Features**:
  - Nested comment threads per challenge
  - Optional user display names (defaults to "匿名ユーザー")
  - Like system for community feedback
  - Real-time comment refresh with Riverpod

```dart
// Add comment
await addDiscussionComment(
  challengeId: 'challenge_id',
  userId: 'user_id',
  displayName: 'User Name',
  content: 'Comment text',
);

// Like comment
await likeDiscussionComment(
  challengeId: 'challenge_id',
  commentId: 'comment_id',
);
```

### Phase 6: Advanced Analytics & Insights

#### 6.1 Insights Dashboard
- **Files**:
  - `lib/presentation/screens/insights_screen.dart` - UI
  - `lib/infrastructure/providers/insights_provider.dart` - Logic
- **Metrics**:
  - Voting consistency (0-100%)
  - Category diversity percentage
  - Days since last vote / predicted next vote
  - Most active category
- **Political Affinity**:
  - Conservative vs progressive score
  - Spectrum visualization with color coding
  - Dominant leaning classification

## Riverpod State Management Patterns

### AsyncValue Patterns
```dart
// Handling async state
ref.watch(provider).when(
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error: error),
  data: (data) => ContentWidget(data: data),
);
```

### Family Providers (Parameterized)
```dart
// Define with parameters
final myProvider = FutureProvider.family<Result, String>((ref, param) async {
  // Use param in logic
  return await fetchData(param);
});

// Use with parameter
ref.watch(myProvider('parameter'));
```

### StateNotifier for Persistent State
```dart
class MyNotifier extends StateNotifier<AsyncValue<List<String>>> {
  MyNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    // Initialize from Hive
  }

  Future<void> updateState(String value) async {
    // Update both memory and Hive
  }
}
```

## Firebase Integration

### Firestore Structure
```
users/
├── {userId}/
│   ├── votes/
│   │   └── {voteId}/
│   │       ├── challenge_id
│   │       ├── category
│   │       ├── realized (boolean)
│   │       └── created_at
│   ├── achievements/
│   │   └── {achievementId}/
│   │       └── unlocked_at
│   └── preferences/
│       ├── selected_interests
│       └── theme_mode

challenges/
├── {challengeId}/
│   ├── title
│   ├── description
│   ├── category
│   ├── vote_count
│   ├── created_at
│   └── discussions/
│       └── {commentId}/
│           ├── user_id
│           ├── user_display_name
│           ├── content
│           ├── likes
│           └── created_at
```

### Query Patterns

#### Efficient Vote Counting
```dart
// Use count() for large collections
final snapshot = await firestore
    .collection('challenges')
    .doc(challengeId)
    .collection('votes')
    .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
    .count()
    .get();
final voteCount = snapshot.count;
```

#### Date Range Filtering
```dart
final start = DateTime(2024, 1, 1);
final end = DateTime(2024, 1, 31);

final snapshot = await firestore
    .collection('users')
    .doc(userId)
    .collection('votes')
    .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
    .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(end))
    .get();
```

## Testing Strategy

### Unit Tests
```dart
// Test Riverpod providers
test('selectedInterestsProvider loads from Hive', () async {
  // Mock Hive box
  // Verify provider initialization
});
```

### Widget Tests
```dart
// Test UI components
testWidgets('InterestSetupScreen displays all categories', (tester) async {
  // Build widget
  // Verify all categories render
  // Test selection logic
});
```

### Integration Tests
```dart
// Test complete flows
testWidgets('User can vote and see analytics', (tester) async {
  // Navigate through app
  // Perform voting action
  // Verify analytics update
});
```

## Performance Optimization

### List Pagination
```dart
// Limit initial queries
final snapshot = await firestore
    .collection('discussions')
    .orderBy('created_at', descending: true)
    .limit(50)
    .get();
```

### Cached Providers
```dart
// Riverpod automatically caches data
// Refresh only when needed
ref.refresh(analyticsProvider(userId));
```

### Image Optimization
- Use proper image formats and sizes
- Lazy load images in lists
- Cache images locally with image_cache

## Error Handling

### Graceful Degradation
```dart
// Return default values on error
} catch (e) {
  return UserAnalytics(
    userId: userId,
    totalVotes: 0,
    categoryCounts: {},
    // ... other defaults
  );
}
```

### User-Facing Errors
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('エラー: ${e.message}')),
);
```

## Localization Ready

Current implementation supports future localization:
- All UI strings use constants
- Japanese strings ready for extraction
- Riverpod can provide locale-specific data

## Accessibility

### Implementation
- Proper contrast ratios (Material Design 3)
- Semantic labels for icons
- TextField hints for form inputs
- Clear error messages

### Testing
- Test with screen readers (TalkBack/VoiceOver)
- Verify color contrast ratios
- Test keyboard navigation

## Build & Deployment

### Local Build
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run linter
flutter analyze

# Run tests
flutter test

# Build iOS release
flutter build ios --release
```

### CI/CD Pipeline
- GitHub Actions workflows
- Automated testing on each commit
- Build matrix for multiple iOS versions
- Automatic TestFlight upload on main branch

## Monitoring & Analytics

### Firebase Analytics
- Track user engagement
- Monitor feature usage
- Identify user drop-off points

### Crashlytics
- Automatic crash reporting
- Error stack traces
- Performance metrics

### Custom Events
```dart
FirebaseAnalytics.instance.logEvent(
  name: 'vote_submitted',
  parameters: {'category': category},
);
```

## Future Enhancements

### Phase 3 Refinement
- Machine learning for better recommendations
- Collaborative filtering based on similar users
- A/B testing recommendation algorithms

### Phase 4 Expansion
- Seasonal achievements
- Weekly/monthly leaderboards
- Social achievement sharing

### Phase 5 Social
- User profiles with voting history
- Follow other voters
- Comment notifications

### Phase 6 Advanced
- Export analytics reports (PDF/CSV)
- Comparative analysis vs population
- Policy impact tracking

## Documentation

- **Architecture**: See ARCHITECTURE.md
- **Contributing**: See CONTRIBUTING.md
- **API Reference**: See API.md
- **Changelog**: See CHANGELOG.md

## Support & Contact

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Email**: support@nihon-future-map.jp

---

**Last Updated**: 2026-09-11
**Version**: 1.0.1
**Status**: Ready for App Store Submission
