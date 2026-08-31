import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agri_mart/core/providers/product_provider.dart';
import 'package:agri_mart/core/models/product_model.dart';

class BuyerHomeContent extends ConsumerStatefulWidget {
  const BuyerHomeContent({super.key});

  @override
  ConsumerState<BuyerHomeContent> createState() => _BuyerHomeContentState();
}

class _BuyerHomeContentState extends ConsumerState<BuyerHomeContent> {
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    '🍅 Fruits',
    '🥦 Vegetables',
    '🌾 Grains',
    '🌿 Herbs',
  ];

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(allProductsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Find Fresh Produce',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search products, farmers...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: _buildCategoryChip(
                      category,
                      isSelected: _selectedCategory == category,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Nearby Farmers Section
          DottedBorder(
            options: RoundedRectDottedBorderOptions(
              color: Colors.green.shade300,
              strokeWidth: 1.5,
              dashPattern: const [6, 4],
              radius: const Radius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4EF), // Light green tint
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('🗺️', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    'Nearby Farmers — Colombo District',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Featured Products Title
          const Text(
            'Featured Products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Products List
          productsAsyncValue.when(
            data: (products) {
              // Filter products
              var filteredProducts = products.where((product) {
                final matchesSearch =
                    product.name.toLowerCase().contains(_searchQuery) ||
                    product.farmerName.toLowerCase().contains(_searchQuery);

                final matchesCategory =
                    _selectedCategory == 'ALL' ||
                    product.category.toLowerCase() ==
                        _selectedCategory
                            .replaceAll(RegExp(r'[^\w\s]'), '')
                            .trim()
                            .toLowerCase();

                // Only show active/available products in marketplace
                final isActive = product.status != 'flagged';

                return matchesSearch && matchesCategory && isActive;
              }).toList();

              if (filteredProducts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text('No products found matching your criteria.'),
                  ),
                );
              }

              return Column(
                children: filteredProducts.map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildProductCard(
                      context: context,
                      product: product,
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error loading products: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required ProductModel product,
  }) {
    final bool isAvailable = product.quantity > 0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/buyerProductDetails',
          arguments: product,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4EF),
                borderRadius: BorderRadius.circular(8),
                image: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.imageUrl == null || product.imageUrl!.isEmpty
                  ? const Icon(Icons.image, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Low Stock',
                          style: TextStyle(
                            color: isAvailable
                                ? Colors.green.shade700
                                : Colors.orange.shade800,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('🧑‍🌾', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        product.farmerName.isEmpty
                            ? 'Farmer'
                            : product.farmerName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.location.isEmpty ? 'Unknown' : product.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rs. ${product.price}/${product.unit}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
