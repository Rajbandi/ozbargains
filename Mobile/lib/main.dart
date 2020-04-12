import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:ozbargain/viewmodels/thememodel.dart';
import 'package:ozbargain/views/app.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(
      providers: [
          ChangeNotifierProvider(create: (context)=> ThemeModel()),
          Provider<FirebaseAnalytics>.value(value: OzBargainApp.analytics),
          Provider<FirebaseAnalyticsObserver>.value(value: OzBargainApp.observer),
        ],
      child: OzBargainApp()));

