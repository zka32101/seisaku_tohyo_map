import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/glossary_term.dart';
import '../usecases/load_glossary_terms.dart';

final glossaryTermsProvider = Provider<List<GlossaryTerm>>((ref) {
  return LoadGlossaryTerms.call();
});

// 用語集画面の検索キーワード
final glossarySearchQueryProvider = StateProvider<String>((ref) => '');
