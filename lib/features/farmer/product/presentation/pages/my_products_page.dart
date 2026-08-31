import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/models/product_model.dart';
import '../../../../../core/providers/product_provider.dart';

enum NoteType { pending, officer }

class MyProductsPage extends ConsumerStatefulWidget {
  const MyProductsPage({super.key});

  @override
  ConsumerState<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends ConsumerState<MyProductsPage> {
  static const Color _green = Color(0xFF387015);
  static const Color _bg = Color(0xFFFAFAFA);

  int _filterIndex = 0; // 0=All, 1=Active, 2=Pending, 3=Sold

  final List<String> _filterLabels = ['ALL', 'Active', 'Pending', 'Sold'];

  List<ProductModel> _getFilteredProducts(List<ProductModel> allProducts) {
    switch (_filterIndex) {
      case 1:
        return allProducts.where((p) => p.status == 'active').toList();
      case 2:
        return allProducts.where((p) => p.status == 'pending').toList();
      case 3:
        return allProducts.where((p) => p.status == 'sold').toList();
      default:
        return allProducts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(farmerProductsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: productsAsync.when(
        data: (allProducts) {
          final filtered = _getFilteredProducts(allProducts);
          final activeCount = allProducts
              .where((p) => p.status == 'active')
              .length;
          final pendingCount = allProducts
              .where((p) => p.status == 'pending')
              .length;
          final soldCount = allProducts.where((p) => p.status == 'sold').length;

          return Column(
            children: [
              _buildFilterTabs(
                allProducts.length,
                activeCount,
                pendingCount,
                soldCount,
              ),
              _buildStatsRow(
                allProducts.length,
                activeCount,
                pendingCount,
                soldCount,
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _buildProductCard(filtered[i]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _green,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: const Text(
        'My Products',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4EF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.black, size: 20),
                onPressed: () => Navigator.of(context).pushNamed('/addProduct'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(int total, int active, int pending, int sold) {
    List<String> labels = [
      'ALL ($total)',
      'Active ($active)',
      'Pending ($pending)',
      'Sold ($sold)',
    ];

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(labels.length, (i) {
            final isActiveTab = i == _filterIndex;
            return GestureDetector(
              onTap: () => setState(() => _filterIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActiveTab
                      ? const Color(0xFFE8F5E9)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActiveTab ? _green : Colors.grey.shade300,

                    width: isActiveTab ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActiveTab
                        ? FontWeight.w700
                        : FontWeight.normal,
                    color: isActiveTab ? _green : Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatsRow(int total, int active, int pending, int sold) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          _buildStatCard(
            '$active',
            'Active',
            const Color(0xFFF1F8E9),
            _green,
            const Color(0xFFC5E1A5),
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            '$total',
            'Total',
            const Color(0xFFF1F8E9),
            _green,
            const Color(0xFFC5E1A5),
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            '$pending',
            'Pending',
            const Color(0xFFFFF8E1),
            const Color(0xFFF57F17),
            const Color(0xFFFFCC80),
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            '$sold',
            'Sold',
            const Color(0xFFEEEEEE),
            Colors.grey.shade700,
            const Color(0xFFD6D6D6),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String count,
    String label,
    Color bg,
    Color textColor,
    Color borderColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final isSold = product.status == 'sold';
    final isPending = product.status == 'pending';
    final borderColor = isPending
        ? const Color(0xFFFFCC80)
        : Colors.transparent;

    // Fallback details if not fully provided
    final detailsStr =
        '${product.quantity} ${product.unit} · ${product.category} · ${product.location}';
    final priceStr = product.price > 0
        ? 'Rs. ${product.price}/${product.unit}'
        : '';

    // Note logic based on status
    String? note;
    NoteType? noteType;
    if (product.status == 'pending') {
      note = 'Awaiting officer approval';
      noteType = NoteType.pending;
    } else if (product.status == 'flagged') {
      note = 'Flagged by Officer';
      noteType = NoteType.officer;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isPending ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEDC8),
                  borderRadius: BorderRadius.circular(8),
                  image:
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.imageUrl == null || product.imageUrl!.isEmpty
                    ? const Center(
                        child: Icon(Icons.image, color: Colors.white, size: 28),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSold ? Colors.grey.shade400 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detailsStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (note != null && noteType != null)
                                _buildNoteBanner(note, noteType),
                              if (priceStr.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: note != null ? 4.0 : 0.0,
                                  ),
                                  child: Text(
                                    priceStr,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSold
                                          ? Colors.grey.shade400
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (note != null || priceStr.isNotEmpty)
                          const SizedBox(width: 8),
                        _buildStatusBadge(product.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Action buttons
                    Row(
                      children: [
                        _buildActionButton(
                          label: '✏️ Edit',
                          onTap: isSold ? null : () => _onEdit(product),
                          isEdit: true,
                          disabled: isSold,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          label: '🗑️ Delete',
                          onTap: isSold ? null : () => _onDelete(product),
                          isEdit: false,
                          disabled: isSold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'active':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Active',
            style: TextStyle(
              fontSize: 10,
              color: _green,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case 'pending':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Pending',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFF9A825),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }

  Widget _buildNoteBanner(String note, NoteType type) {
    final bg = type == NoteType.pending
        ? const Color(0xFFFFF8E1)
        : const Color(0xFFE3F2FD);
    final textColor = type == NoteType.pending
        ? const Color(0xFFF9A825)
        : const Color(0xFF1565C0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        note,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onTap,
    required bool isEdit,
    required bool disabled,
  }) {
    final borderColor = disabled
        ? Colors.grey.shade200
        : isEdit
        ? const Color(0xFF8BC34A)
        : const Color(0xFFEF9A9A);
    final textColor = disabled
        ? Colors.grey.shade400
        : isEdit
        ? _green
        : const Color(0xFFE53935);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _onEdit(ProductModel product) {
    Navigator.pushNamed(context, '/addProduct', arguments: product);
  }

  void _onDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Listing?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permanently remove "${product.name}" from AgriMart?',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buyers will no longer see this product.',
              style: TextStyle(color: Color(0xFFB71C1C), fontSize: 14),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFFFCA28),
                    ), // Amber/Yellow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFFFFCA28),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref
                        .read(productControllerProvider.notifier)
                        .deleteProduct(product.id);
                  },
                  icon: const Text('🗑️', style: TextStyle(fontSize: 16)),
                  label: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Color(0xFFB71C1C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFB71C1C)), // Red
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
