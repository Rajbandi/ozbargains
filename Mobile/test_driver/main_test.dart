// This is a basic Flutter Driver test for the application. A Flutter Driver
// test is an end-to-end test that "drives" your application from another
// process or even from another computer. If you are familiar with
// Selenium/WebDriver for web, Espresso for Android or UI Automation for iOS,
// this is simply Flutter's version of that.

import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart' as ftest;
import 'package:screenshots/screenshots.dart';
import 'package:test/test.dart';
import 'dart:convert' as c;

void main() {
  group('end-to-end test', () {
    FlutterDriver driver;
    Map localizations;
    final config = Config();

    setUpAll(() async {
      // Connect to a running Flutter application instance.
      driver = await FlutterDriver.connect();
   
     
    });

    tearDownAll(() async {
      if (driver != null) await driver.close();
    });

    test('Load', () async {

      
      // take screenshot before number is incremented
      await screenshot(driver, config, '0');

      // increase timeout from 30 seconds for testing
      // on slow running emulators in cloud
    }, timeout: Timeout(Duration(seconds: 120)));
  });
}