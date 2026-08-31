import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'auth_provider.dart';
import 'product_provider.dart';
import 'request_provider.dart';
import 'user_provider.dart';
import 'certificate_provider.dart';
import 'review_provider.dart';

// Tracks whether the user has marked notifications as read in current session
final notificationReadStateProvider = StateProvider<bool>((ref) => false);

// Computes whether the current user has unread notification events
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  final isRead = ref.watch(notificationReadStateProvider);
  if (isRead) return false;

  final user = ref.watch(currentUserProvider).value;
  if (user == null) return false;

  final role = user.role;

  if (role == 'officer') {
    final products = ref.watch(allProductsProvider).value ?? [];
    final farmers = ref.watch(farmersProvider).value ?? [];
    final hasPendingProducts = products.any((p) => p.status == 'pending');
    final hasPendingFarmers = farmers.any((f) => f.status == 'pending');
    return hasPendingProducts || hasPendingFarmers;
  } else if (role == 'farmer') {
    final farmerRequests = ref.watch(farmerRequestsProvider).value ?? [];
    final hasPendingRequests = farmerRequests.any((r) => r.status == 'pending');
    final certificates = ref.watch(farmerCertificatesProvider(user.id)).value ?? [];
    final reviews = ref.watch(farmerReviewsProvider(user.id)).value ?? [];
    return hasPendingRequests || certificates.isNotEmpty || reviews.isNotEmpty;
  } else {
    // Buyer
    final buyerRequests = ref.watch(buyerRequestsProvider).value ?? [];
    final hasActiveUpdates = buyerRequests.any((r) => r.status == 'accepted' || r.status == 'rejected');
    return hasActiveUpdates || buyerRequests.isNotEmpty;
  }
});
