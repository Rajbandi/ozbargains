
class AppHelper{

  static int currentTimeInSeconds(DateTime d) {
  
    var ms = d.millisecondsSinceEpoch;
    return (ms / 1000).round();
}


}