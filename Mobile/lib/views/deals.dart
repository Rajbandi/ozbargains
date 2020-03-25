import 'package:flutter/material.dart';
import 'package:ozbargain/api/dealapi.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/views/deal.dart';

import '../helpers/apphelper.dart';
import '../helpers/apphelper.dart';
import '../helpers/apphelper.dart';
import '../helpers/apphelper.dart';

class DealsView extends StatefulWidget {
  DealsView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DealsViewState createState() => _DealsViewState();
}

class _DealsViewState extends State<DealsView> {
  List<Deal> deals = new List<Deal>();
  @override
  void initState() {
    super.initState();
    _onRefresh();
  }
  TextStyle _nonTitleStyle, _primaryTitle,_highlightTitle;
  TextTheme _currentTextTheme;
  ThemeData _theme;
  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    _primaryTitle = _theme.primaryTextTheme.subtitle2.copyWith(color: _theme.primaryColor);
    _highlightTitle = _theme.accentTextTheme.subtitle2.copyWith(color: _theme.accentColor);

    _nonTitleStyle = Theme.of(context).textTheme.caption.merge(new TextStyle(color: Colors.grey));
    var model = new AppDataModel();
    var listView = ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Divider(height: 1);
        },
        itemBuilder: (BuildContext context, int index) {
          var deal = deals[index];
          return InkWell(
              onTap: () {
                _openDeal(deal);
              },
              child: _getDeal(deal));
        },
        itemCount: deals == null ? 0 : deals.length,
        scrollDirection: Axis.vertical);

    var refresh = RefreshIndicator(
      child: listView,
      onRefresh: () => _onRefresh(),
    );

    var layout = Container(
        padding: EdgeInsets.only(left: 2, right: 2),
        child: Stack(
          children: <Widget>[refresh],
        ));

    return layout;
  }

  _openDeal(Deal d) {
    var view = new DealView(title: "Deal", deal: d);
    Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => view));
  }

  Widget _getDeal(Deal d) {

    List<Widget> metaWidgets = new List<Widget>();
    metaWidgets.add(getNonTitle(d.meta.author));

    var dealDate = AppHelper.getDateFromUnix(d.meta.timestamp);
    var dealFormat = AppHelper.getLocalDateTime(dealDate);
    metaWidgets.add(getNonTitle(dealFormat));
    if(d.meta.upcomingDate>0)
    {
      var upcomDate = AppHelper.getDateFromUnix(d.meta.upcomingDate);
      var upcomDays = DateTime.now().difference(upcomDate).inDays;
      var upcomText = "From $upcomDate (in $upcomDays)";
      metaWidgets.add(getNonTitle(upcomText));
    }                     
    
    if(d.meta.expiredDate>0)
    {
      print(d.meta.expiredDate);
      var expiryDate = AppHelper.getDateFromUnix(d.meta.expiredDate);
      var expiryDiff = DateTime.now().difference(expiryDate);
      var expiryDays = expiryDiff.inDays;
      var expiryFormat = AppHelper.getLocalDateTime(expiryDate);
      var expiryText = "Expires $expiryFormat ";
      if(expiryDays>0)
      {
        expiryText += " (in ${expiryDiff.inDays} days)";
      }

      metaWidgets.add(getNonTitle(expiryText));
    }

    return new Container(
        padding: EdgeInsets.only(top: 2, bottom: 2, left: 2, right: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            getDealRow(Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 6, child: getTitle(d)),
                
              ],
            )),
            getDealRow(Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  
                  Expanded(flex:1, child:
                  Container(
                  padding: EdgeInsets.only(left:2,right:2),  
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      getVote( (d.vote.up??"0") + "+", Colors.green),
                      getVote( (d.vote.down??"0") + "-", Colors.red)
                    ],
                  ))),
                  Expanded(flex:5, child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: metaWidgets
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                 Container(padding:EdgeInsets.only(right:10),child:Icon(Icons.content_copy))
                 , Container(padding:EdgeInsets.only(right:10),child:Icon(Icons.open_in_new))
                  ],)
                ])),
            getDealRow(Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[],
            )),
            // getDealRow(Row(children: <Widget>[
            //   getTagsRow(d.tags)

            // ],))
            Align(child:getTagsRow(d.tags),alignment: Alignment.topLeft),
          ],
        ));
  }

  Widget getSearchRow() {
    return Container(
      padding: EdgeInsets.only(
        left: 2,
        right: 2,
      ),
      child: Expanded(
          child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: TextField(),
          ),
          Expanded(flex: 1, child: Text("Go"))
        ],
      )),
    );
  }

  Widget getTitle(Deal d)
  {
     List<InlineSpan> spans = new List<InlineSpan>();
    if(d.meta != null)
    {
       if(d.meta.upcomingDate != null && d.meta.upcomingDate>0)
       {
         spans.add(WidgetSpan(
           child: Container(child: Text("UPCOMING", style: _highlightTitle.copyWith(color:Colors.white),),
           padding: EdgeInsets.only(right:2, left:2),
           margin: EdgeInsets.only(right:2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: Colors.green
              ),
           )
         ));
       }
        if(d.meta.expiredDate != null && d.meta.expiredDate>0)
       {
         spans.add(WidgetSpan(
           child: Container(
             
             child: Text("EXPIRED",  style: _highlightTitle.copyWith(color:Colors.white)),
                 padding: EdgeInsets.only(right:2, left:2),
           margin: EdgeInsets.only(right:2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: Colors.red
              ),
             )
         ));
       }
    } 
    spans.add(TextSpan(text: d.title, style: _primaryTitle));

      return RichText(
        text:TextSpan(
          
        children:spans));
  }
  Widget getNonTitle(t) {
    return Text(t, style: _nonTitleStyle);
  }

  Widget getDealRow(child) {
    return Container(padding: EdgeInsets.only(top: 3, bottom: 3), child: child);
  }

  Widget getTagsRow(List<String> tags)
  {
    var row = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.spaceBetween,
      direction: Axis.horizontal,
      children: <Widget>[

      ],
    );

    tags.forEach((element) {
        var tagStyle = _nonTitleStyle.copyWith(color:Colors.white);
        row.children.add(Container(padding:EdgeInsets.only(left:2,right:2,top:2, bottom:2),
        margin: EdgeInsets.only(right:2, top:2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.0)
        ,color: Colors.brown),
        child:Text(element, style: tagStyle,)));
    });

    return row;
  }

  Widget getIcon(icon) {
    return  Container(alignment: Alignment.topCenter,
            child: icon,
        );
  }

  Widget getVote(v, Color c) {
    return  Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(1),
            margin: EdgeInsets.only(bottom: 1),
            child: Text(
              v,
              style: _nonTitleStyle.copyWith(color:Colors.white),
            ),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(2.0),
            ));
  }
  // ListTile _getDeal(Deal d) {
  //   return new ListTile(
  //     contentPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
  //     dense: true,
  //     leading: Container(child: Column(children: <Widget>[],),),
  //     title: Text(
  //       d.title,
  //       style: TextStyle(color: Theme.of(context).primaryColor),
  //     ),
  //     subtitle: Padding(
  //         child:
  //             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               Text(
  //                 d.meta.author,
  //               ),
  //               Text(
  //                 d.meta.date,
  //               )
  //             ],
  //           ),
  //           InkWell(
  //               onTap: () =>
  //                   {AppHelper.openUrl(context, d.title, d.snapshot.goto)},
  //               child: Icon(
  //                 Icons.open_in_browser,
  //                 color: Theme.of(context).accentColor,
  //               )),
  //         ]),
  //         padding: EdgeInsets.only(top: 2.0)),
  //   );
  // }

  Future<Null> _onRefresh() async {
    var now = DateTime.now();
    var dateToday = new DateTime(now.year, now.month, now.day);
    var dayStart = AppHelper.currentTimeInSeconds(dateToday);

    var q = new DealsQuery(
        dateFrom: dayStart.toString(),
        limit: "10",
        sort: "meta.timestamp,desc");

    var list = await AppDataModel().getDeals(q);
    setState(() {
      this.deals = list
          .skipWhile((value) => value.errors != null && value.errors.length > 0)
          .toList();
    });
    return null;
  }
}
