

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomMenuView extends StatefulWidget {
  BottomMenuView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _BottomMenuViewState createState() => _BottomMenuViewState();
}

class _BottomMenuViewState extends State<BottomMenuView> {
  
  @override
  Widget build(BuildContext context) {

    return  new BottomNavigationBar(
      
      
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Deals'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          title: Text('Alerts'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text('Settings'),
          
        ),
      ],);
    
  }
}
