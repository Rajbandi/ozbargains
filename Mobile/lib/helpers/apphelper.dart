import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';
import 'package:ozbargain/models/analyticsevent.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/viewmodels/thememodel.dart';
import 'package:ozbargain/views/app.dart';
import 'package:ozbargain/views/dealwebview.dart';
import 'package:package_info/package_info.dart';
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
    try {
      if (isUrlValid(url)) {
        if (AppDataModel().settings.openBrowser) {
          var result = await launch(url);
          if (!result) {
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
    } catch (e) {
      print(e);
       OzBargainApp.logEvent(AnalyticsEventType.Error, { 'error': e, 'class':'AppHelper','method':'openUrl'});

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

  static Future showNotification(String title, String message,
      {bool sound = true}) async {
    var model = AppDataModel();
    if (!model.settings.showNotifications) {
      return;
    }
    var android = AndroidNotificationDetails(
        "1234", "Messages", "General messages",
        playSound: sound, importance: Importance.Max, priority: Priority.High);

    var iOS = IOSNotificationDetails(presentSound: sound);

    var details = new NotificationDetails(android, iOS);

    await flutterLocalNotificationsPlugin.show(0, title, message, details);
  }

  static Future showNotificationMessage(Map<String, dynamic> message) async {
    var notification = message['notification'];
    if (notification != null) {
      var title = notification['title'];
      var body = notification['body'];
      if (title != null && body != null) {
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

  static bool isInternetAvailable;

  static GlobalKey<ScaffoldState> scaffoldKey;
  static void showSnackError(message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message,
          style: Theme.of(scaffoldKey.currentContext)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.white)),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.red.shade800,
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

  static showAlertDialog(BuildContext context, String title, Widget message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: message,
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        "Ok",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ))
            ],
          );
        });
  }

  static showAlertMessage(BuildContext context,
      {String title, String message, Widget content, List<Widget> actions}) {
    var actionWidgets = actions;
    if (actionWidgets == null) {
      actionWidgets = <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(10),
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ];
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title ?? ""),
            content: content != null ? content : Text(message ?? ""),
            actions: actionWidgets,
          );
        });
  }

  static Future<bool> getInternetStatus() async
  {
      var isAvailable = false;
      var connectivity = await Connectivity().checkConnectivity();
      if(connectivity != null)
      {
        if(connectivity == ConnectivityResult.mobile)
        {
          isAvailable = true;
        }
        else
        if(connectivity == ConnectivityResult.wifi)
        {
          isAvailable = true;
        }
      }

      return isAvailable;
  }

}
