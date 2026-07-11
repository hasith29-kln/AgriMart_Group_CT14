import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting
            const Text(
              'Hello, Farmer Kumarasinghe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Colombo District — Agricultural Zone 3',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Stat Cards Row
            Row(
              children: [
                Expanded(child: _buildStatCard('5', 'Product')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('3', 'Request')),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('2', 'Sold')),
              ],
            ),
            const SizedBox(height: 20),

            // Add New Product Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Add New Product',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF387015),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // My Recent Products Section
            const Text(
              'My Recent Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildProductCard(
              title: 'Organic Spinach',
              subtitle: '50 kg · Vegetables',
              price: 'Rs. 120/kg',
              statusText: 'Active',
              statusColor: const Color(0xFFE8F5E9),
              statusTextColor: const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 12),
            _buildProductCard(
              title: 'Tomatoes',
              subtitle: '80 kg · Vegetables',
              price: 'Rs. 95/kg',
              statusText: 'Pending',
              statusColor: const Color(0xFFFFF3E0),
              statusTextColor: const Color(0xFFE65100),
            ),
            const SizedBox(height: 24),

            // New Buyer Requests Section
            const Text(
              'New Buyer Requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildRequestCard(
              title: 'Request for Tomatoes',
              subtitle: 'Buyer: Sandeepa K.H · 30 kg',
              statusText: 'New',
              statusColor: const Color(0xFFE3F2FD),
              statusTextColor: const Color(0xFF1565C0),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF387015),
      elevation: 0,
      title: Row(
        children: [
          // Using an emoji as the agrimart logo in the appbar
          const Text('🌾', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          const Text(
            'AgriMart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Text('🔔', style: TextStyle(fontSize: 20)),
            ),
            Positioned(
              right: 8,
              top: 3,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Text('👤', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5E1), // Light green background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC5E1A5), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E5E16),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF387015),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String subtitle,
    required String price,
    required String statusText,
    required Color statusColor,
    required Color statusTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF5E1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32), // Green price text
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard({
    required String title,
    required String subtitle,
    required String statusText,
    required Color statusColor,
    required Color statusTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, '🏠', 'Home', isActive: true),
              _buildNavItem(1, '📦', 'Product'),
              _buildNavItem(2, '➕', 'add', isCenterIcon: true),
              _buildNavItem(3, '📋', 'Orders'),
              _buildNavItem(4, '👤', 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String emoji,
    String label, {
    bool isActive = false,
    bool isCenterIcon = false,
  }) {
    final color = isActive ? const Color(0xFF387015) : Colors.grey.shade500;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: isCenterIcon ? 28 : 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
