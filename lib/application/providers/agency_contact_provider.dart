import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/agency_contact.dart';
import '../usecases/load_agency_contacts.dart';

final agencyContactsProvider =
    FutureProvider.family<List<AgencyContact>, String>((ref, challengeId) {
      return Future.value(LoadAgencyContacts.forChallenge(challengeId));
    });
