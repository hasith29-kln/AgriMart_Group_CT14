import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/models/review_model.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/providers/review_provider.dart';
import '../../../../../core/theme/app_theme.dart';

class AddReviewDialog extends ConsumerStatefulWidget {
  final String farmerId;
  final String farmerName;
  final String? productId;
  final String? productName;

  const AddReviewDialog({
    super.key,
    required this.farmerId,
    required this.farmerName,
    this.productId,
    this.productName,
  });

  @override
  ConsumerState<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends ConsumerState<AddReviewDialog> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  String _selectedQuality = 'Super Fresh & Organic';
  bool _isSubmitting = false;

  final List<String> _qualityTags = [
    'Super Fresh & Organic',
    'High Quality Produce',
    'Great Taste & Texture',
    'Accurate Quantity',
    'Friendly Farmer',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a few words about your experience.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to leave a review.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final review = ReviewModel(
        id: '',
        farmerId: widget.farmerId,
        farmerName: widget.farmerName,
        buyerId: currentUser.id,
        buyerName: currentUser.name.isNotEmpty ? currentUser.name : 'Verified Buyer',
        productId: widget.productId,
        productName: widget.productName,
        rating: _rating,
        comment: comment,
        qualityFeedback: _selectedQuality,
        createdAt: DateTime.now(),
      );

      await ref.read(reviewControllerProvider.notifier).addReview(review);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your rating and review has been submitted.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Rate & Review',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
              'Reviewing: ${widget.farmerName}${widget.productName != null ? " (${widget.productName})" : ""}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Star Rating Selector
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1.0;
                      return IconButton(
                        iconSize: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: Icon(
                          _rating >= starValue
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: _rating >= starValue
                              ? const Color(0xFFFFB300)
                              : Colors.grey.shade300,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = starValue;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRatingLabel(_rating),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quality Tag chips
            const Text(
              'Quality & Freshness Tag',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _qualityTags.map((tag) {
                final isSelected = _selectedQuality == tag;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedQuality = tag);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEDF5E1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Comment textfield
            const Text(
              'Your Feedback',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe product freshness, taste, farmer communication, or packaging...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                fillColor: Colors.grey.shade50,
                filled: true,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 5.0) return '⭐⭐⭐⭐⭐ Excellent (5.0)';
    if (rating >= 4.0) return '⭐⭐⭐⭐ Very Good (4.0)';
    if (rating >= 3.0) return '⭐⭐⭐ Average (3.0)';
    if (rating >= 2.0) return '⭐⭐ Below Average (2.0)';
    return '⭐ Poor (1.0)';
  }
}
