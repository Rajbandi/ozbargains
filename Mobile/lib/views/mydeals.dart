import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/models/pagetypes.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/views/dealcommon.dart';

import 'app.dart';
import 'bottommenu.dart';

class MyDealsPage extends StatefulWidget {
  final String title;
  MyDealsPage({Key key, this.title}) : super(key: key) {
    OzBargainApp.logCurrentPage("MyDeals");
  }

  @override
  _MyDealsPageState createState() => _MyDealsPageState();
}

class _MyDealsPageState extends State<MyDealsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Deal> deals = new List<Deal>();
  final ScrollController _dealsController =
      ScrollController(initialScrollOffset: 0.0);
  DealCommon _common;
  AppDataModel _model = AppDataModel();
  ThemeData _theme;
  StreamSubscription _dealSub;
  @override
  void initState() {
    super.initState();
    _dealSub = _model.dealStream.stream.listen((event) {
      _onRefresh();
    });
    _onRefresh();
  }

  @override
  void dispose() {
    super.dispose();
    if (_dealSub != null) {
      _dealSub.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    _common = DealCommon(context, _scaffoldKey);
    var listView = ListView.separated(
      controller: _dealsController,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) {
        return Divider(height: 1);
      },
      itemBuilder: (BuildContext context, int index) {
        var deal = deals[index];
        return InkWell(onTap: () {}, child: _getDeal(deal));
      },
      itemCount: deals == null ? 0 : deals.length,
    );
    var listNotification = NotificationListener<ScrollUpdateNotification>(
      child: listView,
      onNotification: (notification) {
        setState(() {
          _floatButtonVisible = notification.metrics.pixels > 300;
        });
        return true;
      },
    );
    var listWidget = deals.length == 0
        ? Align(
            alignment: Alignment.center,
            child: Container(child:Text("No favourite or filtered deals. Add some favourite deals or filter rules.", style:_theme.textTheme.subtitle1),
            padding: EdgeInsets.all(10) ,),
          )
        : listNotification;
    var mainWidget = Column(
      children: <Widget>[
        Expanded(
          child: getFilterHeaderRow(),
        ),
        Expanded(flex: 15, child: listWidget)
      ],
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Deals"),
          actions: <Widget>[
            Container(child:Row(children: <Widget>[
               InkWell(
                  child: Container(
                    child: Icon(Icons.refresh),
                    padding: EdgeInsets.all(5),
                  ),
                  onTap: () => {_onRefresh()}),
              ],),
              margin: EdgeInsets.only(right: 5),
            )
          ],
        ),
        body: mainWidget,
        bottomNavigationBar: BottomMenuView(pageType: PageType.MyDeals),
        floatingActionButton: _getFloatButton(),
      ),
    );
  }

  Future<Null> _onRefresh() {
    setState(() {});

    _model.refreshMyDeals();

    setState(() {
      this.deals = _model.myDeals;
      print("My deals ${this.deals.length}");
    });

    return null;
  }

  bool _floatButtonVisible;
  _getFloatButton() {
    var _floatButton = FloatingActionButton(
        child: Icon(Icons.vertical_align_top, color: Colors.white),
        backgroundColor: _theme.primaryColor,
        onPressed: () => {_scrollToTop()});
    return Visibility(
        visible: _floatButtonVisible ?? false, child: _floatButton);
  }

  _scrollToTop() {
    if (_dealsController.hasClients) {
      _dealsController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
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
            _common.getDealRow(_common.getMeta(d, showFilters: true)),
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

  Widget getFilterHeaderRow() {
    var widgets = new List<Widget>();
    var alertFilters = _model.settings.alertFilters;
    var filterNames = new List<String>();
    var anyFavourites = _model.deals.any((d) => d.starred);
    if (anyFavourites) {
      filterNames.add("Favourites");
    }
    for (var alertFilter in alertFilters) {
      filterNames.add(alertFilter.name);
    }
    widgets.add(getFilterHeaderItem("All"));

    for (var filterName in filterNames) {
      widgets.add(getFilterHeaderItem(filterName));
    }

    var container = Container(
        color: _theme.accentColor,
        child: ListView(

            // This next line does the trick.
            scrollDirection: Axis.horizontal,
            children: widgets));
    return container;
  }

  String _filter = "All";
  Widget getFilterHeaderItem(String filter) {
    var text = filter;

    var color = _theme.accentColor;
    var textStyle = _theme.textTheme.bodyText1;
    if (_filter == filter) {
      color = _theme.primaryColor;
      textStyle = textStyle.copyWith(color: Colors.white);
    }

    var action = () => {_changeFilter(filter)};

    return InkWell(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Text(text, style: textStyle),
        decoration: BoxDecoration(
          color: color,
        ),
      ),
      onTap: action,
    );
  }

  _changeFilter(String filter) {
    setState(() {
      _filter = filter;
      print("Filtering $filter");
      if (filter == "All") {
        this.deals = _model.myDeals;
      } else {
        this.deals = _model.myDeals.where((d) {
          return d.meta.alertName.split(",").any((f) => f == filter);
        }).toList();
      }
    });
  }
}
