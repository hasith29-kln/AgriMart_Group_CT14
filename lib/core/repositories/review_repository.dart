import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ReviewModel>> getReviewsForFarmer(String farmerId) {
    return _firestore
        .collection('reviews')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  Stream<List<ReviewModel>> getReviewsForProduct(String productId) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  Stream<List<ReviewModel>> getAllReviews() {
    return _firestore
        .collection('reviews')
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection('reviews').add({
      ...review.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
