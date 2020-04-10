import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/filterrule.dart';

class DealFilterView extends StatefulWidget {
  final DealFilter filter;
  DealFilterView(this.filter, {Key key}) : super(key: key);

  @override
  _DealFilterViewState createState() => _DealFilterViewState();
}

class _DealFilterViewState extends State<DealFilterView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DealFilter ruleFilter = new DealFilter();
  ThemeData _theme;
  TextEditingController _nameController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameFocus = new FocusNode();

    ruleFilter = widget.filter ?? DealFilter();
  
    if (ruleFilter.rules.length == 0) {
      _addRule();
    }

    _nameController.text = ruleFilter.name;
    AppHelper.scaffoldKey = _scaffoldKey;
  }

  bool _isTextField = false;

  FocusNode _nameFocus;
  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
   
    return
        //WillPopScope(
        //child:
        GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (TapDownDetails t) {
              try {
                var focusNode = FocusScope.of(context);
                if(focusNode != null)
                {
                  var focusChild = focusNode.focusedChild;
                  if(focusChild != null)
                  {
                     if(!(focusChild is EditableText))
                     {
                        focusNode.unfocus();
                     }
                  }
                }
              } catch (e) {
                print(e);
              }
            },
            child: SafeArea(
              child: Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                    title: Text("Add/Edit Alert"),
                    leading: InkWell(
                        child: Icon(Icons.arrow_back),
                        onTap: () {
                          _onPop();
                        }),
                  ),
                  floatingActionButton: _getFloatButtons(),
                  body: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: new TextField(
                          focusNode: _nameFocus,
                          controller: _nameController,
                          maxLength: 20,
                          onTap: () => _isTextField = true,
                          onEditingComplete: () => _isTextField = false,
                          decoration:
                              new InputDecoration(hintText: "Type name here"),
                          onChanged: (value) {
                            ruleFilter.name = value;
                          },
                        ),
                      ),
                      Expanded(
                          child: ListView.separated(
                        padding: EdgeInsets.only(top: 10, left: 5, right: 5),
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 1,
                          );
                        },
                        itemBuilder: (context, index) {
                          var filterRule = ruleFilter.rules[index];
                          return _getRuleWidget(filterRule, index: index);
                        },
                        itemCount: ruleFilter.rules.length,
                      )),
                    ],
                  )),
            ))
        //onWillPop: () => _onPop(),
        //)
        ;
  }

  Future<bool> _onPop() {
    _closeAlert();
  }

  _closeAlert()
  {
    if (Navigator.of(context).canPop() && _checkFilter()) {
      Navigator.pop<DealFilter>(context, ruleFilter);
    }
  }

  bool _checkFilter() {
    var validName = (ruleFilter.name ?? "").trim().length > 0;
    var rules = ruleFilter.rules;
    if (rules.length == 0) {
      return true;
    } else if (rules.length == 1) {
      if ((ruleFilter.rules[0].suffix ?? "").trim().length == 0) {
        return true;
      }
    }

    if (!validName) {
      AppHelper.showSnackError("Alert name is required");
      return false;
    }
    ruleFilter.rules.removeWhere((r) => (r.suffix ?? "").trim().length == 0);
    return true;
  }

  _getRuleWidget(FilterRule rule, {int index = -1}) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: Text("Look in")),
                  Expanded(child: _getPrefixWidget(rule))
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Text("Condition")),
                  Expanded(child: _getConditionWidget(rule))
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Text("For")),
                  Expanded(child: _getSuffixWidget(rule))
                ],
              ),
              Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.only(top: 10, bottom: 5),
                  child: _getRemoveWidget(rule, index))
            ],
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(width: 1, color: _theme.primaryColor)),
        ),
        Visibility(
            visible: index >= 0 && index < ruleFilter.rules.length - 1,
            child: _getJoinWidget(rule)),
      ],
    );
  }

  _getRemoveWidget(FilterRule rule, int index) {
    return InkWell(
        child: Icon(Icons.delete),
        onTap: () {
          setState(() {
            ruleFilter.rules.removeAt(index);
            if (ruleFilter.rules.length > 0) {
              print("Removing alert filter");
              var notContain = ruleFilter.rules.firstWhere(
                  (r) => r.condition == FilterRule.conditionNotContains,
                  orElse: () => null);
              if (notContain != null) {
                _checkConditionExclusive(
                    notContain, FilterRule.conditionContains);
              }
            }
          });
        });
  }

  _getPrefixWidget(FilterRule rule) {
    return DropdownButton<String>(
      value: rule.prefix,
      items: FilterRule.prefixTypes.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value),
        );
      }).toList(),
      onChanged: (item) {
        if (ruleFilter.rules.any((r) => r.prefix == item)) {
          return;
        }

        setState(() {
          rule.prefix = item;
        });
      },
    );
  }

  _getConditionWidget(FilterRule rule) {
    return DropdownButton<String>(
      value: rule.condition,
      items: FilterRule.conditionTypes.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value),
        );
      }).toList(),
      onChanged: (item) {
        setState(() {
          var oldCondition = rule.condition;
          rule.condition = item;
          _checkConditionExclusive(rule, oldCondition);
        });
      },
    );
  }

  _checkConditionExclusive(FilterRule rule, String oldCondition) {
    var notContains = ruleFilter.rules
        .where((r) => r.condition == FilterRule.conditionNotContains)
        .toList();
    if (ruleFilter.rules.length <= 1 ||
        notContains.length == ruleFilter.rules.length) {
      rule.condition = oldCondition;
    }
  }

  _getSuffixWidget(FilterRule rule) {
    var controller = TextEditingController(text: rule.suffix);
    return TextField(
        onTap: () => _isTextField = true,
        onEditingComplete: () => _isTextField = false,
        controller: controller,
        decoration: InputDecoration(
          isDense: true,
        ),
        onChanged: (value) => {
              setState(() => {rule.suffix = value})
            });
  }

  _getJoinWidget(FilterRule rule) {
    return DropdownButton<String>(
      value: rule.join ?? FilterRule.joinOr,
      items: FilterRule.joinTypes.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value),
        );
      }).toList(),
      onChanged: (item) {
        setState(() {
          rule.join = item;
        });
      },
    );
  }

  _addRule() {
    var rules = ruleFilter.rules;
    var newRule = FilterRule();
    if (rules.length > 0) {
      var prefixes = FilterRule.prefixTypes;

      if (rules.length >= prefixes.length) {
        return;
      } else {
        for (var prefix in prefixes) {
          if (!rules.any((r) => r.prefix == prefix)) {
            newRule.prefix = prefix;
            break;
          }
        }
      }
    }
    setState(() {
      ruleFilter.rules.add(newRule);
    });
  }

  _getFloatButton() {
    var _floatButton = FloatingActionButton(
        backgroundColor: _theme.primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => {_addRule()});
    return _floatButton;
  }

  _getFloatButtons(){
    return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      FloatingActionButton(
         backgroundColor: _theme.primaryColor,  
        child: Transform.rotate(angle: 180 * pi/180, child: Icon(
          Icons.exit_to_app, color: Colors.white
        )),
        onPressed: () {
          _closeAlert();
        },
        heroTag: null,
      ),
      SizedBox(
        height: 10,
      ),
      FloatingActionButton(           
        backgroundColor: _theme.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _addRule(),
        heroTag: null,
      )
    ]
  );
  }

}
