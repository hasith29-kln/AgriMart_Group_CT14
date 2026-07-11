import 'package:flutter/material.dart';

// ── Data model ──────────────────────────────────────────────────────────────

enum ProductStatus { active, pending, sold }

class ProductItem {
  final String name;
  final String details; // e.g. "50 kg · Vegetables · Colombo"
  final String price;
  final ProductStatus status;
  final String? note; // banner note below details
  final NoteType? noteType;

  const ProductItem({
    required this.name,
    required this.details,
    required this.price,
    required this.status,
    this.note,
    this.noteType,
  });
}

enum NoteType { pending, officer }

// ── Page ────────────────────────────────────────────────────────────────────

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  // ── Constants ──────────────────────────────────────────────────────────────
  static const Color _green = Color(0xFF387015);
  static const Color _bg = Color(0xFFF5F5F5);

  // ── State ──────────────────────────────────────────────────────────────────
  int _filterIndex = 0; // 0=All, 1=Active, 2=Pending, 3=Sold
  int _navIndex = 1; // "Product" tab active

  final List<String> _filterLabels = ['ALL (5)', 'Active(3)', 'Pending (1)', 'Sold (1)'];

  final List<ProductItem> _allProducts = const [
    ProductItem(
      name: 'Organic Spinach',
      details: '50 kg · Vegetables · Colombo',
      price: 'Rs. 120/kg',
      status: ProductStatus.active,
    ),
    ProductItem(
      name: 'Tomatoes',
      details: '80 kg · Vegetables · Gampaha',
      price: '',
      status: ProductStatus.pending,
      note: 'Awaiting officer approval',
      noteType: NoteType.pending,
    ),
    ProductItem(
      name: 'Carrots',
      details: '40 kg · Vegetables · Kandy',
      price: '',
      status: ProductStatus.active,
      note: '🌾 Added by Agricultural Officer',
      noteType: NoteType.officer,
    ),
    ProductItem(
      name: 'Bananas',
      details: '60 kg · Fruits · Matara',
      price: 'Rs. 60 / kg',
      status: ProductStatus.sold,
    ),
  ];

  List<ProductItem> get _filtered {
    switch (_filterIndex) {
      case 1:
        return _allProducts.where((p) => p.status == ProductStatus.active).toList();
      case 2:
        return _allProducts.where((p) => p.status == ProductStatus.pending).toList();
      case 3:
        return _allProducts.where((p) => p.status == ProductStatus.sold).toList();
      default:
        return _allProducts;
    }
  }

  // ── Counts ─────────────────────────────────────────────────────────────────
  int get _activeCount => _allProducts.where((p) => p.status == ProductStatus.active).length;
  int get _pendingCount => _allProducts.where((p) => p.status == ProductStatus.pending).length;
  int get _soldCount => _allProducts.where((p) => p.status == ProductStatus.sold).length;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterTabs(),
          _buildStatsRow(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _buildProductCard(_filtered[i]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _green,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4EF), // Light background for circle
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      title: const Text(
        'My Products',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4EF), // Light background for circle
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

  // ── Filter tabs ────────────────────────────────────────────────────────────

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filterLabels.length, (i) {
            final active = i == _filterIndex;
            return GestureDetector(
              onTap: () => setState(() => _filterIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFE8F5E9) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? _green : Colors.grey.shade300,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  _filterLabels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                    color: active ? _green : Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          _buildStatCard('$_activeCount', 'Active', const Color(0xFFF1F8E9), _green, const Color(0xFFC5E1A5)),
          const SizedBox(width: 8),
          _buildStatCard('${_allProducts.length}', 'Total', const Color(0xFFF1F8E9), _green, const Color(0xFFC5E1A5)),
          const SizedBox(width: 8),
          _buildStatCard('$_pendingCount', 'Pending', const Color(0xFFFFF8E1), const Color(0xFFF57F17), const Color(0xFFFFCC80)),
          const SizedBox(width: 8),
          _buildStatCard('$_soldCount', 'Sold', const Color(0xFFEEEEEE), Colors.grey.shade700, const Color(0xFFD6D6D6)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String count, String label, Color bg, Color textColor, Color borderColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10), // Changed to 10 as in the image it's slightly more rounded
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
              style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ── Product card ───────────────────────────────────────────────────────────

  Widget _buildProductCard(ProductItem product) {
    final isSold = product.status == ProductStatus.sold;
    final isPending = product.status == ProductStatus.pending;
    final borderColor = isPending ? const Color(0xFFF9A825) : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isPending ? 1.5 : 0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSold ? Colors.grey.shade400 : Colors.black87,
                        ),
                      ),
                    ),
                    _buildStatusBadge(product.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  product.details,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (product.note != null) ...[
                  const SizedBox(height: 6),
                  _buildNoteBanner(product.note!, product.noteType!),
                ],
                if (product.price.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.price,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSold ? Colors.grey.shade400 : Colors.black87,
                    ),
                  ),
                ],
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
    );
  }

  Widget _buildStatusBadge(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Active', style: TextStyle(fontSize: 10, color: _green, fontWeight: FontWeight.w600)),
        );
      case ProductStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Pending', style: TextStyle(fontSize: 10, color: Color(0xFFF9A825), fontWeight: FontWeight.w600)),
        );
      case ProductStatus.sold:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Sold', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
        );
    }
  }

  Widget _buildNoteBanner(String note, NoteType type) {
    final bg = type == NoteType.pending ? const Color(0xFFFFF8E1) : const Color(0xFFE3F2FD);
    final textColor = type == NoteType.pending ? const Color(0xFFF9A825) : const Color(0xFF1565C0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(note, style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w500)),
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
          style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ── Callbacks ──────────────────────────────────────────────────────────────

  void _onEdit(ProductItem product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit: ${product.name}'), duration: const Duration(seconds: 1)),
    );
  }

  void _onDelete(ProductItem product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, '🏠', 'Home'),
          _buildNavItem(1, '📦', 'Product'),
          _buildNavItem(2, '➕', 'add', isCenter: true),
          _buildNavItem(3, '🧾', 'Orders'),
          _buildNavItem(4, '👤', 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String emoji, String label, {bool isCenter = false}) {
    final active = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: isCenter ? 26 : 22)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? _green : Colors.grey.shade500,
              fontWeight: active ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
