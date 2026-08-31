import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/providers/product_provider.dart';

class OfficerZoneManagementPage extends ConsumerStatefulWidget {
  const OfficerZoneManagementPage({super.key});

  @override
  ConsumerState<OfficerZoneManagementPage> createState() =>
      _OfficerZoneManagementPageState();
}

class _OfficerZoneManagementPageState
    extends ConsumerState<OfficerZoneManagementPage> {
  final Color primaryBrown = const Color(0xFF8D5A36);
  String? _selectedZoneName;

  @override
  Widget build(BuildContext context) {
    final farmersAsync = ref.watch(farmersProvider);
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: primaryBrown,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Zone Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Managed Zones overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View statistics and details for each agricultural zone.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            farmersAsync.when(
              data: (farmers) {
                return productsAsync.when(
                  data: (products) {
                    if (farmers.isEmpty && products.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Text('📭', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 16),
                              Text(
                                'No Data',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        _buildZoneCard(
                          'Zone 1',
                          'North Zone',
                          farmers,
                          products,
                          '0xFFE8F5E9',
                          '0xFF2E7D32',
                        ),
                        const SizedBox(height: 16),
                        _buildZoneCard(
                          'Zone 2',
                          'South Zone',
                          farmers,
                          products,
                          '0xFFFFF3E0',
                          '0xFFE65100',
                        ),
                        const SizedBox(height: 16),
                        _buildZoneCard(
                          'Zone 3',
                          'East Zone',
                          farmers,
                          products,
                          '0xFFFFEBEE',
                          '0xFFC62828',
                        ),
                        const SizedBox(height: 16),
                        _buildZoneCard(
                          'Zone 4',
                          'West Zone',
                          farmers,
                          products,
                          '0xFFE3F2FD',
                          '0xFF1565C0',
                        ),
                        const SizedBox(height: 16),
                        _buildZoneCard(
                          'Zone 5',
                          'Outskirts/Zone 5',
                          farmers,
                          products,
                          '0xFFF3E5F5',
                          '0xFF6A1B9A',
                        ),
                        const SizedBox(height: 16),
                        _buildZoneCard(
                          'Unassigned',
                          'Public Signups / Pending Assignment',
                          farmers,
                          products,
                          '0xFFECEFF1',
                          '0xFF37474F',
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading products: $err'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading farmers: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard(
    String zoneName,
    String region,
    List<dynamic> allFarmers,
    List<dynamic> allProducts,
    String bgHex,
    String textHex,
  ) {
    final bool isSelected = _selectedZoneName == zoneName;

    // Real calculation: filter farmers by zone field
    final farmersInZone = allFarmers.where((f) {
      if (zoneName == 'Unassigned') {
        return f.zone == null || f.zone.isEmpty;
      }
      return f.zone == zoneName;
    }).toList();
    final int farmerCount = farmersInZone.length;

    // Create a set of farmer IDs in this zone to filter products
    final farmerIdsInZone = farmersInZone.map((f) => f.id).toSet();
    final int productCount = allProducts
        .where((p) => farmerIdsInZone.contains(p.farmerId))
        .length;

    final bgColor = Color(int.parse(bgHex));
    final textColor = Color(int.parse(textHex));

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedZoneName = zoneName;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBrown : Colors.grey.shade200,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryBrown.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zoneName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      region,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildZoneStat(
                    '🧑‍🌾 Farmers',
                    '$farmerCount registered',
                  ),
                ),
                Expanded(
                  child: _buildZoneStat('📦 Products', '$productCount listed'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }
}
