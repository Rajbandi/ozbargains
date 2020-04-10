import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/filterrule.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/viewmodels/thememodel.dart';
import 'package:ozbargain/views/about.dart';
import 'package:ozbargain/views/filterrule.dart';
import 'package:ozbargain/views/filters.dart';
import 'package:ozbargain/views/dealroute.dart';
import 'package:ozbargain/views/deviceinfo.dart';
import 'package:ozbargain/views/mydeals.dart';
import 'package:ozbargain/views/settings.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'home.dart';

class OzBargainApp extends StatefulWidget {

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

@override
  _OzBargainAppState createState() => new _OzBargainAppState();
}

class _OzBargainAppState extends State<OzBargainApp>
{
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;
 bool _initialized = false;

    @override
  initState() {

    _requestIOSPermissions();
    _initializeNotifications(); 
    _loadApp();
AppHelper.flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;
    if(!_initialized)

    {
    OzBargainApp.firebaseMessaging.requestNotificationPermissions();

     OzBargainApp.firebaseMessaging.configure(
     onMessage: (Map<String, dynamic> message) async {

       print('onMessage called: $message');
       await AppHelper.showNotificationMessage(message);
     },
     onResume: (Map<String, dynamic> message) async {
       print('onResume called: $message');
       await AppHelper.showNotificationMessage(message);
     },
     onLaunch: (Map<String, dynamic> message) async
     {
       print('onLaunch called: $message');
       await AppHelper.showNotificationMessage(message);
     },
   );


OzBargainApp.firebaseMessaging.getToken().then((token){
   print('FCM Token: $token');
 });

   _initialized = true;
    }
  }
  BuildContext context;

  _loadApp() async {
    var model = AppDataModel();
    await AppHelper.getSharedPreferences();
    model.loadSettings();
    // you can load here any other data or external data that your app might need
    if(this.context != null)
    {
        if(model.settings != null)
        {
          var theme = model.settings.theme;
          AppHelper.changeTheme(context, theme);
        }
    }
  }

  @override
  Widget build(BuildContext context) {

   
    this.context = context;

return MaterialApp(
      title: 'OZBargain Deals',
      theme: Provider.of<ThemeModel>(context).currentTheme,
      navigatorObservers: <NavigatorObserver>[OzBargainApp.observer],
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings){
        switch(settings.name)
        {
          case '/mydeals': return new DealRoute(builder: (_)=> new MyDealsPage(title: 'My Deals'));
          case '/alerts': return new DealRoute(builder: (_)=> new DealFiltersPage(title: 'Deal Filters'));
          case '/settings': return new DealRoute(builder: (_)=> new SettingsPage(title: 'Settings'));
          case '/viewalert': return new MaterialPageRoute<DealFilter>(builder: (_)=> new DealFilterView(settings.arguments));
          case '/deviceinfo': return new MaterialPageRoute(builder: (_)=> new DeviceInfoPage());
          case '/about': return new MaterialPageRoute(builder: (_)=> new AboutPage());
          default:
            return new DealRoute(builder: (_)=> new HomePage(title: 'OZBargain Deals'));
        }
      },
      // routes: {
        
      //   '/': (context)=> HomePage(title: 'OZBargain Deals'),
      //   '/alerts': (context)=> DealAlertsPage(title: 'Deal alerts'),
      //   '/settings': (context)=> SettingsPage()
      // },
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
