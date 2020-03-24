import 'package:flutter/material.dart';
import 'package:ozbargain/api/dealapi.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/views/deal.dart';

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
  TextStyle _nonTitleStyle;
  @override
  Widget build(BuildContext context) {

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
    return new Container(
        padding: EdgeInsets.only(top: 2, bottom: 2, left: 2, right: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            getDealRow(Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 6, child: Text(d.title)),
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
                      getVote(context, d.vote.up + "+", Colors.green),
                      getVote(context, d.vote.down + "-", Colors.red)
                    ],
                  ))),
                  Expanded(flex:5, child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      getNonTitle(d.meta.author),
                      getNonTitle(d.meta.date)
                    ],
                  )),
                  
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
        var tagStyle = _nonTitleStyle.copyWith(backgroundColor: Colors.lightGreenAccent);
        row.children.add(Padding(padding:EdgeInsets.only(left:2,right:2,top:2, bottom:2),child:Text(element, style: tagStyle,)));
    });

    return row;
  }
  Widget getVote(context,v, Color c) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
      var textStyle = textTheme.caption.merge(TextStyle(color: Colors.white));
    return  Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(1),
            margin: EdgeInsets.only(bottom: 1),
            child: Text(
              v,
              style: textStyle,
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
