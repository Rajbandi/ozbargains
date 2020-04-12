import 'package:flutter/material.dart';
import 'package:ozbargain/models/filterrule.dart';
import 'package:ozbargain/models/pagetypes.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/views/bottommenu.dart';

import 'app.dart';

class DealFiltersPage extends StatefulWidget {
  DealFiltersPage({Key key, this.title}) : super(key: key){
    OzBargainApp.logCurrentPage("Filters");
  }
  final String title;
  @override
  _DealsFiltersPageState createState() => _DealsFiltersPageState();
}

class _DealsFiltersPageState extends State<DealFiltersPage> {
  ThemeData _theme;
  List<DealFilter> _filters = new List<DealFilter>();
  BuildContext context;
  AppDataModel _model = AppDataModel();
  @override
  void initState() {
    super.initState();
    if (_model.settings.alertFilters == null) {
      print("Alert filters not exist, creating new");
      _model.settings.alertFilters = List<DealFilter>();
      _model.updateSettings();
    }
    _filters = _model.settings.alertFilters;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    _theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title ?? "")),
        body: _filters.length == 0
            ? Align(
                alignment: Alignment.center,
                child: Text("No alert filters found. Press '+' to add new one."))
            : ListView.separated(
                itemCount: _filters.length,
                separatorBuilder: (context, index) {
                  return Divider(height: 1);
                },
                itemBuilder: (context, index) {
                  var filter = _filters[index];
                  return _getRuleView(filter);
                },
              ),
        floatingActionButton: _getFloatButton(),
        bottomNavigationBar: BottomMenuView(pageType: PageType.Alerts),
      ),
    );
  }

  _getRuleView(DealFilter filter) {
    return InkWell(child:Container(
      padding: EdgeInsets.symmetric(vertical:10, horizontal: 10),
      margin: EdgeInsets.all(5),
      color: _theme.dividerColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Opacity(
              opacity: 0.75,
              child: Text(filter.name,
                  style: _theme.textTheme.headline6
                      )),
          InkWell(
              child: Icon(Icons.delete, color: Colors.redAccent,), onTap: () => {_removeFilter(filter)}),
        ],
      ),
    ), onTap: ()=>{
      _viewFilter(filter)
    },);
  }

  _getFloatButton() {
    var _floatButton = FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: _theme.primaryColor,
        onPressed: () => {_viewFilter(null)});
    return _floatButton;
  }

  _removeFilter(filter) {
    if (_filters.length > 0) {
      var alertFilter =
          _filters.firstWhere((f) => f.id == filter.id, orElse: () => null);
      if (alertFilter != null) {
        setState(() {
          _filters.removeWhere((f) => f.id == filter.id);
          _model.updateSettings();
        });
      }
    }
  }

  _viewFilter(fil) async {
    var filter = await Navigator.pushNamed<DealFilter>(context, "/viewalert",
        arguments: fil ?? DealFilter());

    print('Return from filter view ********** $filter');

    if (_checkFilter(filter)) {
      setState(() {
        var alertFilter =
            _filters.firstWhere((f) => f.id == filter.id, orElse: () => null);
          bool update = false;

        if (alertFilter != null) {
            alertFilter.name = filter.name;
            alertFilter.rules = filter.rules;
            update = true;
        } else {
          update = true;
          _filters.add(filter);
          
        }
        if(update)
          AppDataModel().updateSettings();

      });
    }
  }

  bool _checkFilter(DealFilter filter) {
    if (filter == null) {
      return false;
    }
    if ((filter.name ?? "").trim().length == 0) return false;
    if (filter.rules == null || filter.rules.length == 0) return false;

    return true;
  }
}
