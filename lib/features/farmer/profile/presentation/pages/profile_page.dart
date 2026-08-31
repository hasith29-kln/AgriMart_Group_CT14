import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/providers/product_provider.dart';
import '../../../../../core/providers/request_provider.dart';
import '../../../../../core/providers/review_provider.dart';
import '../../../../../core/providers/certificate_provider.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../comman/notifications/presentation/pages/app_notifications_page.dart';
import '../widgets/certificate_viewer_dialog.dart';
import '../../../../../core/utils/url_helper.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const Color _green = Color(0xFF387015);
  static const Color _darkGreen = Color(0xFF24480E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final products = ref.watch(farmerProductsProvider).value ?? [];
    final requests = ref.watch(farmerRequestsProvider).value ?? [];

    int activeListings = products.length;
    int totalRequests = requests.length;
    int soldCount = requests.where((r) => r.status == 'accepted').length;

    // Real-time rating summary and certificates
    final farmerId = user?.id ?? '';
    final ratingSummary = ref.watch(farmerRatingSummaryProvider(farmerId));
    final certificatesAsync = ref.watch(farmerCertificatesProvider(farmerId));
    final certificates = certificatesAsync.value?.where((c) => c.status == 'active').toList() ?? [];
    final reviewsAsync = ref.watch(farmerReviewsProvider(farmerId));
    final reviews = reviewsAsync.value ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(
            context,
            user?.name ?? 'Farmer',
            user?.district ?? 'Unknown',
            user?.status ?? 'pending',
            ratingSummary.averageRating,
            ratingSummary.totalReviews,
          ),
          _buildStatsRow(activeListings, totalRequests, soldCount, ratingSummary.averageRating),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Official Certificates Section ──
                if (certificates.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('🏆', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Text(
                              'Official Certificates',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFD54F)),
                          ),
                          child: Text(
                            '${certificates.length} Issued',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: certificates.length,
                      itemBuilder: (context, index) {
                        final cert = certificates[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => CertificateViewerDialog(certificate: cert),
                            );
                          },
                          child: Container(
                            width: 240,
                            margin: const EdgeInsets.only(right: 12, top: 4, bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCFBF7),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('🎖️', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        cert.title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E5E16),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  cert.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'By: ${cert.officerName}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const Text(
                                      'View ➔',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: Color(0xFFEEEEEE), height: 1),
                  ),
                ],

                _buildMenuItem(
                  icon: Icons.person,
                  iconColor: const Color(0xFF455A64),
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'Personal Info',
                  subtitle:
                      'User Name: ${(user?.name.isNotEmpty == true) ? user!.name : 'No Name'}\n'
                      'Phone Number: ${(user?.phone?.isNotEmpty == true) ? user!.phone : 'No Phone'}\n'
                      'NIC Number: ${(user?.nic?.isNotEmpty == true) ? user!.nic : 'No NIC'}',
                ),
                _buildMenuItem(
                  icon: Icons.location_on,
                  iconColor: Colors.black87,
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'Farm Location',
                  subtitle: '${user?.district ?? 'Unknown'} District',
                ),
                _buildMenuItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFB300),
                  iconBg: const Color(0xFFFFF8E1),
                  title: 'Rating & Reviews',
                  subtitle: ratingSummary.totalReviews > 0
                      ? '⭐ ${ratingSummary.averageRating.toStringAsFixed(1)} / 5.0 (${ratingSummary.totalReviews} buyer reviews)'
                      : 'No buyer reviews yet (Default 5.0)',
                  onTap: () {
                    _showReviewsBottomSheet(context, reviews, ratingSummary);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.inventory_2,
                  iconColor: const Color(0xFF795548),
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'My Products',
                  subtitle: '$activeListings active listings',
                ),
                _buildMenuItem(
                  icon: Icons.analytics_outlined,
                  iconColor: const Color(0xFF2E7D32),
                  iconBg: const Color(0xFFE8F5E9),
                  title: 'SL Market Price Portal',
                  subtitle: 'Daily wholesale & retail crop market prices',
                  onTap: () {
                    UrlHelper.launchSlMarket(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications,
                  iconColor: const Color(0xFFF57F17),
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'Notifications',
                  subtitle: 'Manage alerts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AppNotificationsPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.lock,
                  iconColor: const Color(0xFF7CB342),
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'Change Password',
                  subtitle: 'Security settings',
                  onTap: () async {
                    if (user?.email != null) {
                      try {
                        await ref.read(authControllerProvider.notifier).resetPassword(user!.email);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset email sent to your email!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  iconColor: const Color(0xFFD32F2F),
                  iconBg: const Color(0xFFFFEBEE),
                  title: 'Logout',
                  titleColor: const Color(0xFFD32F2F),
                  isLast: true,
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String name,
    String district,
    String status,
    double rating,
    int reviewsCount,
  ) {
    return Container(
      color: _green,
      padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Farmer Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.editProfile);
                },
                child: const Row(
                  children: [
                    Icon(Icons.edit, color: Colors.yellow, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFC5E1A5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text('🧑‍🌾', style: TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Farmer · $district District',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(
                              color: status == 'approved'
                                  ? const Color(0xFF8BC34A)
                                  : Colors.orangeAccent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                status == 'approved' ? Icons.check : Icons.hourglass_empty,
                                color: status == 'approved'
                                    ? const Color(0xFF8BC34A)
                                    : Colors.orangeAccent,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                status == 'approved' ? 'Verified' : 'Pending',
                                style: TextStyle(
                                  color: status == 'approved'
                                      ? const Color(0xFF8BC34A)
                                      : Colors.orangeAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFD54F)),
                              const SizedBox(width: 3),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int products, int requests, int sold, double rating) {
    return Container(
      color: _darkGreen,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('$products', 'Listings'),
          _buildDivider(),
          _buildStatItem('$requests', 'Requests'),
          _buildDivider(),
          _buildStatItem('$sold', 'Sold'),
          _buildDivider(),
          _buildStatItem('⭐ ${rating.toStringAsFixed(1)}', 'Rating'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    String? subtitle,
    Color titleColor = Colors.black87,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                )
              : null,
          trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          onTap: onTap ?? () {},
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
            ),
          ),
      ],
    );
  }

  void _showReviewsBottomSheet(
    BuildContext context,
    List<dynamic> reviews,
    RatingSummary summary,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Buyer Ratings & Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '⭐ ${summary.averageRating.toStringAsFixed(1)} / 5.0',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (reviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Text(
                          'No customer reviews yet.\nReviews will appear here as buyers rate your products.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...reviews.map((r) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  r.buyerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < r.rating.round()
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: 16,
                                      color: const Color(0xFFFFB300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (r.qualityFeedback.isNotEmpty)
                              Text(
                                '• ${r.qualityFeedback}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              r.comment,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, yyyy').format(r.createdAt),
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
