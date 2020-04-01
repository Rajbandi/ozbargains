import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ozbargain/views/dealcommon.dart';

import '../helpers/apphelper.dart';
import '../models/deal.dart';

class DealView extends StatefulWidget {
  DealView({Key key, this.title, this.deal}) : super(key: key);

  final String title;
  final Deal deal;

  @override
  _DealViewState createState() => _DealViewState();
}

class _DealViewState extends State<DealView> {
  Deal deal;

  @override
  void initState() {
    super.initState();
  }
 final _scaffoldKey = GlobalKey<ScaffoldState>();
DealCommon _common;
@override
  Widget build(BuildContext context) {

    _common = DealCommon(context, _scaffoldKey);
    var deal = widget.deal;
   
    return SafeArea(child:Scaffold(
         key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(deal.title??widget.title),
        ),
        body:
            ListView(
              padding: EdgeInsets.symmetric(horizontal:5,vertical:5),
              children: <Widget>[
              Padding( padding: EdgeInsets.only(top:5,bottom: 10),
              child:_common.getTitle(deal)),
              Container(padding:EdgeInsets.only(bottom: 5),
              child: _common.getMeta(deal, authorImage: true, gotoImage: true),
              ),
            
              _common.getTagsRow(deal.tags),
             Opacity(opacity:0.85,child: Html(data: widget.deal.description,
              onLinkTap: (url) => {
                AppHelper.openUrl(context, "", url)
              },))
              
              ])));

  }

}
