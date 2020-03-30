

import 'dart:io';

import 'package:dio/dio.dart';
import '../dart/dealsocket.dart';

void main() async
{
    log("Creating socket");
    var socket = DealSocket("https://ozbargains.omkaars.dev");
    log("Opening socket");
    await socket.open();


 socket.controller.stream.listen((message) {
    print('received a message from controller ${message.length}');
  }, onError: (error, StackTrace stackTrace) {
    print('Error received from controller ${error} ${stackTrace}');
  }, onDone: () {
    print("controller is closed");
  });

    ProcessSignal.sigint.watch().listen((ProcessSignal signal) {
      log("Closing socket");
      socket.close();
      exit(0);
    });
}

void log(msg)
{
  print(msg);
}

Future<String> getUrl(String url) async
{
   var finalUrl = await Dio().get(url);
   if(finalUrl.redirects != null && finalUrl.redirects.length>0)
   {
     return finalUrl.redirects[0].location.toString();
   }
   return finalUrl.request.uri.toString();
}