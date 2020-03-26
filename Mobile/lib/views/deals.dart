import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ozbargain/api/dealapi.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/models/dealfilter.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/views/bottommenu.dart';
import 'package:ozbargain/views/deal.dart';

import '../helpers/apphelper.dart';

class DealsView extends StatefulWidget {
  DealsView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DealsViewState createState() => _DealsViewState();
}

class _DealsViewState extends State<DealsView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Deal> deals = new List<Deal>();
  bool _searchVisible;
  
  DealFilter _filter;
  @override
  void initState() {
    super.initState();
    _floatButtonVisible = false;
    _filter = DealFilter.Today;
    _searchVisible = false;
    _onRefresh();
  }

  TextStyle _nonTitleStyle, _primaryTitle, _highlightTitle;
  TextTheme _currentTextTheme;
  ThemeData _theme;

  final ScrollController _dealsController = ScrollController();
  BuildContext _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
    _theme = Theme.of(context);

    _primaryTitle =
        _theme.primaryTextTheme.subtitle2.copyWith(color: _theme.primaryColor);
    _highlightTitle =
        _theme.accentTextTheme.subtitle2.copyWith(color: _theme.accentColor);

    _nonTitleStyle = Theme.of(context)
        .textTheme
        .caption
        .merge(new TextStyle(color: Colors.grey));
    var model = new AppDataModel();
    var listView = ListView.separated(
        controller: _dealsController,
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
       
      child: Stack(
        children: <Widget>[

        listView,
         Visibility(visible: (_isLoading??false),child:new Align(
              child: CircularProgressIndicator(),
              alignment: FractionalOffset.center,
            ))
      ]),
      onRefresh: () => _onRefresh(),
    );
    var listNotification = NotificationListener<ScrollUpdateNotification>(
      child: refresh,
      onNotification: (notification) {
        setState(() {
          _floatButtonVisible = notification.metrics.pixels > 300;
        });
      },
    );

    var layout = new GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (TapDownDetails t) {
          try {
            FocusScope.of(context).unfocus();
          } catch (e) {}
        },
        child: Container(
            child: Column(children: <Widget>[
          Visibility(visible:_searchVisible??false, child:Expanded(child: getFilterSearchRow())),
          Expanded(child: getFilterHeaderRow()),
          Expanded(flex: 15, child: listNotification)
        ])));
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(children: <Widget>[
          Expanded(flex:2, child:Text(widget.title ?? "")),
          Expanded(child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
            InkWell(child:Icon(Icons.refresh), onTap: () => { _onRefresh(refresh: true)},),
            InkWell(child:Icon(Icons.search), onTap: () => { _showSearchRow() },),
            InkWell(child:Icon(Icons.filter_list), onTap: () => {}),
          ],),)
          ],) 
        ),
        body: layout,
        floatingActionButton: _getFloatButton(),
        bottomNavigationBar: BottomMenuView());
  }

  bool _floatButtonVisible;
  _getFloatButton() {
    var _floatButton = FloatingActionButton(
        child: Icon(Icons.vertical_align_top),
        onPressed: () => {
              _dealsController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              )
            });
    return Visibility(
        visible: _floatButtonVisible ?? false, child: _floatButton);
  }

  _openDeal(Deal d) {
    var view = new DealView(title: "Deal", deal: d);
    Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => view));
  }

  showSnackMessage(message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  copyToClipboard(text) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackMessage("Copied $text");
  }

  Widget _getDeal(Deal d) {
    List<Widget> metaWidgets = new List<Widget>();
    metaWidgets.add(getNonTitle(d.meta.author));

    var dealDate = AppHelper.getDateFromUnix(d.meta.timestamp ?? 0);
    var dealFormat = AppHelper.getLocalDateTime(dealDate);
    metaWidgets.add(getNonTitle(dealFormat));
    if (d.meta.upcomingDate > 0) {
      var upcomDate = AppHelper.getDateFromUnix(d.meta.upcomingDate ?? 0);
      var upcomDiff = DateTime.now().difference(upcomDate);
      var upcomDays = upcomDiff.inDays;
      var upcomFormat = AppHelper.getLocalDateTime(upcomDate);
      var upcomText = "";
      if (upcomDiff.isNegative) {
        upcomText = "Starts on $upcomFormat (in ${upcomDays * -1} days)";
      } else {
        upcomText = "From $upcomFormat ($upcomDays days ago)";
      }
      metaWidgets.add(getNonTitle(upcomText));
    }

    if (d.meta.expiredDate > 0) {
      var expiryDate = AppHelper.getDateFromUnix(d.meta.expiredDate);
      var expiryDiff = DateTime.now().difference(expiryDate);
      var expiryDays = expiryDiff.inDays;
      var expiryFormat = AppHelper.getLocalDateTime(expiryDate);
      var expiryText = "";

      if (!expiryDiff.isNegative) {
        expiryText = "Expired on $expiryFormat ";
        if (expiryDays > 0) {
          expiryText += " (${expiryDiff.inDays} days ago)";
        }
      } else {
        expiryText = "Expires on $expiryFormat ";
        if (expiryDays > 0) {
          expiryText += " (in ${expiryDiff.inDays} days)";
        }
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
                  Expanded(
                      flex: 1,
                      child: Container(
                          padding: EdgeInsets.only(left: 2, right: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              getVote((d.vote.up ?? "0") + "+", Colors.green),
                              getVote((d.vote.down ?? "0") + "-", Colors.red)
                            ],
                          ))),
                  Expanded(
                      flex: 5,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: metaWidgets)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.content_copy)),
                        onTap: () => {copyToClipboard(d.link)},
                      ),
                      InkWell(
                          child: Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.open_in_new)),
                          onTap: () => {})
                    ],
                  )
                ])),
            getDealRow(Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[],
            )),
            // getDealRow(Row(children: <Widget>[
            //   getTagsRow(d.tags)

            // ],))
            Align(child: getTagsRow(d.tags), alignment: Alignment.topLeft),
          ],
        ));
  }

  Widget getTitle(Deal d) {
    List<InlineSpan> spans = new List<InlineSpan>();
    if (d.meta != null) {
      if (d.meta.upcomingDate != null && d.meta.upcomingDate > 0) {
        spans.add(WidgetSpan(
            child: Container(
          child: Text(
            "UPCOMING",
            style: _highlightTitle.copyWith(color: Colors.white),
          ),
          padding: EdgeInsets.only(right: 2, left: 2),
          margin: EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0), color: Colors.green),
        )));
      }
      if (d.meta.expiredDate != null && d.meta.expiredDate > 0) {
        spans.add(WidgetSpan(
            child: Container(
          child: Text("EXPIRED",
              style: _highlightTitle.copyWith(color: Colors.white)),
          padding: EdgeInsets.only(right: 2, left: 2),
          margin: EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0), color: Colors.red),
        )));
      }
    }
    spans.add(TextSpan(text: d.title, style: _primaryTitle));

    return RichText(text: TextSpan(children: spans));
  }

  Widget getNonTitle(t) {
    return Text(t ?? "", style: _nonTitleStyle);
  }

  Widget getDealRow(child) {
    return Container(padding: EdgeInsets.only(top: 3, bottom: 3), child: child);
  }

  Widget getTagsRow(List<String> tags) {
    var row = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.spaceBetween,
      direction: Axis.horizontal,
      children: <Widget>[],
    );

    tags.forEach((element) {
      var tagStyle = _nonTitleStyle.copyWith(color: Colors.white);
      row.children.add(Container(
          padding: EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 2),
          margin: EdgeInsets.only(right: 2, top: 2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0), color: Colors.brown),
          child: Text(
            element,
            style: tagStyle,
          )));
    });

    return row;
  }

  Widget getFilterHeaderRow() {
    var container = Container(
        child: ListView(
      // This next line does the trick.
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        getFilterHeaderItem(DealFilter.Today),
        getFilterHeaderItem(DealFilter.Popular),
        getFilterHeaderItem(DealFilter.Freebies),
        getFilterHeaderItem(DealFilter.Expiring),
        getFilterHeaderItem(DealFilter.Upcoming),
        getFilterHeaderItem(DealFilter.LongRunning),
        getFilterHeaderItem(DealFilter.All)

      ],
    ));
    return container;
  }

  Widget getFilterHeaderItem(DealFilter filter)
  {
    var text = "All";
    var color = _filter==filter?Colors.blueAccent:Colors.yellow;
    var action=()=>{};
    switch(filter)
    {
      case DealFilter.Today:{
        text = "Today";
        action=()=> changeFilter(DealFilter.Today);
      }
      break;
      case DealFilter.Popular:{
        text = "Popular";
        action=()=> changeFilter(DealFilter.Popular);

      }
      break;
      case DealFilter.Upcoming:{
        text = "Upcoming";
        action=()=> changeFilter(DealFilter.Upcoming);

      }
      break;
      case DealFilter.Expiring:{
        text = "Expiring";
        action=()=> changeFilter(DealFilter.Expiring);

      }
      break;
      case DealFilter.Freebies:{
        text = "Freebies";
        action=()=> changeFilter(DealFilter.Freebies);

      }
      break;
       case DealFilter.LongRunning:{
        text = "Long Running";
        action=()=> changeFilter(DealFilter.LongRunning);

      }
      break;
      default:{
        text = "All";
        action=()=> changeFilter(DealFilter.All);

      }
      break;
    }
    return InkWell(child:Container(
          padding: EdgeInsets.only(left:10,right:10, top:10, bottom: 10),
          child: Text(text, style:_theme.textTheme.bodyText2),
          decoration: BoxDecoration(color:color),
          ), onTap: action,);
  }

  changeFilter(DealFilter filter)
  {
      setState(() {
        _filter = filter;
        _onRefresh();
      });
  }

  _showSearchRow()
  {
    setState(() {
      _searchVisible = !(_searchVisible??false);
    });
  }
  Widget getFilterSearchRow() {
    var row = Container(
        child: Row(
      children: <Widget>[
        Expanded(flex: 6, child: TextField()),
        Expanded(
            child: InkWell(
          child: Icon(Icons.search),
          onTap: () => {},
        )),
      ],
    ));

    return row;
  }

  Widget getIcon(icon) {
    return Container(
      alignment: Alignment.topCenter,
      child: icon,
    );
  }

  Widget getVote(v, Color c) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(1),
        margin: EdgeInsets.only(bottom: 1),
        child: Text(
          v,
          style: _nonTitleStyle.copyWith(color: Colors.white),
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
  bool _isLoading = false;
  Future<Null> _onRefresh({bool refresh=false}) async {
    print("Filtering with $_filter");
    setState((){
      _isLoading = true;
      
    });
    var list = await AppDataModel().getFilteredDeals(_filter, refresh:refresh);
    setState(() {

      print("*************** Refreshing deals ${list.length} ${this.deals.length}");
      this.deals.clear();
      this.deals = list
          .skipWhile((value) => value.errors != null && value.errors.length > 0)
          .toList();

      print("============== ${this.deals.length}");
      _isLoading = false;
    });
    return null;
  }
}
