import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';
import 'package:ozbargain/models/filterrule.dart';
import 'package:ozbargain/models/appsettings.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/viewmodels/thememodel.dart';
import 'package:ozbargain/views/dealwebview.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppHelper {

  AppHelper() {
    AppDataModel().refreshSettings();
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
      if (AppDataModel().settings.openBrowser) {

      var result = await launch(url);
      if(!result)
      {
        print(" Unabled open link");
      }

      } else {
        var view = new DealWebView(
          title: title,
          url: url,
        );
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => view));
      }
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

  static String getCurrentTheme(BuildContext context) {
    return Provider.of<ThemeModel>(context, listen: false).currentThemeName;
  }

  static changeTheme(BuildContext context, String theme) async {
    var themeStr = theme ?? "light";

    Provider.of<ThemeModel>(context, listen: false).changeTheme(theme);
    var model = AppDataModel();
    model.settings.theme = themeStr;
    model.updateSettings();
  }

  static Future showNotification(String title, String message, {bool sound=true}) async
  {
     var model = AppDataModel();
      if(!model.settings.showNotifications)
      {
        return;
      }
      var android = AndroidNotificationDetails("1234","Messages","General messages", playSound: sound, importance: Importance.Max, priority: Priority.High);

      var iOS = IOSNotificationDetails(presentSound: sound);
      
      var details = new NotificationDetails(android, iOS);
      
      await flutterLocalNotificationsPlugin.show(0, title, message, details);
  }

  static Future showNotificationMessage(Map<String, dynamic> message) async
  {
      var notification = message['notification'];
      if(notification != null)
      {
          var title = notification['title'];
          var body = notification['body'];
          if(title != null && body != null)
          {
              print("Showing message $title $body");
              await showNotification(title, body);
          }
      }
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

  static getSharedPreferences() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  }

  
}
