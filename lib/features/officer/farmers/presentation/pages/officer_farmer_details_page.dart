import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/models/user_model.dart';
import '../../../../../core/providers/review_provider.dart';
import '../../../../../core/providers/certificate_provider.dart';
import '../../../../../core/providers/product_provider.dart';
import '../../../../farmer/profile/presentation/widgets/certificate_viewer_dialog.dart';
import '../widgets/issue_certificate_dialog.dart';

class OfficerFarmerDetailsPage extends ConsumerWidget {
  final UserModel farmer;

  const OfficerFarmerDetailsPage({
    super.key,
    required this.farmer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingSummary = ref.watch(farmerRatingSummaryProvider(farmer.id));
    final reviewsAsync = ref.watch(farmerReviewsProvider(farmer.id));
    final certificatesAsync = ref.watch(farmerCertificatesProvider(farmer.id));
    final allProducts = ref.watch(allProductsProvider).value ?? [];
    final farmerProducts = allProducts.where((p) => p.farmerId == farmer.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8D5A36), // Brown officer color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          farmer.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: Color(0xFFFFD54F)),
            tooltip: 'Issue Certificate',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => IssueCertificateDialog(farmer: farmer),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Farmer Overview Card ──
            Container(
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
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC5E1A5),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🧑‍🌾', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${farmer.district ?? "Unknown District"} · ${farmerProducts.length} Listings',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NIC: ${farmer.nic ?? "N/A"} · Tel: ${farmer.phone ?? farmer.email}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEEEEEE), height: 1),
                  const SizedBox(height: 14),

                  // Rating Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        'Average Rating',
                        '⭐ ${ratingSummary.averageRating.toStringAsFixed(1)}',
                        const Color(0xFF2E7D32),
                      ),
                      Container(width: 1, height: 28, color: Colors.grey.shade200),
                      _buildMetric(
                        'Total Reviews',
                        '${ratingSummary.totalReviews}',
                        Colors.black87,
                      ),
                      Container(width: 1, height: 28, color: Colors.grey.shade200),
                      _buildMetric(
                        'Status',
                        farmer.status.toUpperCase(),
                        farmer.status == 'approved' ? const Color(0xFF2E7D32) : Colors.orange.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Official Certificates Section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('🏆', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Official Certificates',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => IssueCertificateDialog(farmer: farmer),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFF8D5A36)),
                  label: const Text(
                    'Issue New',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8D5A36),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            certificatesAsync.when(
              data: (certificates) {
                if (certificates.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text('📜', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          'No certificates issued yet for this farmer.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => IssueCertificateDialog(farmer: farmer),
                            );
                          },
                          icon: const Icon(Icons.workspace_premium, size: 16),
                          label: const Text('Issue Recognition Certificate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8D5A36),
                            side: const BorderSide(color: Color(0xFF8D5A36)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: certificates.map((cert) {
                    final isRevoked = cert.status == 'revoked';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isRevoked ? Colors.grey.shade50 : const Color(0xFFFCFBF7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRevoked ? Colors.grey.shade300 : const Color(0xFFD4AF37),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(isRevoked ? '❌' : '🎖️', style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        cert.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isRevoked ? Colors.grey : const Color(0xFF2E5E16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isRevoked ? Colors.red.shade50 : const Color(0xFFEDF5E1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  cert.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isRevoked ? Colors.red : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cert.description,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Issued: ${DateFormat('MMM d, yyyy').format(cert.issuedAt)} · By ${cert.officerName}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => CertificateViewerDialog(certificate: cert),
                                      );
                                    },
                                    child: const Text(
                                      'View',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8D5A36),
                                      ),
                                    ),
                                  ),
                                  if (!isRevoked) ...[
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () async {
                                        await ref.read(certificateControllerProvider.notifier).revokeCertificate(cert.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Certificate revoked.')),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Revoke',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // ── Buyer Reviews & Ratings List ──
            const Row(
              children: [
                Text('💬', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  'Buyer Reviews & Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            reviewsAsync.when(
              data: (reviews) {
                if (reviews.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Text(
                        'No buyer reviews yet for this farmer.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ),
                  );
                }

                return Column(
                  children: reviews.map((r) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r.buyerName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < r.rating.round()
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 16,
                                    color: const Color(0xFFFFB300),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (r.qualityFeedback.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF5E1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                r.qualityFeedback,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          Text(
                            r.comment,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('MMM d, yyyy · h:mm a').format(r.createdAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
