
class AlertRulePrefix
{
 static final String title = "Title";
 static final String description = "Description";
}

class AlertRuleCondition
{
  static final String contains = "Contains";
  static final String startsWith = "Starts With";
  static final String endsWith = "Ends With";
}

class AlertRuleItem{

  AlertRuleItem({this.name, this.prefix, this.condition, this.suffix});

  String name;
  
  String prefix;

  String condition;

  String suffix;

  String join;

  bool get isValid {
    return !(prefix??"").isNotEmpty && (condition??"").isNotEmpty && (suffix??"").isNotEmpty;
  }
}

class AlertRule
{
  String name;

  List<AlertRuleItem> ruleItems = new List<AlertRuleItem>();
  
}