import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../repositories/certificate_repository.dart';
import '../models/certificate_model.dart';

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return CertificateRepository();
});

final farmerCertificatesProvider =
    StreamProvider.family<List<CertificateModel>, String>((ref, farmerId) {
  return ref.watch(certificateRepositoryProvider).getCertificatesForFarmer(farmerId);
});

final allCertificatesProvider = StreamProvider<List<CertificateModel>>((ref) {
  return ref.watch(certificateRepositoryProvider).getAllCertificates();
});

class CertificateController extends StateNotifier<AsyncValue<void>> {
  final CertificateRepository _certificateRepository;

  CertificateController(this._certificateRepository)
      : super(const AsyncValue.data(null));

  Future<void> issueCertificate(CertificateModel certificate) async {
    state = const AsyncValue.loading();
    try {
      await _certificateRepository.issueCertificate(certificate);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> revokeCertificate(String certificateId) async {
    state = const AsyncValue.loading();
    try {
      await _certificateRepository.revokeCertificate(certificateId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final certificateControllerProvider =
    StateNotifierProvider<CertificateController, AsyncValue<void>>((ref) {
  return CertificateController(ref.watch(certificateRepositoryProvider));
});
