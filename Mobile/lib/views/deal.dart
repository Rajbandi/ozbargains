import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

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

@override
  Widget build(BuildContext context) {
    var deal = widget.deal;
    var primaryColor = Theme.of(context).primaryColor;
    var titleStyle = Theme.of(context).textTheme.headline6.merge(TextStyle(color: primaryColor));
    
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body:
            ListView(
              padding: EdgeInsets.symmetric(horizontal:5,vertical:5),
              children: <Widget>[
              Padding( padding: EdgeInsets.only(top:5,bottom: 5),
              child:Text(deal.title, style:titleStyle)),
              Container(padding: EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                    Image.network(deal.meta.image,width: 50,height:50),
                    Text(deal.meta.author),
                    Text(deal.meta.date)  
                  ],),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                    InkWell(child:
                                      Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[

                      Image.network(deal.snapshot.image,width: 75,height:75),
                      Text("Goto", style: TextStyle(fontWeight: FontWeight.bold),)
                    ]),
                      onTap: () => {
                        AppHelper.openUrl(context, "", deal.snapshot.goto)
                      },
                    )
                  ],)
              ],),),
              
              Html(data: widget.deal.description,
              onLinkTap: (url) => {
                AppHelper.openUrl(context, "", url)
              },)
              
              ]));

  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       appBar: AppBar(
  //         title: Text(widget.title),
  //       ),
  //       body:
  //           ListView(children: <Widget>[
  //             Html(data: widget.deal.description,
  //             onLinkTap: (url) => {
  //               AppHelper.openUrl(context, "", url)
  //             },)
              
  //             ]));
  // }
}
