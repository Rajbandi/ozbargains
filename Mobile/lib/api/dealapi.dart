import 'dart:async';

import 'package:logger/logger.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:dio/dio.dart';


class DealsQuery{

  String dateFrom;
  String dateEnd;

  String dealFrom;
  String dealTo;

  String limit;
  String sort;

  String startRow;
  String endRow;

  DealsQuery({this.dateFrom, this.dateEnd, this.dealFrom, this.dealTo, this.limit, this.sort, this.startRow, this.endRow});

  String toRequestParams()
  {
    String query = "";

    var params = new List<String>();
    if(dateFrom != null)
    {
        params.add("dateFrom="+dateFrom);
    }
    if(dateEnd != null)
    {
        params.add("dateEnd="+dateEnd);
    }

    if(dealFrom != null)
    {
      params.add("dealFrom="+dealFrom);
    }

    if(dealTo != null)
    {
      params.add("dealTo="+dealTo);
    }

    if(limit != null)
    {
      params.add("limit="+limit);
    }

    if(sort != null)
    {
      params.add("sort="+sort);
    }

    if(startRow != null)
    {
      params.add("startRow="+startRow);
    }

    if(endRow != null)
    {
      params.add("endRow="+endRow);
    }
    if(params.length>0)
    {
        query="?"+params.join("&");
    }

    return query;
  } 
}

class DealsApi
{
  static final DealsApi _api = new DealsApi._internal();
  Dio _dio;
  String _baseUrl;
  Logger _log = Logger();

  factory DealsApi(String url) {
    _api._baseUrl = url;
    return _api;
  }
 
  DealsApi._internal()
  {
     //_baseUrl = "http://192.168.1.189";
   
    _dio = new Dio();
  }

   Future<Deals> getDeals(DealsQuery q) async {

    Deals deals = new Deals();

    try {

       var p = '';
       if(q !=null  )
       {
         var params = q.toRequestParams();
         if(params != null && params.length>0)
         {
           p = params;
         }
       }

      _log.d("Fetching deals..");
      _log.d("$_baseUrl/api/deals");
      _log.d(p);
      var response = await _dio.get("$_baseUrl/api/deals"+p);
      _log.d("Response received");
      var data = response.data;
      var obj = Deals.fromJson(data);
      if (obj != null) {
        deals = obj;
      }

      _log.d("Received deals ");
    } catch (e, st) {
      _log.d(e);
      deals.success = false;
      deals.errorCode = "101";
      deals.errorMessage = e.toString();
    }

    return deals;
  }


}