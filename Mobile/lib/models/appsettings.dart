import 'package:ozbargain/models/filterrule.dart';

class AppSettings {
  String theme;
  String title;
  bool openBrowser;
  bool showNotifications;
  bool showUpgrades;
  List<DealFilter> alertFilters = new List<DealFilter>();
  String favourites;

  AppSettings({this.title, this.theme})
  {
    openBrowser = true;
    showNotifications = true;
    showUpgrades = true;
  }

  AppSettings.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? "";
    theme = json['theme'] ?? "light";
    openBrowser = json['openBrowser'] ?? true;
    showNotifications = json['showNotifications'] ?? true;
    showUpgrades = json['showUpgrades']?? true;
    favourites = json["favourites"]??"";
    
    var filters = json['alertFilters'];
    if (filters != null) {
      alertFilters.clear();
      for (var filter in filters) {
        alertFilters.add(DealFilter.fromJson(filter));
      }
    }
    if(alertFilters != null)
    print("AlertFilters ${alertFilters.length}");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['title'] = this.title ?? "";
    data['theme'] = this.theme ?? "light";
    data['openBrowser'] = this.openBrowser ?? true;
    data['showNotifications'] = this.showNotifications ?? true;
    data['alertFilters'] = this.alertFilters;
    data['showUpgrades'] = this.showUpgrades??true;
    data['favourites'] = this.favourites ??"";
    return data;
  }
}
