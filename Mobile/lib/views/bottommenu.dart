

import 'package:flutter/material.dart';

class BottomMenuView extends StatefulWidget {
  BottomMenuView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _BottomMenuViewState createState() => _BottomMenuViewState();
}

class _BottomMenuViewState extends State<BottomMenuView> {
  
  @override
  Widget build(BuildContext context) {

    return  new BottomNavigationBar(items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Deals'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          title: Text('Live'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          title: Text('Account'),
        ),
      ],);
    
  }
}
