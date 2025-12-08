import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Screen events
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Custom events
  static Future<void> logEventViewing(String eventId, String eventName) async {
    await _analytics.logEvent(
      name: 'event_viewed',
      parameters: {
        'event_id': eventId,
        'event_name': eventName,
      },
    );
  }

  static Future<void> logProjectViewing(
      String projectId, String projectName) async {
    await _analytics.logEvent(
      name: 'project_viewed',
      parameters: {
        'project_id': projectId,
        'project_name': projectName,
      },
    );
  }

  static Future<void> logEventCreation(String eventName) async {
    await _analytics.logEvent(
      name: 'event_created',
      parameters: {
        'event_name': eventName,
      },
    );
  }

  static Future<void> logProjectCreation(String projectName) async {
    await _analytics.logEvent(
      name: 'project_created',
      parameters: {
        'project_name': projectName,
      },
    );
  }

  static Future<void> logUserLogin(String userId) async {
    await _analytics.logLogin(
      loginMethod: 'google_sign_in',
      parameters: {
        'user_id': userId,
      },
    );
  }

  static Future<void> logUserLogout() async {
    await _analytics.logEvent(
      name: 'user_logout',
      parameters: {},
    );
  }

  static Future<void> logUserSignUp(String userId) async {
    await _analytics.logSignUp(
      signUpMethod: 'email',
      parameters: {
        'user_id': userId,
      },
    );
  }

  static Future<void> logContributionJoin(
      String projectId, String userId) async {
    await _analytics.logEvent(
      name: 'contribution_joined',
      parameters: {
        'project_id': projectId,
        'user_id': userId,
      },
    );
  }

  static Future<void> logPageNavigation(String fromPage, String toPage) async {
    await _analytics.logEvent(
      name: 'page_navigation',
      parameters: {
        'from_page': fromPage,
        'to_page': toPage,
      },
    );
  }
}
