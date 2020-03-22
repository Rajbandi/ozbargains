import 'package:flutter/material.dart';

import 'home.dart';

class OzBargainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'OZ Bargain'),
    );
  }
}
