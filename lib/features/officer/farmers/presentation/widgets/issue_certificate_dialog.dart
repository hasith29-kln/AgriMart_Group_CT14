import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/models/certificate_model.dart';
import '../../../../../core/models/user_model.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/providers/certificate_provider.dart';
import '../../../../../core/providers/review_provider.dart';

class IssueCertificateDialog extends ConsumerStatefulWidget {
  final UserModel farmer;

  const IssueCertificateDialog({
    super.key,
    required this.farmer,
  });

  @override
  ConsumerState<IssueCertificateDialog> createState() => _IssueCertificateDialogState();
}

class _IssueCertificateDialogState extends ConsumerState<IssueCertificateDialog> {
  String _selectedTitle = 'Top-Rated Quality Farmer';
  String _selectedCategory = 'Quality & Freshness';
  final TextEditingController _descriptionController = TextEditingController();
  int _validityYears = 1;
  bool _isIssuing = false;

  final List<Map<String, String>> _certificatePresets = [
    {
      'title': 'Top-Rated Quality Farmer',
      'category': 'Quality & Freshness',
      'desc': 'Awarded for consistently receiving high ratings (4.5+ stars) and outstanding feedback from buyers regarding produce freshness and satisfaction.',
    },
    {
      'title': 'Certified Organic Producer',
      'category': 'Organic Standards',
      'desc': 'Verified for adhering to clean, pesticide-free, and sustainable organic farming methods with positive consumer verification.',
    },
    {
      'title': 'GAP (Good Agricultural Practices) Certified',
      'category': 'Good Agricultural Practices',
      'desc': 'Certified for complying with Good Agricultural Practices, ensuring food safety, environmental sustainability, and worker welfare.',
    },
    {
      'title': 'Verified Premium Supplier',
      'category': 'Supply Reliability',
      'desc': 'Recognized for excellent order fulfillment, accurate quantity dispatch, and high buyer reliability score.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController.text = _certificatePresets[0]['desc']!;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _issueCertificate() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Officer credentials not found.')),
      );
      return;
    }

    final ratingSummary = ref.read(farmerRatingSummaryProvider(widget.farmer.id));

    setState(() => _isIssuing = true);

    try {
      final now = DateTime.now();
      final certificateNumber = 'CERT-${now.year}-${widget.farmer.name.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      final certificate = CertificateModel(
        id: '',
        certificateNumber: certificateNumber,
        farmerId: widget.farmer.id,
        farmerName: widget.farmer.name,
        officerId: currentUser.id,
        officerName: currentUser.name.isNotEmpty ? currentUser.name : 'Agricultural Officer',
        officerDepartment: currentUser.department ?? 'Department of Agriculture',
        title: _selectedTitle,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        averageRatingAtIssue: ratingSummary.averageRating,
        totalReviewsAtIssue: ratingSummary.totalReviews,
        status: 'active',
        issuedAt: now,
        validUntil: now.add(Duration(days: 365 * _validityYears)),
      );

      await ref.read(certificateControllerProvider.notifier).issueCertificate(certificate);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Official certificate "$_selectedTitle" issued to ${widget.farmer.name}!'),
            backgroundColor: const Color(0xFF387015),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to issue certificate: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isIssuing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingSummary = ref.watch(farmerRatingSummaryProvider(widget.farmer.id));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('🏆', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text(
                      'Issue Certificate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Issuing recognition to: ${widget.farmer.name} (${widget.farmer.district ?? "District"})',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Performance snapshot
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC5E1A5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Avg Rating', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                          const SizedBox(width: 2),
                          Text(
                            ratingSummary.averageRating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(width: 1, height: 24, color: Colors.grey.shade300),
                  Column(
                    children: [
                      const Text('Buyer Reviews', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text(
                        '${ratingSummary.totalReviews}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 24, color: Colors.grey.shade300),
                  Column(
                    children: [
                      const Text('Status', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text(
                        widget.farmer.status.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Certificate Type Dropdown
            const Text(
              'Certificate Type',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedTitle,
              isExpanded: true,
              decoration: InputDecoration(
                fillColor: Colors.grey.shade50,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF8D5A36), width: 1.5),
                ),
              ),
              items: _certificatePresets.map((preset) {
                return DropdownMenuItem<String>(
                  value: preset['title'],
                  child: Text(
                    preset['title']!,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final preset = _certificatePresets.firstWhere((p) => p['title'] == val);
                  setState(() {
                    _selectedTitle = val;
                    _selectedCategory = preset['category']!;
                    _descriptionController.text = preset['desc']!;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Assessment / Recommendation
            const Text(
              'Officer Recommendation & Justification',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                fillColor: Colors.grey.shade50,
                filled: true,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF8D5A36), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Validity Period
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Validity Period',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        initialValue: _validityYears,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF8D5A36), width: 1.5),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 Year', style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(value: 2, child: Text('2 Years', style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(value: 3, child: Text('3 Years', style: TextStyle(fontSize: 13))),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _validityYears = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Issue Certificate Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isIssuing ? null : _issueCertificate,
                icon: const Icon(Icons.verified, size: 18),
                label: _isIssuing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Issue Official Certificate',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D5A36), // Brown officer color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
