import 'dart:async';
import 'dart:convert' as c;

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:ozbargain/views/app.dart';

void main() {
  final DataHandler handler = (_) async {
 
    final response = {
    };
    return Future.value(c.jsonEncode(response));
  };
  // Enable integration testing with the Flutter Driver extension.
  // See https://flutter.io/testing/ for more info.
 // enableFlutterDriverExtension(handler: handler);
  WidgetsApp.debugAllowBannerOverride = false; // remove debug banner
  runApp(OzBargainApp());
}