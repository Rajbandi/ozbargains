

import 'package:flutter/material.dart';
import 'package:ozbargain/views/bottommenu.dart';
import 'package:ozbargain/views/deals.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 

  @override
  Widget build(BuildContext context) {
    return DealsView(title: "OZBargain Deals",);
  }
}
