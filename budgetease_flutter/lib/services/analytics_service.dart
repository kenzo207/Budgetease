import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Provider for the Analytics Service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final Posthog _posthog = Posthog();

  /// Initialize analytics (call in main.dart)
  Future<void> init() async {
    // PostHog is mainly configured via AndroidManifest.xml / Info.plist
    // or passing options here if using the latest SDK versions.
    // For now, we rely on the native configuration or default no-op if missing.
  }

  /// Track a specific user event
  Future<void> capture(String eventName, {Map<String, dynamic>? properties}) async {
    try {
      if (kDebugMode) {
        print('📊 Analytics Event: $eventName | Properties: $properties');
      }
      // TODO: Re-enable PostHog when build issue is resolved
      // await _posthog.capture(eventName: eventName, properties: properties);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Analytics Error: $e');
      }
    }
  }

  /// Track a screen view
  Future<void> screen(String screenName, {Map<String, dynamic>? properties}) async {
    try {
      if (kDebugMode) {
        print('📱 Analytics Screen: $screenName | Properties: $properties');
      }
      // await _posthog.screen(screenName: screenName, properties: properties);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Analytics Error: $e');
      }
    }
  }
}
