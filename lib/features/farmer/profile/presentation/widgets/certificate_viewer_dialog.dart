import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/models/certificate_model.dart';
import '../../../../../core/theme/app_theme.dart';

class CertificateViewerDialog extends StatelessWidget {
  final CertificateModel certificate;

  const CertificateViewerDialog({
    super.key,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
    final isRevoked = certificate.status == 'revoked';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 22),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              // Certificate Inner Border
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFBF7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isRevoked ? Colors.red.shade300 : const Color(0xFFD4AF37), // Gold border
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // Official Icon / Seal
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isRevoked ? Colors.red.shade50 : const Color(0xFFFFF8E1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isRevoked ? Colors.red : const Color(0xFFFFD54F),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isRevoked ? '❌' : '🏆',
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Text(
                      isRevoked
                          ? 'CERTIFICATE REVOKED'
                          : 'OFFICIAL AGRICULTURAL CERTIFICATE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: isRevoked ? Colors.red : const Color(0xFF8D6E63),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      certificate.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isRevoked ? Colors.black54 : const Color(0xFF2E5E16),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${certificate.category}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFD4AF37), thickness: 1),
                    const SizedBox(height: 14),

                    // Awarded To
                    const Text(
                      'This is proudly presented to:',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      certificate.farmerName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Assessment / Description
                    Text(
                      certificate.description.isNotEmpty
                          ? '"${certificate.description}"'
                          : '"Recognized for maintaining exceptional agricultural quality and high buyer satisfaction ratings on AgriMart."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Metrics badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFB300)),
                          const SizedBox(width: 4),
                          Text(
                            'Rating at issue: ${certificate.averageRatingAtIssue.toStringAsFixed(1)} / 5.0 (${certificate.totalReviewsAtIssue} reviews)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Officer signature & verification details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Certified By:',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              certificate.officerName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              certificate.officerDepartment,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Issued Date:',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM d, yyyy').format(certificate.issuedAt),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'ID: ${certificate.certificateNumber}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Done button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
