import 'package:flutter/material.dart';
import 'package:ozbargain/helpers/apphelper.dart';

enum ThemeType { Light, Dark }

class ThemeModel extends ChangeNotifier {
  ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Color(0xffCD6700),
    accentColor: Color(0xff40bf7a),
  );
  ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Color(0xffCD6700),
    accentColor: Color(0xff40bf7a),
  );
  ThemeData currentTheme;
  ThemeType _themeType = ThemeType.Dark;

  ThemeModel() {
    var theme = lightTheme;
    
    currentTheme = lightTheme;
  }
  String get currentThemeName {
    return currentTheme== darkTheme?"Dark":"Light";
  }
  changeTheme(String theme)
  {
      var themeStr = theme??"light";
      if(themeStr.toLowerCase() == "dark")
      {
          currentTheme = darkTheme;
      }
      else
      {
        currentTheme = lightTheme;
      }
     
       return notifyListeners();
  }

  toggleTheme() {
    if (_themeType == ThemeType.Dark) {
      currentTheme = lightTheme;
      _themeType = ThemeType.Light;
      return notifyListeners();
    }

    if (_themeType == ThemeType.Light) {
      currentTheme = darkTheme;
      _themeType = ThemeType.Dark;
      return notifyListeners();
    }
  }
}
