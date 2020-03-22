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
    return new WebviewScaffold(
      url: widget.url,
      appBar: new AppBar(
        title: Text(widget.title),
      ),
      withZoom: true,
      withLocalStorage: true,
      withJavascript: true,
      
      hidden: true,
      initialChild: Container(
        child: const Center(
          child: CircularProgressIndicator()
        ),
      ),
    );
  }
}