import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:posthog_flutter/posthog_flutter.dart';

/// Provider for the Analytics Service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  // final Posthog _posthog = Posthog();

  /// Initialize analytics (call in main.dart)
  Future<void> init() async {
    // PostHog temporarily disabled due to Gradle build conflict
  }

  /// Track a specific user event
  Future<void> capture(String eventName, {Map<String, dynamic>? properties}) async {
    try {
      if (kDebugMode) {
        print('📊 Analytics Event (Mock): $eventName | Properties: $properties');
      }
      
      // await _posthog.capture(eventName: eventName, properties: safeProperties);
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
        print('📱 Analytics Screen (Mock): $screenName | Properties: $properties');
      }
      
      // await _posthog.screen(screenName: screenName, properties: safeProperties);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Analytics Error: $e');
      }
    }
  }
}
