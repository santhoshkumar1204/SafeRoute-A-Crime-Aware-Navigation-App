import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  /// [state] == true means online.
  ConnectivityNotifier() : super(true) {
    _sub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      state = results.any((r) => r != ConnectivityResult.none);
    });
    _checkNow();
  }

  Future<void> _checkNow() async {
    final results = await Connectivity().checkConnectivity();
    state = results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
