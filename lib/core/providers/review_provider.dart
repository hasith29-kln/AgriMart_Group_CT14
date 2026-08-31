import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../repositories/review_repository.dart';
import '../models/review_model.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

final farmerReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, farmerId) {
  return ref.watch(reviewRepositoryProvider).getReviewsForFarmer(farmerId);
});

final productReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, productId) {
  return ref.watch(reviewRepositoryProvider).getReviewsForProduct(productId);
});

final allReviewsProvider = StreamProvider<List<ReviewModel>>((ref) {
  return ref.watch(reviewRepositoryProvider).getAllReviews();
});

class RatingSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> starCounts; // 5: count, 4: count, etc.

  RatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.starCounts,
  });

  factory RatingSummary.fromReviews(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return RatingSummary(
        averageRating: 5.0,
        totalReviews: 0,
        starCounts: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );
    }

    double sum = 0;
    final Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var r in reviews) {
      sum += r.rating;
      int rounded = r.rating.round().clamp(1, 5);
      counts[rounded] = (counts[rounded] ?? 0) + 1;
    }

    return RatingSummary(
      averageRating: sum / reviews.length,
      totalReviews: reviews.length,
      starCounts: counts,
    );
  }
}

final farmerRatingSummaryProvider =
    Provider.family<RatingSummary, String>((ref, farmerId) {
  final reviews = ref.watch(farmerReviewsProvider(farmerId)).value ?? [];
  return RatingSummary.fromReviews(reviews);
});

class ReviewController extends StateNotifier<AsyncValue<void>> {
  final ReviewRepository _reviewRepository;

  ReviewController(this._reviewRepository)
      : super(const AsyncValue.data(null));

  Future<void> addReview(ReviewModel review) async {
    state = const AsyncValue.loading();
    try {
      await _reviewRepository.addReview(review);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final reviewControllerProvider =
    StateNotifierProvider<ReviewController, AsyncValue<void>>((ref) {
  return ReviewController(ref.watch(reviewRepositoryProvider));
});
