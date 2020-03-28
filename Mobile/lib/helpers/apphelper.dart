
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ozbargain/views/dealwebview.dart';
import 'package:intl/intl.dart';

class AppHelper{
static FlutterLocalNotificationsPlugin  flutterLocalNotificationsPlugin;
  static int currentTimeInSeconds(DateTime d) {
  
    var ms = d.millisecondsSinceEpoch;
    return (ms / 1000).round();

  
}

  static openUrl(context, title, url)
  {
    var view = new DealWebView(title: title, url: url,);
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => view));
  }

  static getDateFromUnix(int timeStamp)
  {
    return DateTime.fromMillisecondsSinceEpoch(timeStamp*1000);
  }

  static getLocalDateTime(DateTime date)
  {
      DateFormat format = new DateFormat("dd-MMM-yyyy hh:mm");
      var dt = format.format(date);
      return dt;
  }
  
  static  Future showNotificationWithoutSound() async {
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
}