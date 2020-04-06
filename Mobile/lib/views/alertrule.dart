import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ozbargain/models/alertrule.dart';

class AlertRuleView extends StatefulWidget {
  final AlertRule rule;
  AlertRuleView(this.rule, {Key key}) : super(key: key) {}

  @override
  _AlertRuleViewState createState() => _AlertRuleViewState();
}

class _AlertRuleViewState extends State<AlertRuleView> {
  AlertRule rule = new AlertRule();
  List<String> prefixCategories = ["Title", "Description"].toList();
  ThemeData _theme;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(title: Text("Add/Edit Alert")),
          floatingActionButton: _getFloatButton(),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          var ruleItem = rule.ruleItems[index];

                          return _getRuleItemRow(ruleItem);
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 1,
                          );
                        },
                        itemCount: rule.ruleItems.length)),
              ),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(right: 10),
                      child:
                          RaisedButton(child: Text("Clear"), onPressed: () {})),
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child:
                          RaisedButton(child: Text("Save"), onPressed: () {}))
                ],
              ))
            ],
          )),
    );
  }

  _getFloatButton() {
    var _floatButton = Align(
        alignment: Alignment.centerRight,
        child: FloatingActionButton(
            backgroundColor: _theme.primaryColor,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () => {_addRuleItem()}));
    return _floatButton;
  }

  _addRuleItem() {
    var items = rule.ruleItems.any((x){
      return !x.isValid;
    });
    if(items)
    {
      return;
    }
    setState(() {
      rule.ruleItems.add(new AlertRuleItem());
    });
  }

  _getRuleItemRow(AlertRuleItem rule) {

    if((rule.prefix??"").isEmpty)
    {
        rule.prefix = "Title";
        rule.condition = "Contains";
    }
    var row = Wrap(
      runAlignment: WrapAlignment.start,
      direction: Axis.horizontal,
      children: <Widget>[
        DropdownButton(
          value: rule.prefix??prefixCategories[0],
          items: prefixCategories.map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList(),
          onChanged: (item) => {setState(() {
            rule.prefix = item;
           
          })},
        ),
      ],
    );

    if((rule.condition??"").isNotEmpty)
    {
      var conditionList = List<String>();
      if(rule.prefix == AlertRulePrefix.title || rule.prefix == AlertRulePrefix.description)
      {
        conditionList.addAll(<String>["Contains","Starts With","Ends With"].toList());
      }
      if(conditionList.length>0)
      {
      var conditionWidget = DropdownButton(
        value: rule.condition??"Contains",
        items: conditionList.map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList(),
          onChanged: (condition){
            rule.condition = condition;
          },
          );

        row.children.add(conditionWidget);
      }
    }
    return row;
  }

  _getRuleCondtion() {
    var conditionList = <String>[].toList();
  }
}
