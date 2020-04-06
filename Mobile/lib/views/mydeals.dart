
import 'package:flutter/material.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/models/pagetypes.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/views/dealcommon.dart';

import 'bottommenu.dart';

class MyDealsPage extends StatefulWidget {
  final String title;
  MyDealsPage({Key key, this.title}) : super(key: key);

  @override
  _MyDealsPageState createState() => _MyDealsPageState();
}

class _MyDealsPageState extends State<MyDealsPage> {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

   List<Deal> deals = new List<Deal>();
   final ScrollController _dealsController = ScrollController();
  DealCommon _common;

  @override
  void initState() {

    _onRefresh();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
        _common = DealCommon(context, _scaffoldKey);

    return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        title: Text("My Deals"),
        actions: <Widget>[

      ],),
      body: 
      deals.length==0?
      Align(alignment: Alignment.center, child: Text("No deals"),):
      ListView.separated(
        controller: _dealsController,
         scrollDirection: Axis.vertical,
        separatorBuilder: (context, index)  {
           return Divider(height: 1);
        },
        itemBuilder: (BuildContext context, int index) {
          var deal = deals[index];
          return InkWell(
              onTap: () {
              },
              child: _getDeal(deal));
        },
        itemCount: deals == null ? 0 : deals.length,

        ),

      bottomNavigationBar: BottomMenuView(pageType:PageType.MyDeals),
      ),
    );
  }

  bool _isLoading = false;

  Future<Null> _onRefresh() {
    setState(() {
      _isLoading = true;
    });
    this.deals = AppDataModel().myDeals;
      print("My deals ${this.deals.length}");
      _isLoading = false;
    //_scrollToTop();
    if(this.deals.length>5)
    {
      _scrollToTop();
    }
    return null;
  }


  _scrollToTop() {
    _dealsController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }


  Widget _getDeal(Deal d) {
    return new Container(
        padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _common.getDealRow(Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 6, child: _common.getTitle(d)),
              ],
            )),
            _common.getDealRow(_common.getMeta(d)),
            _common.getDealRow(Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Opacity(
                        opacity: 0.85,
                        child: Container(
                            child: Text(d.content ?? ""),
                            padding: EdgeInsets.only(left: 2))))
              ],
            )),
            // getDealRow(Row(children: <Widget>[
            //   getTagsRow(d.tags)

            // ],))
            Align(
                child: _common.getTagsRow(d.tags),
                alignment: Alignment.topLeft),
          ],
        ));
  }

}