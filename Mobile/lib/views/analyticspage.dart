import 'app.dart';

abstract class AnalyticsPage {
  String get pageName;
  // FirebaseAnalytics constructor reuses a single instance, so it's ok to call like this
  void setCurrentPage() =>
      OzBargainApp.analytics.setCurrentScreen(screenName: pageName);
}