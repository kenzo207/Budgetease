import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Provider for the Analytics Service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final Posthog _posthog = Posthog();

  /// Track a specific user event
  Future<void> capture(String eventName, {Map<String, dynamic>? properties}) async {
    try {
      if (kDebugMode) {
        debugPrint('📊 Analytics: $eventName | $properties');
      }
      final Map<String, Object>? safeProperties = properties?.map(
        (key, value) => MapEntry(key, value as Object),
      );
      await _posthog.capture(
        eventName: eventName,
        properties: safeProperties,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Analytics Error: $e');
      }
    }
  }

  /// Track a screen view
  Future<void> screen(String screenName, {Map<String, dynamic>? properties}) async {
    try {
      if (kDebugMode) {
        debugPrint('📱 Analytics Screen: $screenName | $properties');
      }
      final Map<String, Object>? safeProperties = properties?.map(
        (key, value) => MapEntry(key, value as Object),
      );
      await _posthog.screen(
        screenName: screenName,
        properties: safeProperties,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Analytics Error: $e');
      }
    }
  }

  /// Identify a user
  Future<void> identify(String userId, {Map<String, dynamic>? properties}) async {
    try {
      final Map<String, Object>? safeProperties = properties?.map(
        (key, value) => MapEntry(key, value as Object),
      );
      await _posthog.identify(
        userId: userId,
        userProperties: safeProperties,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Analytics Identify Error: $e');
      }
    }
  }

  /// Reset user identity (e.g., on logout)
  Future<void> reset() async {
    try {
      await _posthog.reset();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Analytics Reset Error: $e');
      }
    }
  }
}
