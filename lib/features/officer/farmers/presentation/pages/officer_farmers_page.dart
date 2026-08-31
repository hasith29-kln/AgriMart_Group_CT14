import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/models/user_model.dart';
import '../../../../../core/providers/review_provider.dart';
import '../../../../../core/providers/certificate_provider.dart';
import 'officer_register_farmer_page.dart';
import 'officer_farmer_details_page.dart';

class OfficerFarmersPage extends ConsumerStatefulWidget {
  const OfficerFarmersPage({super.key});

  @override
  ConsumerState<OfficerFarmersPage> createState() => _OfficerFarmersPageState();
}

class _OfficerFarmersPageState extends ConsumerState<OfficerFarmersPage> {
  String _searchQuery = '';
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final farmersAsync = ref.watch(farmersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Omit back button since it's a tab
        backgroundColor: const Color(0xFF8D5A36), // Brown background
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Manage Farmers',
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
                  builder: (context) => const OfficerRegisterFarmerPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: farmersAsync.when(
        data: (farmers) {
          int total = farmers.length;
          int approved = farmers.where((f) => f.status == 'approved').length;
          int pending = farmers.where((f) => f.status == 'pending').length;

          // Filtering
          List<UserModel> filteredFarmers = farmers.where((f) {
            bool matchesSearch = f.name.toLowerCase().contains(_searchQuery) ||
                (f.district ?? '').toLowerCase().contains(_searchQuery);

            bool matchesFilter = true;
            if (_selectedFilter == 'Approved') {
              matchesFilter = f.status == 'approved';
            } else if (_selectedFilter == 'Pending') {
              matchesFilter = f.status == 'pending';
            }
            return matchesSearch && matchesFilter;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      hintText: 'Search farmers...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', total),
                      const SizedBox(width: 8),
                      _buildFilterChip('Approved', approved),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', pending),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (filteredFarmers.isEmpty)
                  const Center(child: Text('No farmers found.'))
                else
                  ...filteredFarmers.map((f) {
                    if (f.status == 'pending') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildPendingFarmerCard(f),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildApprovedFarmerCard(f),
                      );
                    }
                  }),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
            color: isSelected ? Colors.orange.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.brown.shade800 : Colors.grey.shade500,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingFarmerCard(UserModel farmer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade500, width: 2),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFC5E1A5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🧑‍🌾', style: TextStyle(fontSize: 32)),
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
                            farmer.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${farmer.district ?? 'Unknown'} District\nRegistration',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('NIC:', farmer.nic ?? 'Not Provided'),
                      const SizedBox(height: 6),
                      _buildInfoRow('Phone:', farmer.phone ?? 'Not Provided'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('District:', farmer.district ?? 'Unknown'),
                      const SizedBox(height: 6),
                      _buildInfoRow('Applied:', 'Today'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(userControllerProvider.notifier).updateUserStatus(farmer.id, 'approved');
                  },
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: const Text(
                    'Approve',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showRejectDialog(context, ref, farmer);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFC62828),
                    size: 18,
                  ),
                  label: const Text(
                    'Reject',
                    style: TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC62828)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, UserModel farmer) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reject Registration?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This will deny ${farmer.name} access to AgriMart. They will be notified by the system.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFFCA28)), // Amber/Yellow outline
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFFFFB300), // Amber text
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(userControllerProvider.notifier).updateUserStatus(farmer.id, 'rejected');
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${farmer.name} has been rejected')),
                          );
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFFC62828),
                          size: 16,
                        ),
                        label: const Text(
                          'Confirm\nReject',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC62828)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedFarmerCard(UserModel farmer) {
    final ratingSummary = ref.watch(farmerRatingSummaryProvider(farmer.id));
    final certsAsync = ref.watch(farmerCertificatesProvider(farmer.id));
    final certs = certsAsync.value?.where((c) => c.status == 'active').toList() ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfficerFarmerDetailsPage(farmer: farmer),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFC5E1A5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🧑‍🌾', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        farmer.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (certs.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Text('🏆', style: TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        farmer.district ?? 'Unknown District',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
                      const SizedBox(width: 2),
                      Text(
                        '${ratingSummary.averageRating.toStringAsFixed(1)} (${ratingSummary.totalReviews})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Approved',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Details ➔',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8D5A36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
