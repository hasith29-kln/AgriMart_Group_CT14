import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color _green = Color(0xFF387015);
  static const Color _darkGreen = Color(0xFF24480E); // Darker shade for stats row

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildStatsRow(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.person,
                  iconColor: const Color(0xFF455A64),
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'Personal Info',
                  subtitle: 'Name, phone, NIC',
                ),
                _buildMenuItem(
                  icon: Icons.location_on,
                  iconColor: Colors.black87,
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'Farm Location',
                  subtitle: 'Colombo District, Zone 3',
                ),
                _buildMenuItem(
                  icon: Icons.inventory_2,
                  iconColor: const Color(0xFF795548),
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'My Products',
                  subtitle: '5 active listings',
                ),
                _buildMenuItem(
                  icon: Icons.notifications,
                  iconColor: const Color(0xFFF57F17),
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'Notifications',
                  subtitle: 'Manage alerts',
                ),
                _buildMenuItem(
                  icon: Icons.lock,
                  iconColor: const Color(0xFF7CB342),
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'Change Password',
                  subtitle: 'Security settings',
                ),
                _buildMenuItem(
                  icon: Icons.language,
                  iconColor: const Color(0xFF29B6F6),
                  iconBg: const Color(0xFFF1F8E9),
                  title: 'Language',
                  subtitle: 'English',
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  iconColor: const Color(0xFFD32F2F),
                  iconBg: const Color(0xFFFFEBEE),
                  title: 'Logout',
                  titleColor: const Color(0xFFD32F2F),
                  isLast: true,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {},
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
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFC5E1A5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text('🧑‍🌾', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kumarasinghe\nK.M.B.S.S',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Farmer · Colombo District',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: const Color(0xFF8BC34A),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Color(0xFF8BC34A), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Verified Farmer',
                            style: TextStyle(
                              color: Color(0xFF8BC34A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildStatsRow() {
    return Container(
      color: _darkGreen,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('5', 'Product'),
          _buildDivider(),
          _buildStatItem('3', 'Orders'),
          _buildDivider(),
          _buildStatItem('2', 'Sold'),
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withValues(alpha: 0.3),
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
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                )
              : null,
          onTap: () {},
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
}
