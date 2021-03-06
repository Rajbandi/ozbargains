import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/analyticsevent.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/models/dealfiltertype.dart';
import 'package:ozbargain/models/pagetypes.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/views/app.dart';
import 'package:ozbargain/views/bottommenu.dart';
import 'package:ozbargain/views/deal.dart';
import 'package:ozbargain/views/dealcommon.dart';

class DealsView extends StatefulWidget  {

  
  DealsView({Key key, this.title}) : super(key: key)
  {
    OzBargainApp.logCurrentPage("Deals");
  }

  final String title;

  @override
  _DealsViewState createState() => _DealsViewState();
}

class _DealsViewState extends State<DealsView> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Deal> deals = new List<Deal>();
  bool _searchVisible;

  DealCommon _common;
  DealFilterType _filter;
  StreamSubscription _dealSub;

  @override
  void initState() {
    super.initState();
     AppHelper.scaffoldKey = _scaffoldKey;

    WidgetsBinding.instance.addObserver(this);
    _floatButtonVisible = false;
    _filter = DealFilterType.Today;
    _searchVisible = false;
    _onRefresh();
    _searchController.addListener(() => onSearchTextChanged());
    _dealSub = AppDataModel().dealStream.stream.listen((event) {
        _onRefresh(scrollTop: false);
    });
  }

  ThemeData _theme;

  final ScrollController _dealsController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
     super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(() => onSearchTextChanged());
     if(_dealSub != null)
    {
      _dealSub.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("******* Resumed *****");
      // _onRefresh(refresh:true);
    }
  }

  onSearchTextChanged() {
    var text = _searchController.text;

    _onRefresh(search: text);
  }

  String _noDealMessage;

  @override
  Widget build(BuildContext context) {
    _common = DealCommon(context, _scaffoldKey);

    _theme = Theme.of(context);

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

    var listViewItems = deals.length > 0 ? listView : Align(alignment: Alignment.center,
    child: Text(_noDealMessage??""),);
    var refresh = RefreshIndicator(
      child: Stack(children: <Widget>[
        listViewItems,
        Visibility(
            visible: (_isLoading ?? false),
            child: new Align(
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
            var focusNode = FocusScope.of(context);
            if (focusNode != null) {
              var focusChild = focusNode.focusedChild;
              if (focusChild != null) {
                if (!(focusChild is EditableText)) {
                  focusNode.unfocus();
                }
              }
            }
          } catch (e) {
            print(e);
            OzBargainApp.logEvent(AnalyticsEventType.Error, { 'error': e, 'class':'deals','method':'GestureDetector'});

          }
        },
        child: Container(
            child: Column(children: <Widget>[
          Visibility(
              visible: _searchVisible ?? false, child: getFilterSearchRow()),
          Expanded(child: getFilterHeaderRow()),
          Expanded(flex: 15, child: listNotification)
        ])));
    return SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
                title: Row(
              children: <Widget>[
                Expanded(flex: 2, child: Text(widget.title ?? "")),
                Expanded(
                  child: Container(child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(child:
                        Container(child: Icon(Icons.refresh),  padding:EdgeInsets.all(5),),
                        onTap: () => {_onRefresh(refresh: true)},
                      ),
                      InkWell(
                          child:Container(child: Icon(Icons.filter_list) , padding:EdgeInsets.all(5),),
                          onTap: () => {_showSearchRow()}),
                    ],
                  ), margin: EdgeInsets.only(right:5),),
                )
              ],
            )),
            body: layout,
            floatingActionButton: _getFloatButton(),
            bottomNavigationBar: BottomMenuView(pageType: PageType.Home)));
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

    if(deals!= null && deals.length>0)
    {
      if(_dealsController.hasClients)
    {
    _dealsController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    }
    }
  }

  _openDeal(Deal d) {
    var view = new DealView(title: "Deal", deal: d);
    Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => view));
  }

  Widget _getDeal(Deal d) {

    var content = d.content;
    
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
                            child: Text(content),
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
//here goes the function

  Widget getFilterHeaderRow() {
    var container = Container(
        child: ListView(
      // This next line does the trick.
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      children: <Widget>[
        getFilterHeaderItem(DealFilterType.Today),
        getFilterHeaderItem(DealFilterType.Popular),
        getFilterHeaderItem(DealFilterType.Freebies),
        getFilterHeaderItem(DealFilterType.Expiring),
        getFilterHeaderItem(DealFilterType.Upcoming),
        getFilterHeaderItem(DealFilterType.LongRunning),
        getFilterHeaderItem(DealFilterType.All)
      ],
    ));
    return container;
  }

  Widget getFilterHeaderItem(DealFilterType filter) {
    var text = "All";

    var color = _theme.accentColor;
    var textStyle = _theme.textTheme.bodyText1;
    if (_filter == filter) {
      color = _theme.primaryColor;
      textStyle = textStyle.copyWith(color: Colors.white);
    }

    var action = () => {};
    switch (filter) {
      case DealFilterType.Today:
        {
          text = "Today";
          action = () => changeFilter(DealFilterType.Today);
        }
        break;
      case DealFilterType.Popular:
        {
          text = "Popular";
          action = () => changeFilter(DealFilterType.Popular);
        }
        break;
      case DealFilterType.Upcoming:
        {
          text = "Upcoming";
          action = () => changeFilter(DealFilterType.Upcoming);
        }
        break;
      case DealFilterType.Expiring:
        {
          text = "Expiring";
          action = () => changeFilter(DealFilterType.Expiring);
        }
        break;
      case DealFilterType.Freebies:
        {
          text = "Freebies";
          action = () => changeFilter(DealFilterType.Freebies);
        }
        break;
      case DealFilterType.LongRunning:
        {
          text = "Long Running";
          action = () => changeFilter(DealFilterType.LongRunning);
        }
        break;
      default:
        {
          text = "All";
          action = () => changeFilter(DealFilterType.All);
        }
        break;
    }

    return InkWell(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Text(text, style: textStyle),
        decoration: BoxDecoration(
          color: color,
        ),
      ),
      onTap: action,
    );
  }

  changeFilter(DealFilterType filter) {
    setState(() {
      _filter = filter;

      var search = "";
      if(_searchVisible && _searchController.text.length>0)
      {
        search = _searchController.text;
      }
      _onRefresh(search: search);
    });
  }

  _showSearchRow() {
    setState(() {
      _searchVisible = !(_searchVisible ?? false);
    });
  }

  Widget getFilterSearchRow() {
    var row = Container(
      child: 
      Column(children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
              flex: 6,
              child: TextField(
                
                controller: _searchController,
                decoration: InputDecoration(
                    hintText: "Search text here",
                    filled: true,
                    prefixIcon: Icon(
                      Icons.search,
                      size: 28.0,
                    ),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear, size: 28.0),
                        onPressed: () {
                          _searchController.text = "";
                        })),
              )),
        ],
      ),
      ],)
    );

    return row;
  }

  // Widget getFilterCategories() {
  //   var categories = AppDataModel().getCategories();

  //   var listView = ListView.builder(
  //     scrollDirection: Axis.horizontal,
  //     itemBuilder: (context, index) {
  //       var cat = categories[index];
  //       return Text(cat);
  //     },
  //     itemCount: categories != null ? categories.length : 0,
  //   );

  //   return listView;
  // }

  Widget getIcon(icon) {
    return Container(
      alignment: Alignment.topCenter,
      child: icon,
    );
  }

  bool _isLoading = false;
  Future<Null> _onRefresh({bool refresh = false, String search = "", bool scrollTop=true}) async {
    if (refresh) {
      var status = await AppHelper.getInternetStatus();
      if (!status) {
        AppHelper.showSnackError("No internet connection. Please check.");

        return;
      }
    }
    print("Filtering with $_filter");
    var error = false;
    setState(() {
      _isLoading = true;
    });
  
    var list = List<Deal>();
    try{
       list = await AppDataModel()
        .getFilteredDeals(_filter, refresh: refresh, search: search);
       

     }
      catch(e)
      {
        print(e);
        OzBargainApp.logEvent(AnalyticsEventType.Error, {'error':e.toString(), 'class':'Deals','method':'onRefresh'});
        error = true;
        AppHelper.showSnackError("Oops, something went wrong. Please try again later.");
      }
    
    setState(() {

      if(error)
      {
         _noDealMessage= "Oops something went wrong. Please try again later";
      }
      else
      if(deals.length == 0)
      {
          _noDealMessage="No deals found. Please check later";
      }
      print(
          "*************** Refreshing deals ${list.length} ${this.deals.length}");
      this.deals.clear();
      this.deals = list
          .skipWhile((value) => value.errors != null && value.errors.length > 0)
          .toList();

      print("============== ${this.deals.length}");
      _isLoading = false;
    });
    if(scrollTop)
    {
      _scrollToTop();
    }
    return null;
  }
}
