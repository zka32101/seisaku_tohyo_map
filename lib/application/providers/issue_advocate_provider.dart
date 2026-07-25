import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/issue_advocate.dart';
import '../usecases/load_issue_advocates.dart';

final issueAdvocatesProvider =
    FutureProvider.family<List<IssueAdvocate>, String>((ref, challengeId) {
      return Future.value(LoadIssueAdvocates.forChallenge(challengeId));
    });
