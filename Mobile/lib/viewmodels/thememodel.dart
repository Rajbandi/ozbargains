import 'package:flutter/material.dart';

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
    currentTheme = lightTheme;
  }

  changeTheme(String theme)
  {
      if(theme == "Dark")
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
