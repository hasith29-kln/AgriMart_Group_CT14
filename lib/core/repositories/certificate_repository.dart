import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/certificate_model.dart';

class CertificateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CertificateModel>> getCertificatesForFarmer(String farmerId) {
    return _firestore
        .collection('certificates')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) {
      final certs = snapshot.docs
          .map((doc) => CertificateModel.fromMap(doc.data(), doc.id))
          .toList();
      certs.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
      return certs;
    });
  }

  Stream<List<CertificateModel>> getAllCertificates() {
    return _firestore
        .collection('certificates')
        .snapshots()
        .map((snapshot) {
      final certs = snapshot.docs
          .map((doc) => CertificateModel.fromMap(doc.data(), doc.id))
          .toList();
      certs.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
      return certs;
    });
  }

  Future<void> issueCertificate(CertificateModel certificate) async {
    await _firestore.collection('certificates').add({
      ...certificate.toMap(),
      'issuedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> revokeCertificate(String certificateId) async {
    await _firestore
        .collection('certificates')
        .doc(certificateId)
        .update({'status': 'revoked'});
  }
}
