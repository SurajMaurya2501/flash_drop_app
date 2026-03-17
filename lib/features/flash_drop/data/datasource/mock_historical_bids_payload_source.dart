import 'package:flutter/services.dart';

class MockHistoricalBidsPayloadSource {
  static const String _assetPath = 'assets/data/historical_bids_50k.json';
  String? _cachedPayload;

  Future<String> fetchMassivePayload() async {
    final cachedPayload = _cachedPayload;
    if (cachedPayload != null) {
      return cachedPayload;
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    final payload = await rootBundle.loadString(_assetPath);
    _cachedPayload = payload;
    return payload;
  }
}
