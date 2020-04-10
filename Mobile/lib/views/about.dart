

import 'package:flutter/material.dart';
import 'package:ozbargain/helpers/apphelper.dart';

class AboutPage extends StatefulWidget {
  
  
  AboutPage({Key key}) : super(key: key);

  @override
  
  
  _AboutPageState createState() => _AboutPageState();
}



class _AboutPageState extends State<AboutPage> {
  
  @override
  Widget build(BuildContext context) {
    var url = "http://www.omkaars.dev";
    return SafeArea(child: Scaffold(
      appBar: AppBar(title:  Text("About"),),
      body: 
      Align(alignment: Alignment.center, child:
      Container(
        height:75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
         
          Text("Omkaars", style:Theme.of(context).textTheme.headline6),
          InkWell(child: Text(url, style:Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.blue)), onTap: () => {
              AppHelper.openUrl(context, "Omkaars", url)
          })
        ],)
      )),
    ),);

  }
}