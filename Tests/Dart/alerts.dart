import 'dart:io';

class Deal
{
  Deal(this.title, this.description);
  String title;
  String description;

   String toString()
  {
    return "Name=$title, Prefix=$description";
  }
}


class AlertRule {
   static final String prefix_Title = "Title";
  static final String prefix_Description = "Description";

  static final String condition_Contains = "Contains";
  static final String condition_NotContains = "Not Contains";

  static final String join_And = "And";
  static final String join_Or = "Or";

  static final List<String> prefixeTypes = [prefix_Title, prefix_Description];
  static final List<String> conditionTypes = [condition_Contains, condition_NotContains];
  static final List<String> joinTypes = [join_And, join_Or];

  AlertRule(this.name, {this.prefix, this.condition, this.suffix, this.join})
  {

    if((this.prefix??"").length == 0)
    {
      this.prefix = prefixeTypes[0];
    }

    if((this.condition??"").length == 0)
    {
      this.condition = conditionTypes[0];
    }

  }
  String name;

  String prefix;

  String condition;

  String suffix;

  String join;

  bool parse(Deal d)
  {
    var isMatch = false;
    var prefixValue = "";

    if(prefix == prefix_Title)
    {
      prefixValue = d.title??"";
    }  
    else
    if(prefix == prefix_Description)
    {
      prefixValue = d.description??"";
    }

    if(prefixValue.length>0 && ((condition??"").length>0) && ((suffix??"").length>0))
    {
        if(condition == condition_Contains)
        {
          print("Parsing contains $prefixValue $suffix");
          isMatch = prefixValue.contains(new RegExp(suffix));
          print("ruleMatch $isMatch");
        }
        else
        if(condition == condition_NotContains)
        {
             print("Parsing not contains $prefixValue $suffix");
          isMatch = !prefixValue.contains(suffix);
           print("ruleMatch $isMatch");
        }
    }

    return isMatch;
  }

  String toString()
  {
    return "Name=$name, Prefix=$prefix, condition=$condition, suffix=$suffix, join=$join";
  }
}

class AlertFilter
{
  AlertFilter(this.name);
  String name;
  List<AlertRule> rules = new List<AlertRule>();

  bool parse(Deal d)
  {
      var isMatch = rules.length>0;
      var lastJoin = "";
      for(var rule in rules)
      {
         var ruleMatch = rule.parse(d);
         if((lastJoin??"").length>0)
          {
             if(lastJoin == AlertRule.join_And)
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
          lastJoin = AlertRule.join_Or;

        print(lastJoin);
      }

      return isMatch;
  }
}

void main() async {
  var deals = new List<Deal>();
  deals.add(Deal("Android free app", "Andriod free app for all."));
  var rule = AlertRule("Rule1",suffix: "Android",join: "");
  var rule1 = AlertRule("Rule2",prefix: AlertRule.prefix_Description, condition: AlertRule.condition_NotContains, suffix: "Android");

  var filter = AlertFilter("Filter1");
  filter.rules.add(rule);
  filter.rules.add(rule1);
  print("$rule");
  print("$rule1");
  print(filter.parse(deals[0]));

}

