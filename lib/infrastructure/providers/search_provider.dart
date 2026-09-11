import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for search results
class SearchResult {
  final String id;
  final String title;
  final String description;
  final String category;
  final int voteCount;
  final DateTime createdAt;

  SearchResult({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.voteCount,
    required this.createdAt,
  });

  factory SearchResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SearchResult(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      voteCount: data['vote_count'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Search parameters
class SearchParams {
  final String query;
  final List<String> categories;
  final String sortBy; // 'relevance', 'newest', 'popular'

  SearchParams({
    required this.query,
    this.categories = const [],
    this.sortBy = 'relevance',
  });
}

/// Riverpod provider for search functionality
final searchProvider =
    FutureProvider.family<List<SearchResult>, SearchParams>((ref, params) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Base query
    Query query = firestore.collection('challenges');

    // Apply category filter if provided
    if (params.categories.isNotEmpty) {
      query = query.where('category', whereIn: params.categories);
    }

    final snapshot = await query.get();
    var results = snapshot.docs
        .map((doc) => SearchResult.fromFirestore(doc))
        .toList();

    // Client-side keyword filtering
    if (params.query.isNotEmpty) {
      final keywords = params.query.toLowerCase().split(' ');
      results = results.where((result) {
        final searchText =
            '${result.title} ${result.description}'.toLowerCase();
        return keywords.every((keyword) => searchText.contains(keyword));
      }).toList();
    }

    // Sort results
    results = _rankByRelevance(results, params);

    return results;
  } catch (e) {
    return [];
  }
});

/// Rank search results by specified criteria
List<SearchResult> _rankByRelevance(List<SearchResult> results, SearchParams params) {
  switch (params.sortBy) {
    case 'newest':
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case 'popular':
      results.sort((a, b) => b.voteCount.compareTo(a.voteCount));
      break;
    case 'relevance':
    default:
      // Simple relevance: match position and popularity combined
      if (params.query.isNotEmpty) {
        final query = params.query.toLowerCase();
        results.sort((a, b) {
          final aTitle = a.title.toLowerCase();
          final bTitle = b.title.toLowerCase();

          final aContainsQuery = aTitle.contains(query);
          final bContainsQuery = bTitle.contains(query);

          if (aContainsQuery && !bContainsQuery) return -1;
          if (!aContainsQuery && bContainsQuery) return 1;

          // If both or neither contain query, sort by vote count
          return b.voteCount.compareTo(a.voteCount);
        });
      } else {
        results.sort((a, b) => b.voteCount.compareTo(a.voteCount));
      }
  }

  return results;
}
