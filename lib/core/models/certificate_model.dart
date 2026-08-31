class CertificateModel {
  final String id;
  final String certificateNumber; // e.g. "CERT-2026-FARM-042"
  final String farmerId;
  final String farmerName;
  final String officerId;
  final String officerName;
  final String officerDepartment;
  final String title; // e.g. "Certified Top-Rated Farmer", "Certified Organic Producer", "GAP Certified"
  final String category; // e.g. "Quality & Freshness", "Organic Standards", "Good Agricultural Practices"
  final String description; // Assessment / recommendation by the officer
  final double averageRatingAtIssue;
  final int totalReviewsAtIssue;
  final String status; // 'active', 'revoked', 'expired'
  final DateTime issuedAt;
  final DateTime? validUntil;

  CertificateModel({
    required this.id,
    required this.certificateNumber,
    required this.farmerId,
    required this.farmerName,
    required this.officerId,
    required this.officerName,
    required this.officerDepartment,
    required this.title,
    required this.category,
    required this.description,
    required this.averageRatingAtIssue,
    required this.totalReviewsAtIssue,
    this.status = 'active',
    required this.issuedAt,
    this.validUntil,
  });

  factory CertificateModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CertificateModel(
      id: documentId,
      certificateNumber: map['certificateNumber'] ?? 'CERT-${documentId.substring(0, 6).toUpperCase()}',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      officerId: map['officerId'] ?? '',
      officerName: map['officerName'] ?? '',
      officerDepartment: map['officerDepartment'] ?? 'Department of Agriculture',
      title: map['title'] ?? 'Top-Rated Quality Farmer',
      category: map['category'] ?? 'Quality & Freshness',
      description: map['description'] ?? '',
      averageRatingAtIssue: (map['averageRatingAtIssue'] ?? 5.0).toDouble(),
      totalReviewsAtIssue: map['totalReviewsAtIssue'] ?? 1,
      status: map['status'] ?? 'active',
      issuedAt: map['issuedAt'] != null
          ? (map['issuedAt'] as dynamic).toDate()
          : DateTime.now(),
      validUntil: map['validUntil'] != null
          ? (map['validUntil'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'certificateNumber': certificateNumber,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'officerId': officerId,
      'officerName': officerName,
      'officerDepartment': officerDepartment,
      'title': title,
      'category': category,
      'description': description,
      'averageRatingAtIssue': averageRatingAtIssue,
      'totalReviewsAtIssue': totalReviewsAtIssue,
      'status': status,
      'issuedAt': issuedAt,
      'validUntil': validUntil,
    };
  }
}
