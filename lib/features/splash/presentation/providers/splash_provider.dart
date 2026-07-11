import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages splash screen navigation state.
/// Extend this to add logic e.g. auto-login check.
class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() => SplashState.idle;

  Future<void> initialize() async {
    state = SplashState.loading;
    // TODO: Check auth state / token, then navigate accordingly
    await Future.delayed(const Duration(seconds: 2));
    state = SplashState.ready;
  }
}

enum SplashState { idle, loading, ready }

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
