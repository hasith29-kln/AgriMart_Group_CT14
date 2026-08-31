import 'package:agri_mart/features/comman/notifications/presentation/pages/app_notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/providers/user_provider.dart';
import 'officer_edit_profile_page.dart';
import 'officer_zone_management_page.dart';
import 'officer_zone_reports_page.dart';
import 'officer_about_page.dart';
import '../../../../../core/utils/url_helper.dart';


class OfficerProfilePage extends ConsumerWidget {
  const OfficerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final farmersAsync = ref.watch(farmersProvider);
    final buyersAsync = ref.watch(buyersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              color: const Color(0xFF8D5A36), // Brown
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Custom AppBar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OfficerEditProfilePage(),
                                ),
                              );
                            },
                            child: Row(
                              children: const [
                                Text('✏️', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Profile Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade100,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text('👨‍💼', style: TextStyle(fontSize: 40)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.value?.name ?? 'Loading...',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.value?.department != null && user.value!.department!.isNotEmpty
                                      ? 'Agricultural Officer · ${user.value!.department}'
                                      : 'Agricultural Officer · Zone 3',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8D5A36),
                                    border: Border.all(color: Colors.white38),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    '⚙️ System Admin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Row
                    Container(
                      color: const Color(0xFF5D4037), // Darker brown
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: farmersAsync.when(
                              data: (farmers) => _buildStatItem(farmers.length.toString(), 'Farmers'),
                              loading: () => _buildStatItem('...', 'Farmers'),
                              error: (err, st) => _buildStatItem('0', 'Farmers'),
                            ),
                          ),
                          Container(width: 1, height: 30, color: Colors.white38),
                          Expanded(
                            child: buyersAsync.when(
                              data: (buyers) => _buildStatItem(buyers.length.toString(), 'Buyers'),
                              loading: () => _buildStatItem('...', 'Buyers'),
                              error: (err, st) => _buildStatItem('0', 'Buyers'),
                            ),
                          ),
                          Container(width: 1, height: 30, color: Colors.white38),
                          Expanded(child: _buildStatItem('3', 'Zone')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // List Items
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  _buildListTile(context, ref, '👤', 'Officer Info', 'Name, ID, department'),
                  _buildListTile(context, ref, '🗺️', 'Zone Management', 'Zone 3 · Colombo District'),
                  _buildListTile(context, ref, '📊', 'Zone Reports', 'Weekly summaries'),
                  _buildListTile(context, ref, '📈', 'SL Market Price Portal', 'National wholesale & retail prices'),
                  _buildListTile(context, ref, '🔔', 'Notifications', 'System alerts'),
                  _buildListTile(context, ref, '🔒', 'Change Password', 'Security settings'),
                  _buildListTile(context, ref, 'ℹ️', 'About AgriMart', 'App information'),
                  _buildListTile(context, ref, '🚪', 'Logout', '', isLogout: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, WidgetRef ref, String emoji, String title, String subtitle, {bool isLogout = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.red.shade50, // Lighter red to match screenshot
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red.shade800 : Colors.black87,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            )
          : null,
      onTap: () async {
        if (isLogout) {
          await ref.read(authControllerProvider.notifier).signOut();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        } else if (title == 'Officer Info') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OfficerEditProfilePage()),
          );
        } else if (title == 'Zone Management') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OfficerZoneManagementPage()),
          );
        } else if (title == 'Zone Reports') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OfficerZoneReportsPage()),
          );
        } else if (title == 'SL Market Price Portal') {
          UrlHelper.launchSlMarket(context);
        } else if (title == 'Change Password') {
          final currentUser = ref.read(currentUserProvider).value;
          if (currentUser != null && currentUser.email.isNotEmpty) {
            try {
              await ref.read(authControllerProvider.notifier).resetPassword(currentUser.email);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password reset email sent to ${currentUser.email}')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to send reset email: $e')),
                );
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email not found. Cannot reset password.')),
            );
          }
        } else if (title == 'Notifications') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppNotificationsPage()),
          );
        } else if (title == 'About AgriMart') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OfficerAboutPage()),
          );
        }
      },
    );
  }
}

