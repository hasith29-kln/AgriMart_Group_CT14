class ReviewModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String buyerId;
  final String buyerName;
  final String? productId;
  final String? productName;
  final double rating; // 1.0 to 5.0
  final String comment;
  final String qualityFeedback; // e.g. "Excellent Freshness", "Good Quality"
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.buyerId,
    required this.buyerName,
    this.productId,
    this.productName,
    required this.rating,
    required this.comment,
    this.qualityFeedback = 'Good Quality',
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReviewModel(
      id: documentId,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      productId: map['productId'],
      productName: map['productName'],
      rating: (map['rating'] ?? 5.0).toDouble(),
      comment: map['comment'] ?? '',
      qualityFeedback: map['qualityFeedback'] ?? 'Good Quality',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'productId': productId,
      'productName': productName,
      'rating': rating,
      'comment': comment,
      'qualityFeedback': qualityFeedback,
      'createdAt': createdAt,
    };
  }
}
