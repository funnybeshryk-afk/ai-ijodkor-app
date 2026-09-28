import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/env.dart';
import '../../data/models/parent_records.dart';
import '../../data/providers.dart';

/// Children linked to the signed-in parent.
final childrenProvider = FutureProvider<List<Child>>((ref) async {
  final repo = ref.watch(parentRepositoryProvider);
  final parentId = await ref.watch(currentUserIdProvider.future);
  if (repo == null || parentId == null) throw StateError('No signed-in parent');
  return repo.fetchChildren(parentId);
});

final childOverviewProvider = FutureProvider.family<ChildOverview, String>((
  ref,
  childId,
) async {
  final repo = ref.watch(parentRepositoryProvider);
  if (repo == null) throw StateError('No parent repository');
  return repo.fetchChildOverview(childId);
});

/// Which child is shown when several are linked (null = the first one).
class SelectedChild extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String childId) => state = childId;
}

final selectedChildProvider = NotifierProvider<SelectedChild, String?>(
  SelectedChild.new,
);

/// Where the payment and contact buttons lead.
class PaymentLinks {
  const PaymentLinks({
    required this.paymentUrl,
    required this.telegramUrl,
    required this.phone,
  });

  /// Online payment page; empty while the platform has none.
  final String paymentUrl;
  final String telegramUrl;
  final String phone;

  bool get canPayOnline => paymentUrl.isNotEmpty;

  /// Payment page for one month of one child via [provider] (click/payme).
  Uri paymentUri({
    required String provider,
    required String childId,
    required String period,
  }) => Uri.parse(paymentUrl).replace(
    queryParameters: {
      ...Uri.parse(paymentUrl).queryParameters,
      'provider': provider,
      'student': childId,
      'period': period,
    },
  );
}

final paymentLinksProvider = Provider<PaymentLinks>(
  (ref) => const PaymentLinks(
    paymentUrl: Env.paymentUrl,
    telegramUrl: Env.contactTelegramUrl,
    phone: Env.contactPhone,
  ),
);
