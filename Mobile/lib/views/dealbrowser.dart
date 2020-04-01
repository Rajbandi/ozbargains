import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DealBrowser extends InAppBrowser {
  @override
  Future onBrowserCreated() async {
    // print("\n\nBrowser Created!\n\n");
  }

  @override
  Future onLoadStart(String url) async {
    // print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    // print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
    // print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(int progress) {
    // print("Progress: $progress");
  }

  @override
  void onExit() {
    // print("\n\nBrowser closed!\n\n");
  }

  

  @override
  void onLoadResource(LoadedResource response) {
    // print("Started at: " +
    //     response.startTime.toString() +
    //     "ms ---> duration: " +
    //     response.duration.toString() +
    //     "ms " +
    //     response.url);
  }

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {
  //   print("""
  //   console output:
  //     message: ${consoleMessage.message}
  //     messageLevel: ${consoleMessage.messageLevel.toValue()}
  //  """);
  }
}