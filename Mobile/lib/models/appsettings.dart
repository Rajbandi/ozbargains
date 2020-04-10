import 'package:ozbargain/models/filterrule.dart';

class AppSettings {
  String theme;
  String title;
  bool openBrowser;
  bool showNotifications;

  List<DealFilter> alertFilters = new List<DealFilter>();

  AppSettings({this.title, this.theme});

  AppSettings.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? "";
    theme = json['theme'] ?? "light";
    openBrowser = json['openBrowser'] ?? true;
    showNotifications = json['showNotifications'] ?? true;
    var filters = json['alertFilters'];
    if (filters != null) {
      alertFilters.clear();
      for (var filter in filters) {
        alertFilters.add(DealFilter.fromJson(filter));
      }
    }
    print("AlertFilters ${alertFilters.length}");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['title'] = this.title ?? "";
    data['theme'] = this.theme ?? "light";
    data['openBrowser'] = this.openBrowser ?? true;
    data['showNotifications'] = this.showNotifications ?? true;
    data['alertFilters'] = this.alertFilters;

    return data;
  }
}
