import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'app.dart';


class DealWebView extends StatefulWidget {
  final String title;
  final String url;

  DealWebView({Key key, this.title, this.url}) : super(key: key){
    OzBargainApp.logCurrentPage("DealWebView");
  }

  @override
  _DealWebViewState createState() => _DealWebViewState();
}

class _DealWebViewState extends State<DealWebView> {
  String _title, _url;
  bool _isLoading = true;

  FlutterWebviewPlugin _webviewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  final TextEditingController _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (_url == null) {
      _url = widget.url;
    }
    _textController.text = _url;
    return SafeArea(
        child: 
       WebviewScaffold(
            
            appBar: AppBar(
              
              leading:      InkWell(child:  Icon(Icons.clear), onTap: (){
            
            if(Navigator.canPop(context)){
        Navigator.of(context).pop();
      }
            },),  
              title: 
              
              Container(child:TextFormField(controller: _textController,readOnly: true,
              style: Theme.of(context).textTheme.bodyText1.copyWith(color:Colors.black54),
              decoration: InputDecoration(
                
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                enabledBorder: InputBorder.none
              ),)
              ,decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                color: Colors.white
              ),
              ),
              
          
            actions: <Widget>[
              
              Icon(Icons.more_vert)
            ],
             iconTheme: IconThemeData(color: Colors.white),
            ),
            
            url:  _url,
            scrollBar: true,
            
            withJavascript: true,
            withLocalStorage: true,
            resizeToAvoidBottomInset: true,
            
            hidden: true,
          )
    );
  }

  Widget getAction(IconData iconData)
  {
      return Container(child:Icon(iconData, color: Colors.white), padding: EdgeInsets.symmetric(horizontal: 1),);
  }

  void showLoading(bool show) {
    setState(() {
      _isLoading = show;
    });
  }

  void updateTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  void updateUrl(String url)
  {
    setState((){
      _textController.text = url;
    });
  }
 
}
