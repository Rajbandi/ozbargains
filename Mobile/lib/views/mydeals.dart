
import 'package:flutter/material.dart';
import 'package:ozbargain/models/pagetypes.dart';

import 'bottommenu.dart';

class MyDealsPage extends StatefulWidget {
  final String title;
  MyDealsPage({Key key, this.title}) : super(key: key);

  @override
  _MyDealsPageState createState() => _MyDealsPageState();
}

class _MyDealsPageState extends State<MyDealsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        title: Text("My Deals"),
        actions: <Widget>[

      ],),
      body: Text("MyDeals"),
      bottomNavigationBar: BottomMenuView(pageType:PageType.MyDeals),
      ),
    );
  }
}