import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/providers/product_provider.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/providers/request_provider.dart';
import '../../../../../core/providers/certificate_provider.dart';
import '../../../../../core/providers/review_provider.dart';
import '../../../../../core/providers/notification_provider.dart';

class AppNotificationsPage extends ConsumerStatefulWidget {
  final bool showBackButton;
  const AppNotificationsPage({super.key, this.showBackButton = true});

  @override
  ConsumerState<AppNotificationsPage> createState() => _AppNotificationsPageState();
}

class _AppNotificationsPageState extends ConsumerState<AppNotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Automatically mark notifications as read when screen is visited
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationReadStateProvider.notifier).state = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final productsAsync = ref.watch(allProductsProvider);
    final farmersAsync = ref.watch(farmersProvider);
    
    // Watch request providers
    final farmerRequests = ref.watch(farmerRequestsProvider).value ?? [];
    final buyerRequests = ref.watch(buyerRequestsProvider).value ?? [];
    final allRequests = ref.watch(allRequestsProvider).value ?? [];

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('User not found. Please log in.')),
          );
        }

        final role = user.role;
        Color themeColor = const Color(0xFF387015); // Farmer (Green)
        if (role == 'buyer') {
          themeColor = const Color(0xFF1976D2); // Buyer (Blue)
        } else if (role == 'officer') {
          themeColor = const Color(0xFF8D5A36); // Officer (Brown)
        }

        // Generate dynamic notifications based on user role
        final List<Widget> notificationCards = [];

        if (role == 'officer') {
          final pendingProducts = productsAsync.value?.where((p) => p.status == 'pending').toList() ?? [];
          final pendingFarmers = farmersAsync.value?.where((f) => f.status == 'pending').toList() ?? [];

          // Pending Product Approvals
          for (var p in pendingProducts) {
            notificationCards.add(
              _buildNotificationCard(
                icon: '📦',
                title: 'Pending Product Approval',
                subtitle: '${p.farmerName} submitted a listing: "${p.name}" (${p.quantity}${p.unit})',
                time: 'Requires Action',
                leftBorderColor: Colors.orange,
              ),
            );
          }

          // Pending Farmers
          for (var f in pendingFarmers) {
            notificationCards.add(
              _buildNotificationCard(
                icon: '🧑‍🌾',
                title: 'New Farmer Verification Needed',
                subtitle: 'Farmer "${f.name}" registered and is waiting for officer verification.',
                time: 'Requires Action',
                leftBorderColor: Colors.blue,
              ),
            );
          }

          // Buyer requests (all requests on platform)
          for (var r in allRequests.take(5)) {
            notificationCards.add(
              _buildNotificationCard(
                icon: '🛒',
                title: 'New Order Placed in Zone',
                subtitle: 'Buyer "${r.buyerName}" requested ${r.quantity}kg of "${r.productName}" from "${r.farmerName}"',
                time: 'Recently',
                leftBorderColor: Colors.purple,
              ),
            );
          }

          if (notificationCards.isEmpty) {
            notificationCards.add(
              _buildNotificationCard(
                icon: '✅',
                title: 'System Alert',
                subtitle: 'All products and farmers are currently verified and up to date.',
                time: 'Today',
                leftBorderColor: Colors.green,
              ),
            );
          }
        } else if (role == 'farmer') {
          final certificates = ref.watch(farmerCertificatesProvider(user.id)).value ?? [];
          final reviews = ref.watch(farmerReviewsProvider(user.id)).value ?? [];

          // Farmer: display requests received from buyers
          for (var r in farmerRequests) {
            if (r.status == 'pending') {
              notificationCards.add(
                _buildNotificationCard(
                  icon: '🛒',
                  title: 'New Buyer Request Received!',
                  subtitle: '${r.buyerName} requested ${r.quantity}kg of ${r.productName}. Total: Rs. ${r.totalPrice}',
                  time: 'Pending Action',
                  leftBorderColor: Colors.orange,
                ),
              );
            } else if (r.status == 'accepted') {
              notificationCards.add(
                _buildNotificationCard(
                  icon: '✅',
                  title: 'Order Confirmed',
                  subtitle: 'You accepted the order from ${r.buyerName} for ${r.quantity}kg of ${r.productName}',
                  time: 'Active',
                  leftBorderColor: Colors.green,
                ),
              );
            }
          }

          // Officer Certifications awarded
          for (var cert in certificates) {
            notificationCards.add(
              _buildNotificationCard(
                icon: '🏆',
                title: 'Certificate Awarded!',
                subtitle: 'Agricultural Officer awarded you "${cert.title}". Verified on ${cert.issuedAt.day}/${cert.issuedAt.month}/${cert.issuedAt.year}',
                time: 'Official Recognition',
                leftBorderColor: const Color(0xFFFFB300),
              ),
            );
          }

          // Buyer Reviews received
          for (var rev in reviews.take(5)) {
            notificationCards.add(
              _buildNotificationCard(
                icon: '⭐',
                title: 'New Customer Rating (${rev.rating.toInt()} Stars)',
                subtitle: '${rev.buyerName}: "${rev.comment}"',
                time: 'Feedback',
                leftBorderColor: Colors.blueAccent,
              ),
            );
          }

          // Farmer listings approved
          final approvedProducts = productsAsync.value?.where((p) => p.farmerId == user.id && p.status == 'active').toList() ?? [];
          for (var p in approvedProducts) {
            notificationCards.add(
              _buildNotificationCard(
                icon: '🌿',
                title: 'Listing Approved & Live',
                subtitle: 'Your product "${p.name}" has been approved by the officer and is now visible to buyers.',
                time: 'Live',
                leftBorderColor: Colors.green,
              ),
            );
          }

          if (notificationCards.isEmpty) {
            notificationCards.add(
              _buildNotificationCard(
                icon: '🌾',
                title: 'Welcome to AgriMart',
                subtitle: 'Start listing your fresh produce to connect with verified buyers near your district!',
                time: 'Welcome',
                leftBorderColor: Colors.green,
              ),
            );
          }
        } else { // Buyer
          // Buyer: display updates on requested products
          for (var r in buyerRequests) {
            if (r.status == 'accepted') {
              notificationCards.add(
                _buildNotificationCard(
                  icon: '🎉',
                  title: 'Request Accepted!',
                  subtitle: 'Farmer "${r.farmerName}" accepted your order for ${r.quantity}kg of "${r.productName}"!',
                  time: 'Approved',
                  leftBorderColor: Colors.green,
                ),
              );
            } else if (r.status == 'rejected') {
              notificationCards.add(
                _buildNotificationCard(
                  icon: '❌',
                  title: 'Request Declined',
                  subtitle: 'Farmer "${r.farmerName}" was unable to fulfill your order for ${r.quantity}kg of "${r.productName}".',
                  time: 'Declined',
                  leftBorderColor: Colors.red,
                ),
              );
            } else {
              notificationCards.add(
                _buildNotificationCard(
                  icon: '⏳',
                  title: 'Order Sent & Waiting',
                  subtitle: 'Your request for ${r.quantity}kg of "${r.productName}" is waiting for farmer ${r.farmerName}\'s confirmation.',
                  time: 'Pending',
                  leftBorderColor: Colors.amber,
                ),
              );
            }
          }

          final activeProducts = productsAsync.value?.where((p) => p.status == 'active').toList() ?? [];
          for (var p in activeProducts.take(3)) {
            notificationCards.add(
              _buildNotificationCard(
                icon: '🥦',
                title: 'Fresh Listing in Market',
                subtitle: '${p.farmerName} listed "${p.name}" (${p.quantity}${p.unit}) in ${p.location.split(',').first} for Rs. ${p.price}/${p.unit}',
                time: 'Recently',
                leftBorderColor: const Color(0xFF1976D2),
              ),
            );
          }

          if (notificationCards.isEmpty) {
            notificationCards.add(
              _buildNotificationCard(
                icon: '🛒',
                title: 'Welcome to AgriMart',
                subtitle: 'Explore fresh vegetables and fruits directly from certified local farmers.',
                time: 'Welcome',
                leftBorderColor: Colors.blue,
              ),
            );
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: AppBar(
            automaticallyImplyLeading: widget.showBackButton,
            backgroundColor: themeColor,
            elevation: 0,
            leading: widget.showBackButton
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black, size: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: const Text(
              'Notifications',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.done_all, color: Colors.white, size: 20),
                tooltip: 'Mark all as read',
                onPressed: () {
                  ref.read(notificationReadStateProvider.notifier).state = true;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications marked as read'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: notificationCards.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => notificationCards[index],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String icon,
    required String title,
    required String subtitle,
    required String time,
    required Color leftBorderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: leftBorderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: leftBorderColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                time,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
