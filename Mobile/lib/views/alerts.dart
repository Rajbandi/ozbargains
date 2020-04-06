
import 'package:flutter/material.dart';
import 'package:ozbargain/models/alertrule.dart';
import 'package:ozbargain/models/pagetypes.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
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
  ThemeData _theme;
  AppDataModel model = AppDataModel();
  BuildContext context;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
     this.context = context;
    _theme = Theme.of(context);
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title??"")
      ),
      body: model.rules.length == 0 ?
      Align(alignment: Alignment.center,
      child: Text("No rules found. Press '+' to add new one.")):
      ListView.separated(
           itemCount: model.rules.length,
           separatorBuilder: (context, index){
             return Divider(height:1);
           },
           itemBuilder: (context, index){
             var rule = model.rules[index];
             return _getRuleView(rule);
           },
          ),
              floatingActionButton: _getFloatButton(),
      bottomNavigationBar: BottomMenuView(pageType:PageType.Alerts),
      
      ),
      
      );
  }

  _getRuleView(AlertRule rule)
  {
    return Container(child: Row(children: <Widget>[
      Text(rule.name)

    ],),);
  }
   _getFloatButton() {
    var _floatButton = FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: _theme.primaryColor,
        onPressed: () => {

          Navigator.pushNamed(context, "/viewalert", arguments:AlertRule())

        });
        return _floatButton;
  }



}