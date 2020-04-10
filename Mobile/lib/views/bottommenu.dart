

import 'package:flutter/material.dart';
import 'package:ozbargain/models/pagetypes.dart';

class BottomMenuView extends StatefulWidget {
  BottomMenuView({Key key, this.title, this.pageType}) : super(key: key);
 

  final String title;
  
  final PageType pageType;

  @override
  _BottomMenuViewState createState() => _BottomMenuViewState();
}

class _BottomMenuViewState extends State<BottomMenuView> {
  
 
  @override
  Widget build(BuildContext context) {
    return  new BottomNavigationBar(
      showUnselectedLabels: true,
      selectedItemColor: Theme.of(context).primaryColor,
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.pageType.index??0,
      
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Deals'),
        ),
          BottomNavigationBarItem(
          icon: Icon(Icons.list),
          title: Text('My Deals'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          title: Text('Fliters'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text('Settings'),
        
          
        ),
      ],
      onTap: (value) {
    
        switch (value) {
          case 1:
            Navigator.pushReplacementNamed(context, '/mydeals');
            break;
          case 2:
                Navigator.pushReplacementNamed(context, '/alerts');
            break;
          case 3:
              Navigator.pushReplacementNamed(context, '/settings');
          break;
          default:
                Navigator.pushReplacementNamed(context, '/');
                break;
        }
      },
      
      );
    
    
  }
}
