import 'package:flutter/material.dart';
import 'package:ozbargain/viewmodels/thememodel.dart';
import 'package:provider/provider.dart';

import 'home.dart';

class OzBargainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OZBargain Deals',
      theme: Provider.of<ThemeModel>(context).currentTheme,
      home: HomePage(title: 'OZBargain Deals'),
    );
  }

}
