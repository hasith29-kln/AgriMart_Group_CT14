import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/providers/request_provider.dart';
import '../../../../../core/models/user_model.dart';
import 'package:intl/intl.dart';
import 'officer_register_buyer_page.dart';

class OfficerBuyersPage extends ConsumerStatefulWidget {
  const OfficerBuyersPage({super.key});

  @override
  ConsumerState<OfficerBuyersPage> createState() => _OfficerBuyersPageState();
}

class _OfficerBuyersPageState extends ConsumerState<OfficerBuyersPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final buyersAsync = ref.watch(buyersProvider);

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F4F4,
      ), // Slightly darker grey to match screenshot
      appBar: AppBar(
        automaticallyImplyLeading: false, // Omit back button since it's a tab
        backgroundColor: const Color(0xFF8D5A36), // Brown background
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Manage Buyers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OfficerRegisterBuyerPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: buyersAsync.when(
          data: (buyers) {
            int total = buyers.length;
            int activeCount = buyers
                .where((b) => b.status == 'approved')
                .length;
            int suspendedCount = buyers
                .where((b) => b.status == 'suspended')
                .length;

            List<UserModel> filteredBuyers = buyers.where((b) {
              bool matchesSearch =
                  b.name.toLowerCase().contains(_searchQuery) ||
                  (b.district ?? '').toLowerCase().contains(_searchQuery);

              bool matchesFilter = true;
              if (_selectedFilter == 'Active') {
                matchesFilter = b.status == 'approved';
              } else if (_selectedFilter == 'Suspended') {
                matchesFilter = b.status == 'suspended';
              }
              return matchesSearch && matchesFilter;
            }).toList();

            UserModel? topBuyer;
            List<UserModel> otherBuyers = [];

            if (filteredBuyers.isNotEmpty) {
              if (_searchQuery.isEmpty && _selectedFilter == 'All') {
                // Mockup logic: first active buyer is marked as Top Buyer for the UI only on 'All' view
                int topIndex = filteredBuyers.indexWhere(
                  (b) => b.status == 'approved',
                );
                if (topIndex != -1) {
                  topBuyer = filteredBuyers[topIndex];
                  otherBuyers = List.from(filteredBuyers)..removeAt(topIndex);
                } else {
                  otherBuyers = filteredBuyers;
                }
              } else {
                otherBuyers = filteredBuyers;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agricultural Officer — Zone 3 Overview',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          total.toString(),
                          'Total',
                          const Color(0xFFEBF4FE),
                          const Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          activeCount.toString(),
                          'Active',
                          const Color(0xFFF0F7ED),
                          const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          suspendedCount.toString(),
                          'Suspended',
                          const Color(0xFFFDF0ED),
                          const Color(
                            0xFF8D6E63,
                          ), // Brownish text like in screenshot
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search buyers...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', total),
                        const SizedBox(width: 8),
                        _buildFilterChip('Active', activeCount),
                        const SizedBox(width: 8),
                        _buildFilterChip('Suspended', suspendedCount),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Top Buyers Section
                  if (topBuyer != null) ...[
                    const Text(
                      'Top Buyers',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBuyerCard(
                      context,
                      ref,
                      topBuyer,
                      isTopBuyer: true,
                      isSuspended: false,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // All Buyers Section
                  if (_searchQuery.isEmpty && _selectedFilter == 'All') ...[
                    const Text(
                      'All Buyers',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (otherBuyers.isEmpty && topBuyer == null)
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'No buyers found.',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  else
                    ...otherBuyers.map((b) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildBuyerCard(
                          context,
                          ref,
                          b,
                          isTopBuyer: false,
                          isSuspended: b.status == 'suspended',
                        ),
                      );
                    }),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String count,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withValues(alpha: 0.8), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.orange.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.brown.shade800 : Colors.grey.shade500,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildBuyerCard(
    BuildContext context,
    WidgetRef ref,
    UserModel buyer, {
    required bool isTopBuyer,
    required bool isSuspended,
  }) {
    return GestureDetector(
      onTap: () {
        _showBuyerDetailsDialog(context, ref, buyer);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black54,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    buyer.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${buyer.district ?? 'Unknown'} · ${isTopBuyer ? '6' : '0'} orders placed',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSuspended
                    ? Colors.red.shade50
                    : (isTopBuyer ? Colors.blue.shade50 : Colors.green.shade50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isSuspended
                    ? 'Suspended'
                    : (isTopBuyer ? 'Top Buyer' : 'Active'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSuspended
                      ? Colors.red.shade700
                      : (isTopBuyer
                            ? Colors.blue.shade700
                            : Colors.green.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBuyerDetailsDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel buyer,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.black54,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buyer.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${buyer.district ?? 'Unknown'} District · Registered ${_getTimeAgo(buyer.createdAt)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: buyer.status == 'suspended'
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        buyer.status == 'suspended' ? 'Suspended' : 'Active',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: buyer.status == 'suspended'
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Grid details
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<dynamic>>(
                        stream: ref
                            .read(requestRepositoryProvider)
                            .getRequestsByBuyer(buyer.id),
                        builder: (context, snapshot) {
                          final count = snapshot.hasData
                              ? snapshot.data!.length.toString()
                              : '...';
                          return _buildDetailBox('Total orders', count);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailBox(
                        'Joined',
                        DateFormat('MMM dd, yyyy').format(buyer.createdAt),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailBox(
                        'Phone',
                        buyer.phone ?? 'Not provided',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailBox(
                        'District',
                        buyer.district ?? 'Unknown',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final newStatus = buyer.status == 'suspended'
                              ? 'approved'
                              : 'suspended';
                          ref
                              .read(userControllerProvider.notifier)
                              .updateUserStatus(buyer.id, newStatus);
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Account ${newStatus == 'suspended' ? 'suspended' : 'activated'}',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFC62828),
                          ), // Red
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          buyer.status == 'suspended'
                              ? 'Activate Account'
                              : 'Suspend Account',
                          style: const TextStyle(
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('View Orders feature coming soon!'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF1565C0),
                          ), // Blue
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'View Orders',
                          style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 365)
      return '${(difference.inDays / 365).floor()} years ago';
    if (difference.inDays >= 30)
      return '${(difference.inDays / 30).floor()} months ago';
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} minutes ago';
    return 'Just now';
  }
}
