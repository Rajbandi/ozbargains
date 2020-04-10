

import 'package:ozbargain/models/deal.dart';
import 'package:random_string/random_string.dart';


class FilterRule {
   static final String prefixTitle = "Title";
  static final String prefixDescription = "Description";

  static final String conditionContains = "Contains";
  static final String conditionNotContains = "Not Contains";

  static final String joinAnd = "And";
  static final String joinOr = "Or";

  static final List<String> prefixTypes = [prefixTitle, prefixDescription];
  static final List<String> conditionTypes = [conditionContains, conditionNotContains];
  static final List<String> joinTypes = [joinAnd, joinOr];

  FilterRule({this.name, this.prefix, this.condition, this.suffix, this.join})
  {

    _checkDefaults();

  }
  String name;
  String prefix;
  String condition;
  String suffix;
  String join;

  _checkDefaults()
  {
    if((this.prefix??"").length == 0)
    {
      this.prefix = prefixTypes[0];
    }

    if((this.condition??"").length == 0)
    {
      this.condition = conditionTypes[0];
    }
  }
  FilterRule.fromJson(Map<String, dynamic> json) {
    name = json['name']??"";
    prefix = json['prefix'];
    condition = json['condition'];
    suffix = json['suffix'];
    join = json['join'];
    _checkDefaults();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    _checkDefaults();
    data['name'] = this.name;
    data['prefix'] = this.prefix;
    data['condition'] = this.condition;
    data['suffix'] = this.suffix;
    data['join'] = this.join;
    return data;
  }

  bool parse(Deal d)
  {
    var isMatch = false;
    var prefixValue = "";

    if(prefix == prefixTitle)
    {
      prefixValue = d.title??"";
    }  
    else
    if(prefix == prefixDescription)
    {
      prefixValue = d.description??"";
    }

    if(prefixValue.length>0 && ((condition??"").length>0) && ((suffix??"").length>0))
    {
        if(condition == conditionContains)
        {
          //print("Parsing contains $prefixValue $suffix");
          isMatch = prefixValue.contains(new RegExp(suffix));
          //print("ruleMatch $isMatch");
        }
        else
        if(condition == conditionNotContains)
        {
         //    print("Parsing not contains $prefixValue $suffix");
          isMatch = !prefixValue.contains(suffix);
           //print("ruleMatch $isMatch");
        }
    }

    return isMatch;
  }

  String toString()
  {
    return "Name=$name, Prefix=$prefix, condition=$condition, suffix=$suffix, join=$join";
  }
}



class DealFilter
{
  DealFilter({this.name})
  {
    id = randomAlphaNumeric(10);
  }
  String id;
  String name;
  List<FilterRule> rules = new List<FilterRule>();

 DealFilter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']??"";
     var ruleList = json['rules'];
    rules.clear();
    for(var rule in ruleList)
    {
      
        rules.add(FilterRule.fromJson(rule));
      
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
   
    data['rules'] = this.rules;
    return data;
  }

  bool parse(Deal d)
  {
      var isMatch = rules.length>0;
      var lastJoin = "";
      for(var rule in rules)
      {
         var ruleMatch = rule.parse(d);
         if((lastJoin??"").length>0)
          {
             if(lastJoin == FilterRule.joinAnd)
             {
                isMatch &= ruleMatch;
             }
             else
               isMatch |= ruleMatch;
          }
          else
           isMatch &= ruleMatch;
      
         if((rule.join??"").length>0)
         {
            lastJoin = rule.join;
         }
         else
          lastJoin = FilterRule.joinOr;

        //print(lastJoin);
      }

      return isMatch;
  }
  String toString()
  {
    var ruleString = "";
    rules.forEach((e) => {
      ruleString += e.toString()
    });
    return "Id: $id, Name: $name, Rules=$ruleString";
  }
}

