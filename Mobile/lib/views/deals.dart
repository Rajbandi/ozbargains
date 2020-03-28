import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/deal.dart';
import 'package:ozbargain/models/dealfilter.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/viewmodels/thememodel.dart';
import 'package:ozbargain/views/bottommenu.dart';
import 'package:ozbargain/views/deal.dart';
import 'package:ozbargain/views/dealcommon.dart';
import 'package:provider/provider.dart';

import '../helpers/apphelper.dart';

class DealsView extends StatefulWidget {
  DealsView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DealsViewState createState() => _DealsViewState();
}

class _DealsViewState extends State<DealsView> with WidgetsBindingObserver
{
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Deal> deals = new List<Deal>();
  bool _searchVisible;
  Color _primaryColor, _accentColor;
  
  DealCommon _common;
  DealFilter _filter;
  @override
  void initState() {
    super.initState();
      WidgetsBinding.instance.addObserver(this);
    _floatButtonVisible = false;
    _filter = DealFilter.Today;
    _searchVisible = false;
    _onRefresh();
    _searchController.addListener(()=> onSearchTextChanged());

   super.initState();

  }

  TextStyle _nonTitleStyle, _primaryTitle, _highlightTitle;
  TextTheme _currentTextTheme;
  ThemeData _theme;

  final ScrollController _dealsController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  BuildContext _context;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(()=> onSearchTextChanged());
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed)
    {
      _onRefresh(refresh:true);
    }
  }

  onSearchTextChanged()
  {
      var text = _searchController.text;

      _onRefresh(search:text);
  }


  @override
  Widget build(BuildContext context) {
    _context = context;
    _common = DealCommon(context, _scaffoldKey);

    _theme = Theme.of(context);
    _primaryTitle =
        _theme.primaryTextTheme.bodyText1.copyWith(color: _theme.primaryColor);
    _highlightTitle =
        _theme.accentTextTheme.bodyText1.copyWith(color: _theme.accentColor);

    _nonTitleStyle = _common.nonTitleStyle;

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
          } catch (e) {
            print(e);
          }
        },
        child: Container(
            child: Column(children: <Widget>[
          Visibility(visible:_searchVisible??false, child:getFilterSearchRow()),
          Expanded(child: getFilterHeaderRow()),
          Expanded(flex: 15, child: listNotification)
        ])));
    return SafeArea(
      child:
      Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Row(children: <Widget>[
          Expanded(flex:1, child:Text(widget.title ?? "")),
          Expanded(child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
            InkWell(child:Icon(Icons.refresh), onTap: () => { _onRefresh(refresh: true)},),
            InkWell(child:Icon(Icons.filter_list), onTap: () => { 
              
                AppHelper.showNotificationWithoutSound()
              //_showSearchRow() 
              }),
            DropdownButton<String>(
               
               hint: Text("Theme"),
               value: _currentTheme,
              items: <String>["Light","Dark"].map((String value){
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value,)
                );
              }).toList()
              ,
            onChanged: (item){
                _currentTheme = item;
                print(item);
                Provider.of<ThemeModel>(context, listen:false).changeTheme(item);
            },
            )
          ],),)
          ],) 
        ),
        body: layout,
        floatingActionButton: _getFloatButton(),
        bottomNavigationBar: BottomMenuView()));
  }
  String _currentTheme="Light";
  bool _floatButtonVisible;
  _getFloatButton() {
    var _floatButton = FloatingActionButton(
        child: Icon(Icons.vertical_align_top),
        backgroundColor: _theme.primaryColor,
        onPressed: () => {
             _scrollToTop()
            });
    return Visibility(
        visible: _floatButtonVisible ?? false, child: _floatButton);
  }

  _scrollToTop()
  {
     _dealsController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
  }

  _openDeal(Deal d) {
    var view = new DealView(title: "Deal", deal: d);
    Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => view));
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

                Expanded(child:
                  
                  Html(data: d.content??"", padding: EdgeInsets.only(left:2),  onLinkTap: (url) => {
                AppHelper.openUrl(context, "", url)
              },)
                  )
              ],
            )),
            // getDealRow(Row(children: <Widget>[
            //   getTagsRow(d.tags)

            // ],))
            Align(child: _common.getTagsRow(d.tags), alignment: Alignment.topLeft),
          ],
        ));
  }

 

  Widget getFilterHeaderRow() {
    var container = Container(
        
        child: ListView(
      // This next line does the trick.
      scrollDirection: Axis.horizontal,
      shrinkWrap: true, 
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


    var color = _theme.accentColor;
    var textStyle = _theme.textTheme.bodyText1;
    if(_filter==filter)
    {
        color = _theme.primaryColor;
        textStyle = textStyle.copyWith(color:Colors.white);
    }
    
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
          alignment: Alignment.center,
          padding: EdgeInsets.only(left:10,right:10),
          child: Text(text, style:textStyle),
          decoration: BoxDecoration(color:color,
          ),
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
        child: 
       
        Row(
      children: <Widget>[
        Expanded(flex: 6, child: TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
                  filled: true,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 28.0,
                  ),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.clear, size:28.0),
                      onPressed: () {
                          _searchController.text = "";
                      })),)),
      ],

    ),
  
    
    );

    return row;
  }

  Widget getFilterCategories()
  {
      var categories = AppDataModel().getCategories();
      
    
      var listView = ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index){

          var cat = categories[index];
          return Text(cat);
        },
        itemCount: categories != null?categories.length:0,
      );

      return listView;
  }
  
  Widget getIcon(icon) {
    return Container(
      alignment: Alignment.topCenter,
      child: icon,
    );
  }

  
  bool _isLoading = false;
  Future<Null> _onRefresh({bool refresh=false,String search=""}) async {
    print("Filtering with $_filter");
    setState((){
      _isLoading = true;
      
    });
    var list = await AppDataModel().getFilteredDeals(_filter, refresh:refresh, search:search);
    setState(() {

      print("*************** Refreshing deals ${list.length} ${this.deals.length}");
      this.deals.clear();
      this.deals = list
          .skipWhile((value) => value.errors != null && value.errors.length > 0)
          .toList();

      print("============== ${this.deals.length}");
      _isLoading = false;
    });
    _scrollToTop();
    return null;
  }
}
