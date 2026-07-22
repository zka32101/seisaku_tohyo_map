import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/macro_dashboard.dart';
import '../usecases/load_macro_dashboard.dart';

final macroDashboardProvider = FutureProvider<MacroDashboard>((ref) {
  return Future.value(LoadMacroDashboard.call());
});
