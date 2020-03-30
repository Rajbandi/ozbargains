import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class DealSocket extends Object 
{
  static final DealSocket _sockets = new DealSocket._internal();

  String _url;
  String _socketUrl;

  StreamController _controller;
  StreamController get controller => _controller;
  IO.Socket _socket;

  IO.Socket get socket => _socket;

  factory DealSocket(String url) {
    _sockets._url = url;
    return _sockets;
  }

  DealSocket._internal() {
    _controller = StreamController.broadcast();
  }

  void open() async {
    try {
      if (_socketUrl == null || _socketUrl.length <= 0) {
        _socketUrl = await getUrl(_url);
      }
      log("Connecting to socket url $_socketUrl");
      _socket = IO.io(_socketUrl, <String, dynamic>{
        'transports': ['websocket'],
      });
      _socket.on('connect', (_) {
        log("socket connected successfully");
      });

      _socket.on('message', (data) {
        log("Received message from socket server $data");
      });

      _socket.on('deals', (data) {
        var deals = [];
        try {
          deals = jsonDecode(data);
        } catch (e) {
          log("Error while decoding json $e");
        }
        log("Sending data to stream ${deals.length}");
        _controller.sink.add(deals);

        log("Received socket deals from socket server ${deals.length}");
      });

      _socket.on('error', (error) {
        log("An error occurred from socket $error");
      });
    } catch (e) {
      log('An error occurred while opening socket connection $e');
    }
  }

  void log(msg) {
    print(msg);
  }

  Future<String> getUrl(String url) async {
    var finalUrl = await Dio().get(url);
    if (finalUrl.redirects != null && finalUrl.redirects.length > 0) {
      return finalUrl.redirects[0].location.toString();
    }
    return finalUrl.request.uri.toString();
  }

  void close() async {
    try {
      log("Disconnecting socket ");
      if (_socket != null) {
        _socket.disconnect();
        _socket.close();
        log("Done...");
      }
    } catch (e) {
      log('An error occurred while closing socket connection $e');
    }
  }
   
}
