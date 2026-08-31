import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/product_provider.dart';
import '../../../../../core/models/product_model.dart';
import 'package:intl/intl.dart';
import 'officer_add_product_page.dart';
import 'officer_product_approvals_page.dart';

class OfficerProductsPage extends ConsumerStatefulWidget {
  const OfficerProductsPage({super.key});

  @override
  ConsumerState<OfficerProductsPage> createState() =>
      _OfficerProductsPageState();
}

class _OfficerProductsPageState extends ConsumerState<OfficerProductsPage> {
  String _searchQuery = '';
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF8D5A36), // Brown
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Manage Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Color.fromARGB(255, 246, 248, 246),
              size: 20,
            ),
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            padding: const EdgeInsets.all(4),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OfficerAddProductPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          int total = products.length;
          int active = products.where((p) => p.status == 'active').length;
          int flagged = products.where((p) => p.status == 'flagged').length;
          int pending = products.where((p) => p.status == 'pending').length;

          List<ProductModel> filteredProducts = products.where((p) {
            bool matchesSearch =
                p.name.toLowerCase().contains(_searchQuery) ||
                p.farmerName.toLowerCase().contains(_searchQuery) ||
                p.location.toLowerCase().contains(_searchQuery);

            bool matchesFilter = true;
            if (_selectedFilter == 'Active') {
              matchesFilter = p.status == 'active';
            } else if (_selectedFilter == 'Flagged') {
              matchesFilter = p.status == 'flagged';
            } else if (_selectedFilter == 'Pending') {
              matchesFilter = p.status == 'pending';
            }
            return matchesSearch && matchesFilter;
          }).toList();

          // Sort so pending ones are on top
          filteredProducts.sort((a, b) {
            if (a.status == 'pending' && b.status != 'pending') return -1;
            if (a.status != 'pending' && b.status == 'pending') return 1;
            return b.createdAt.compareTo(a.createdAt);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '$total',
                        'Total',
                        bgColor: const Color(0xFFFFF3E0),
                        borderColor: const Color(0xFFFFCC80),
                        textColor: const Color(0xFF795548),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        '$active',
                        'Active',
                        bgColor: const Color(0xFFE8F5E9),
                        borderColor: const Color(0xFFA5D6A7),
                        textColor: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        '$flagged',
                        'Flagged',
                        bgColor: const Color(0xFFFFEBEE),
                        borderColor: const Color(0xFFEF9A9A),
                        textColor: const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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
                      hintText: 'Search products...',
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
                      _buildFilterChip('All', total),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active', active),
                      const SizedBox(width: 8),
                      _buildFilterChip('Flagged', flagged),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (filteredProducts.isEmpty)
                  const Center(child: Text('No products found.'))
                else ...[
                  if (filteredProducts.any(
                    (p) => p.status == 'pending' || p.status == 'flagged',
                  )) ...[
                    const Text(
                      'Farmer submitted',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...filteredProducts
                        .where(
                          (p) => p.status == 'pending' || p.status == 'flagged',
                        )
                        .map((p) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildPendingProductCard(p),
                          );
                        })
                        .toList(),
                    const SizedBox(height: 12),
                  ],
                  if (filteredProducts.any((p) => p.status == 'active')) ...[
                    const Text(
                      'Active Products',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...filteredProducts.where((p) => p.status == 'active').map((
                      p,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildActiveProductCard(p),
                      );
                    }).toList(),
                  ],
                ],
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

  Widget _buildStatCard(
    String value,
    String label, {
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor.withValues(alpha: 0.8),
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
            color: isSelected ? Colors.orange.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '$label($count)',
          style: TextStyle(
            color: isSelected ? const Color(0xFF795548) : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingProductCard(ProductModel product) {
    bool isFlagged = product.status == 'flagged';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFlagged ? Colors.red.shade300 : Colors.orange.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFC5E1A5),
                  shape: BoxShape.circle,
                  image:
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
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
                            product.name,
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
                            color: isFlagged
                                ? Colors.red.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isFlagged ? 'Flagged' : 'Pending',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isFlagged
                                  ? Colors.red.shade800
                                  : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "🧑‍🌾 ${product.farmerName} · ${product.quantity}${product.unit} · Rs.${product.price}/${product.unit}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "📍 ${product.location} · ${DateFormat('MMM d, h:mm a').format(product.createdAt)}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // View uploaded photo button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                // View photo logic
              },
              icon: const Icon(Icons.image, color: Colors.black87, size: 18),
              label: const Text(
                'View uploaded photo',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final updated = product.copyWith(status: 'active');
                    ref
                        .read(productControllerProvider.notifier)
                        .updateProduct(updated);
                  },
                  icon: const Icon(Icons.check, color: Colors.white, size: 16),
                  label: const Text(
                    'Approve',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const OfficerProductApprovalsPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Color(0xFFC62828),
                    size: 16,
                  ),
                  label: const Text(
                    'Review',
                    style: TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC62828)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(productControllerProvider.notifier)
                        .deleteProduct(product.id);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFC62828),
                    size: 16,
                  ),
                  label: const Text(
                    'Reject',
                    style: TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC62828)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProductCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4EF),
              borderRadius: BorderRadius.circular(12),
              image: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(product.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.imageUrl == null || product.imageUrl!.isEmpty
                ? const Icon(Icons.image, color: Colors.grey, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.quantity}${product.unit} · ${product.farmerName}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${product.price}/${product.unit}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  final updated = product.copyWith(status: 'flagged');
                  ref
                      .read(productControllerProvider.notifier)
                      .updateProduct(updated);
                },
                child: const Text(
                  'Flag',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
