import 'dart:async';

import 'package:logger/logger.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:dio/dio.dart';



class DealsApi
{
  static final DealsApi _api = new DealsApi._internal();
  Dio _dio;
  String _baseUrl;
  Logger _log = Logger();
  factory DealsApi() {
    return _api;
  }

  DealsApi._internal()
  {
     _baseUrl = "http://192.168.1.189";

    _dio = new Dio();
  }

   Future<Deals> getDeals() async {

    Deals deals = new Deals();

    try {

      _log.d("Fetching deals..");
      _log.d("$_baseUrl/api/deals");
      var response = await _dio.get("$_baseUrl/api/deals");
      _log.d("Response received");
      var data = response.data;
      var obj = Deals.fromJson(data);
      if (obj != null) {
        deals = obj;
      }

      _log.d("Received deals ");
    } catch (e, st) {
      _log.d(e);
      _log.d(st);
      deals.success = false;
      deals.errorCode = "101";
      deals.errorMessage = e.toString();
    }

    return deals;
  }

}