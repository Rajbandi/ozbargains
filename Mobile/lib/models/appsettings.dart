class AppSettings {
  String theme;
  String title;
  bool openBrowser;

  AppSettings({this.title, this.theme});

  AppSettings.fromJson(Map<String, dynamic> json) {
    
    title = json['title']??"";
    theme = json['theme']??"light";
    openBrowser = json['openBrowser']??false;
  
  }

  Map<String, dynamic> toJson() {
  
    final Map<String, dynamic> data = new Map<String, dynamic>();
    
    data['title'] = this.title??"";
    data['theme'] = this.theme??"light";
    data['openBrowser'] = this.openBrowser??false;

    return data;
  }
  
}