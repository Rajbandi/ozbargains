import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';
import 'package:ozbargain/models/appsettings.dart';
import 'package:ozbargain/viewmodels/thememodel.dart';
import 'package:ozbargain/views/dealwebview.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHelper {
  AppHelper()
  {
      refreshSettings();
      
      }
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static int currentTimeInSeconds(DateTime d) {
    var ms = d.millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  static openUrl(context, title, url) async {
    //    print("*** Url $url");
    //await DealBrowser().open(url: url, options: InAppBrowserClassOptions());

    if (isUrlValid(url)) {
      var view = new DealWebView(
        title: title,
        url: url,
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (BuildContext context) => view));
    } else {
      showSnackError("Invalid Url : $url");
    }
  }

  static bool isUrlValid(String url) {
    bool validUrl = Uri.parse(url).isAbsolute;
    return validUrl;
  }

  static getDateFromUnix(int timeStamp) {
    return DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  }

  static getLocalDateTime(DateTime date) {
    DateFormat format = new DateFormat("dd-MMM-yyyy hh:mm");
    var dt = format.format(date);
    return dt;
  }

  static Future showNotificationWithoutSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        playSound: false, importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'No_Sound',
    );
  }

  static void shareData(String subject, String data) {
    Share.share(data, subject: subject);
  }

  static String getHtmlText(String html) {
    try {
      var document = parse(html ?? "");
      String text = parse(document.body.text).documentElement.text;
      return text;
    } catch (e) {
      return "";
    }
  }

  static GlobalKey<ScaffoldState> scaffoldKey;
  static void showSnackError(message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.redAccent,
    ));
  }

  static void showSnackMessage(message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  static void copyToClipboard(msg, text, {bool show: true}) {
    Clipboard.setData(ClipboardData(text: text));
    if (show) showSnackMessage("$msg \n$text");
  }


  static SharedPreferences _sharedPreferences;

  static SharedPreferences get preferences {
    getSharedPreferences();
    return _sharedPreferences;
  }

  static getSharedPreferences() async
  {
    if(_sharedPreferences == null)
    {
         _sharedPreferences = await SharedPreferences.getInstance();
    }
  }
  
  static AppSettings _settings;

  static AppSettings get settings{
    loadSettings();
    return _settings;
  }
  
  static updateSettings()
  {
      print("******** updating settings ********");
      preferences.setString("settings",  jsonEncode(settings.toJson()));

  }

  static refreshSettings() 
  {
      loadSettings(refresh:true);
  }

  static loadSettings({bool refresh=false})
  {
      
      if(_settings == null || refresh)
      {
        print("Loading settings");
      var jsonString = preferences.getString("settings");
      try{
          _settings = AppSettings.fromJson(jsonDecode(jsonString));
      }
      catch(e)
      {
        _settings = AppSettings();
        print(e);
      }

       print("Settings $_settings");
      }
  }

  static String getCurrentTheme(BuildContext context)
  {
      return Provider.of<ThemeModel>(context, listen:false).currentThemeName;
  }
  static changeTheme(BuildContext context, String theme) async
  { 
     

      var themeStr = theme??"light";

      Provider.of<ThemeModel>(context, listen:false).changeTheme(theme);

      AppHelper.settings.theme = themeStr;
      updateSettings();
  }
  
}
