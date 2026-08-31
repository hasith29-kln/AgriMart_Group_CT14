import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/providers/request_provider.dart';
import '../../../../../core/models/request_model.dart';
import '../../../product/presentation/widgets/add_review_dialog.dart';

class BuyerOrdersPage extends ConsumerStatefulWidget {
  const BuyerOrdersPage({super.key});

  @override
  ConsumerState<BuyerOrdersPage> createState() => _BuyerOrdersPageState();
}

class _BuyerOrdersPageState extends ConsumerState<BuyerOrdersPage> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(buyerRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: requestsAsync.when(
        data: (allRequests) {
          int total = allRequests.length;
          int pending = allRequests.where((r) => r.status == 'pending').length;
          int accepted = allRequests.where((r) => r.status == 'accepted').length;
          int rejected = allRequests.where((r) => r.status == 'rejected').length;

          List<RequestModel> filteredRequests = allRequests.where((r) {
            if (_selectedFilter == 'ALL') return true;
            return r.status.toLowerCase() == _selectedFilter.toLowerCase();
          }).toList();
          
          filteredRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', total),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', pending),
                      const SizedBox(width: 8),
                      _buildFilterChip('Accepted', accepted),
                      const SizedBox(width: 8),
                      _buildFilterChip('Rejected', rejected),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Stat Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '$total',
                        'Total',
                        bgColor: Colors.blue.shade50,
                        borderColor: Colors.blue.shade200,
                        textColor: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '$accepted',
                        'Accepted',
                        bgColor: const Color(0xFFEDF5E1),
                        borderColor: const Color(0xFFC5E1A5),
                        textColor: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '$pending',
                        'Pending',
                        bgColor: Colors.orange.shade50,
                        borderColor: Colors.orange.shade200,
                        textColor: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (filteredRequests.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Text('No orders found.'),
                    ),
                  )
                else ...[
                  if (_selectedFilter == 'ALL' || _selectedFilter == 'Pending') ...[
                    // Pending Section
                    Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...filteredRequests
                        .where((r) => r.status == 'pending')
                        .map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildPendingOrderCard(r),
                            )),
                    if (filteredRequests.any((r) => r.status == 'pending'))
                      const SizedBox(height: 12),
                  ],

                  if (_selectedFilter == 'ALL' || _selectedFilter != 'Pending') ...[
                    // Previous Orders Section
                    const Text(
                      'Previous Orders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...filteredRequests
                        .where((r) => r.status != 'pending')
                        .map((r) {
                      final isRejected = r.status == 'rejected';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildPreviousOrderCard(
                          request: r,
                          title: '${r.productName} — ${r.quantity.toStringAsFixed(0)} kg',
                          farmer: '🧑‍🌾 ${r.farmerName} · Rs. ${r.totalPrice.toStringAsFixed(0)}',
                          time: DateFormat('MMM d, yyyy h:mm a').format(r.createdAt),
                          status: isRejected ? 'Rejected' : 'Accepted',
                          statusColor: isRejected ? Colors.red.shade50 : const Color(0xFFEDF5E1),
                          statusTextColor: isRejected ? Colors.red.shade300 : const Color(0xFF2E7D32),
                          isFaded: isRejected,
                        ),
                      );
                    }),
                  ],
                ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '$label($count)',
          style: TextStyle(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingOrderCard(RequestModel request) {
    String deliveryMethod = request.deliveryType == 'pickup' ? 'Pickup from farm' : 'Request delivery';
    String timeAgo = DateFormat('MMM d, h:mm a').format(request.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          request.productName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '🧑‍🌾 ${request.farmerName} · ${request.quantity.toStringAsFixed(0)} kg',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${request.totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Requested: $timeAgo · $deliveryMethod',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('⏳', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  'Waiting for farmer to respond...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousOrderCard({
    required RequestModel request,
    required String title,
    required String farmer,
    required String time,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    bool isFaded = false,
  }) {
    final titleColor = isFaded ? Colors.grey.shade400 : Colors.black87;
    final subtitleColor = isFaded ? Colors.grey.shade300 : Colors.grey.shade600;
    final imageBg = isFaded ? Colors.red.shade50 : const Color(0xFFE8F5E9);
    final isAccepted = request.status == 'accepted';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFaded ? const Color(0xFFFAFAFA) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: imageBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    isFaded ? '❌' : '📦',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      farmer,
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: isFaded
                            ? Colors.grey.shade300
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isAccepted) ...[
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddReviewDialog(
                        farmerId: request.farmerId,
                        farmerName: request.farmerName,
                        productId: request.productId,
                        productName: request.productName,
                      ),
                    );
                  },
                  icon: const Icon(Icons.star_outline_rounded, size: 16, color: Color(0xFF2E5E16)),
                  label: const Text(
                    'Rate Farmer & Product',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5E16),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2E5E16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
