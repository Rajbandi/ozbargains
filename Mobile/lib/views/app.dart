import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/viewmodels/thememodel.dart';
import 'package:provider/provider.dart';

import 'home.dart';

class OzBargainApp extends StatefulWidget {

@override
  _OzBargainAppState createState() => new _OzBargainAppState();
}

class _OzBargainAppState extends State<OzBargainApp>
{
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;
 
    @override
  initState() {
    _requestIOSPermissions();
    _initializeNotifications(); 
    AppHelper.flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;
  }
  BuildContext context;
  @override
  Widget build(BuildContext context) {
    this.context = context;
    return MaterialApp(
      title: 'OZBargain Deals',
      theme: Provider.of<ThemeModel>(context).currentTheme,
      home: HomePage(title: 'OZBargain Deals'),
    );
  }


  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _initializeNotifications()
  {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
var initializationSettingsIOS = IOSInitializationSettings(
    onDidReceiveLocalNotification: onDidReceiveLocalNotification);
var initializationSettings = InitializationSettings(
    initializationSettingsAndroid, initializationSettingsIOS);
flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async
  {
    showDialog(context: context, builder: (_)=> 
    new AlertDialog(title: const Text("Here is your payload"), 
    content: Text("Payload $payload")));
  }

   Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: title != null ? Text(title) : null,
        content: body != null ? Text(body) : null,
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              //Navigator.of(context, rootNavigator: true).pop();
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => SecondScreen(payload),
              //   ),
              // );
            },
          )
        ],
      ),
    );
  }

  
}
