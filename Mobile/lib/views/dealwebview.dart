import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class DealWebView extends StatefulWidget {
  
  DealWebView({Key key, this.title, this.url}) : super(key: key);
  
  final String title;
  final String url;

  @override
  _DealWebState createState() => _DealWebState();
}

class _DealWebState extends State<DealWebView> {
  @override
  Widget build(BuildContext context) {
    return new SafeArea(child:WebviewScaffold(

      url: widget.url,
      appBar: new AppBar(
        actions: <Widget>[
          Icon(Icons.refresh)
        ],
      ),
      withZoom: true,
      withLocalStorage: true,
      withJavascript: true,
      enableAppScheme: true,
      resizeToAvoidBottomInset: false,
      hidden: true,
      scrollBar: true,      
      initialChild: Container(
        child: const Center(
          child: CircularProgressIndicator()
        ),
      ),
    ));
  }
}