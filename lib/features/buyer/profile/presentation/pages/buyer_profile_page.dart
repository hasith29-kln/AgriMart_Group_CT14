import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agri_mart/core/providers/auth_provider.dart';
import 'package:agri_mart/core/models/user_model.dart';
import 'package:agri_mart/core/providers/request_provider.dart';
import '../../../../comman/notifications/presentation/pages/app_notifications_page.dart';

class BuyerProfilePage extends ConsumerWidget {
  const BuyerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserProvider);
    final requestsList = ref.watch(buyerRequestsProvider).value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('User not found. Please log in again.'),
            );
          }
          final int totalOrders = requestsList.length;
          final int acceptedOrders = requestsList
              .where((req) => req.status == 'accepted')
              .length;
          final int savedProductsCount = user.savedProducts.length;

          return _buildProfileContent(
            context,
            ref,
            user,
            totalOrders,
            acceptedOrders,
            savedProductsCount,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading profile: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    int totalOrders,
    int acceptedOrders,
    int savedProductsCount,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top Header Section (Blue Background)
          Container(
            color: const Color(0xFF1976D2), // Standard Blue
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/buyerEditProfile');
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.orangeAccent,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // User Info Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF90CAF9), // Light blue background
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black54,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Buyer - ${user.district ?? 'Unknown District'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Badge Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              '$totalOrders Orders placed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Stats Row (Dark Blue Background)
          Container(
            color: const Color(0xFF153448), // Dark Blue Navy
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('$totalOrders', 'Orders'),
                _buildDivider(),
                _buildStatItem('$acceptedOrders', 'Accepted'),
                _buildDivider(),
                _buildStatItem('$savedProductsCount', 'Saved'),
              ],
            ),
          ),

          // Menu List
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Personal Info',
                  subtitle:
                      '${user.email} ${user.phone != null ? '• ${user.phone}' : ''}',
                  onTap: () {
                    Navigator.pushNamed(context, '/buyerEditProfile');
                  },
                ),
                _buildListDivider(),

                _buildMenuItem(
                  icon: Icons.assignment_outlined,
                  title: 'My Orders',
                  subtitle: '$totalOrders orders placed',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('My Orders feature coming soon!'),
                      ),
                    );
                  },
                ),
                _buildListDivider(),
                _buildMenuItem(
                  icon: Icons.favorite_border,
                  title: 'Saved Products',
                  subtitle: '$savedProductsCount saved items',
                  onTap: () {
                    Navigator.pushNamed(context, '/savedProducts');
                  },
                ),
                _buildListDivider(),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Delivery Address',
                  subtitle: user.district ?? 'Not specified',
                  onTap: () {
                    Navigator.pushNamed(context, '/buyerEditProfile');
                  },
                ),
                _buildListDivider(),
                _buildMenuItem(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  subtitle: 'Manage alerts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppNotificationsPage(),
                      ),
                    );
                  },
                ),
                _buildListDivider(),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Security settings',
                  onTap: () async {
                    if (user.email != null) {
                      try {
                        await ref
                            .read(authControllerProvider.notifier)
                            .resetPassword(user.email!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password reset email sent to your email!',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    }
                  },
                ),
                _buildListDivider(),
                _buildMenuItem(
                  icon: Icons.exit_to_app,
                  title: 'Logout',
                  subtitle: '',
                  iconColor: Colors.red,
                  bgColor: Colors.red.withValues(alpha: 0.1),
                  titleColor: Colors.red,
                  isLogout: true,
                  onTap: () async {
                    try {
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error logging out: $e')),
                        );
                      }
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

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildListDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 20),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    Color? bgColor,
    Color? titleColor,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    final effectiveIconColor = iconColor ?? Colors.blue.shade700;
    final effectiveBgColor = bgColor ?? Colors.blue.shade50;
    final effectiveTitleColor = titleColor ?? Colors.black87;

    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: effectiveBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: effectiveTitleColor,
                    ),
                  ),
                  if (!isLogout) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
