import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/international_comparison.dart';
import '../usecases/load_international_comparisons.dart';

final internationalComparisonProvider =
    Provider.family<InternationalComparison?, String>((ref, id) {
      return LoadInternationalComparisons.forId(id);
    });
