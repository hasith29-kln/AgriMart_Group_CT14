import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/providers/product_provider.dart';
import 'package:intl/intl.dart';

class OfficerZoneReportsPage extends ConsumerStatefulWidget {
  const OfficerZoneReportsPage({super.key});

  @override
  ConsumerState<OfficerZoneReportsPage> createState() =>
      _OfficerZoneReportsPageState();
}

class _OfficerZoneReportsPageState
    extends ConsumerState<OfficerZoneReportsPage> {
  final Color primaryBrown = const Color(0xFF8D5A36);
  String? _selectedReportTitle;

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
          'Zone Reports',
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
              'Weekly summaries',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Review monthly and weekly performance summaries.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            farmersAsync.when(
              data: (farmers) {
                return productsAsync.when(
                  data: (products) {
                    final now = DateTime.now();

                    // Week 1 (Current week)
                    final w1Start = now.subtract(
                      Duration(days: now.weekday - 1),
                    );
                    final w1End = w1Start.add(
                      const Duration(days: 6, hours: 23, minutes: 59),
                    );
                    final w1Farmers = farmers
                        .where((f) => f.createdAt.isAfter(w1Start))
                        .length;
                    final w1Products = products
                        .where((p) => p.createdAt.isAfter(w1Start))
                        .length;

                    // Week 2 (Previous week)
                    final w2Start = w1Start.subtract(const Duration(days: 7));
                    final w2End = w2Start.add(
                      const Duration(days: 6, hours: 23, minutes: 59),
                    );
                    final w2Farmers = farmers
                        .where(
                          (f) =>
                              f.createdAt.isAfter(w2Start) &&
                              f.createdAt.isBefore(w2End),
                        )
                        .length;
                    final w2Products = products
                        .where(
                          (p) =>
                              p.createdAt.isAfter(w2Start) &&
                              p.createdAt.isBefore(w2End),
                        )
                        .length;

                    // Week 3 (Two weeks ago)
                    final w3Start = w2Start.subtract(const Duration(days: 7));
                    final w3End = w3Start.add(
                      const Duration(days: 6, hours: 23, minutes: 59),
                    );
                    final w3Farmers = farmers
                        .where(
                          (f) =>
                              f.createdAt.isAfter(w3Start) &&
                              f.createdAt.isBefore(w3End),
                        )
                        .length;
                    final w3Products = products
                        .where(
                          (p) =>
                              p.createdAt.isAfter(w3Start) &&
                              p.createdAt.isBefore(w3End),
                        )
                        .length;

                    // Monthly (Current month)
                    final mStart = DateTime(now.year, now.month, 1);
                    final mFarmers = farmers
                        .where((f) => f.createdAt.isAfter(mStart))
                        .length;
                    final mProducts = products
                        .where((p) => p.createdAt.isAfter(mStart))
                        .length;

                    final weekNum =
                        ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7)
                            .ceil();

                    return Column(
                      children: [
                        _buildReportItem(
                          context,
                          'Weekly Report - Week $weekNum',
                          '${DateFormat('MMM dd').format(w1Start)} - ${DateFormat('MMM dd, yyyy').format(w1End)}',
                          w1Farmers,
                          w1Products,
                        ),
                        const SizedBox(height: 16),
                        _buildReportItem(
                          context,
                          'Weekly Report - Week ${weekNum - 1}',
                          '${DateFormat('MMM dd').format(w2Start)} - ${DateFormat('MMM dd, yyyy').format(w2End)}',
                          w2Farmers,
                          w2Products,
                        ),
                        const SizedBox(height: 16),
                        _buildReportItem(
                          context,
                          'Weekly Report - Week ${weekNum - 2}',
                          '${DateFormat('MMM dd').format(w3Start)} - ${DateFormat('MMM dd, yyyy').format(w3End)}',
                          w3Farmers,
                          w3Products,
                        ),
                        const SizedBox(height: 16),
                        _buildReportItem(
                          context,
                          'Monthly Summary - ${DateFormat('MMMM').format(now)}',
                          '${DateFormat('MMM 01').format(now)} - ${DateFormat('MMM dd, yyyy').format(now)}',
                          mFarmers,
                          mProducts,
                          isMonthly: true,
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
              error: (err, _) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context,
    String title,
    String dateRange,
    int farmersCount,
    int productsCount, {
    bool isMonthly = false,
  }) {
    final bool isSelected = _selectedReportTitle == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReportTitle = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryBrown
                : (isMonthly ? const Color(0xFFFFCC80) : Colors.grey.shade200),
            width: isSelected ? 2.0 : (isMonthly ? 1.5 : 1.0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryBrown.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (isMonthly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Monthly',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateRange,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                farmersCount == 0 && productsCount == 0
                    ? const Text(
                        'No Data Available',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Row(
                        children: [
                          const Text('🧑‍🌾', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '$farmersCount Farmers',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text('📦', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '$productsCount Products',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                IconButton(
                  icon: Icon(
                    Icons.download,
                    color: farmersCount == 0 && productsCount == 0
                        ? Colors.grey
                        : Colors.green,
                  ),
                  onPressed: farmersCount == 0 && productsCount == 0
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report download started...'),
                            ),
                          );
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
