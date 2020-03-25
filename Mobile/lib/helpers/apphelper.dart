
import 'package:flutter/material.dart';
import 'package:ozbargain/views/dealwebview.dart';
import 'package:intl/intl.dart';

class AppHelper{

  static int currentTimeInSeconds(DateTime d) {
  
    var ms = d.millisecondsSinceEpoch;
    return (ms / 1000).round();

  
}

  static openUrl(context, title, url)
  {
    var view = new DealWebView(title: title, url: url,);
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => view));
  }

  static getDateFromUnix(int timeStamp)
  {
    return DateTime.fromMillisecondsSinceEpoch(timeStamp*1000);
  }

  static getLocalDateTime(DateTime date)
  {
      DateFormat format = new DateFormat("dd-MMM-yyyy hh:mm");
      var dt = format.format(date);
      return dt;
  }

}