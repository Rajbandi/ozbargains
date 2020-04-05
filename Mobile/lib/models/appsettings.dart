class AppSettings {
  String theme;
  String title;

  AppSettings({this.title, this.theme});

  AppSettings.fromJson(Map<String, dynamic> json) {
    title = json['title']??"";
    theme = json['theme']??"light";
  }

  Map<String, dynamic> toJson() {
    print("To Json*****");
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title??"";
    data['theme'] = this.theme??"light";
  
    return data;
  }
}