import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/good_news_item.dart';
import '../usecases/load_good_news.dart';

final goodNewsProvider = Provider<List<GoodNewsItem>>((ref) {
  return LoadGoodNews.call();
});
