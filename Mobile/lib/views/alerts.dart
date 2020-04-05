
import 'package:flutter/material.dart';
import 'package:ozbargain/models/pagetypes.dart';
import 'package:ozbargain/views/bottommenu.dart';

class DealAlertsPage extends StatefulWidget
{

   DealAlertsPage({Key key, this.title}) : super(key: key);
   final String title;
 @override
  _DealsAlertsPageState createState() => _DealsAlertsPageState();
    
}

class _DealsAlertsPageState extends State<DealAlertsPage>
{
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title??"")
      ),
      body: Text("Alerts"),
      bottomNavigationBar: BottomMenuView(pageType:PageType.Alerts),
      
      ),
      
      );
  }

}