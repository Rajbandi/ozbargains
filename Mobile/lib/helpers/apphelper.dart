
import 'package:flutter/material.dart';
import 'package:ozbargain/views/dealwebview.dart';

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

}