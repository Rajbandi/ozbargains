

import 'package:flutter/material.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:package_info/package_info.dart';

import 'app.dart';

class AboutPage extends StatefulWidget {
  
  
  AboutPage({Key key}) : super(key: key){
    OzBargainApp.logCurrentPage("About");
  }

  @override
  
  
  _AboutPageState createState() => _AboutPageState();
}



class _AboutPageState extends State<AboutPage> {

  PackageInfo _packageInfo;  
  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  @override
  Widget build(BuildContext context) {

    var packageName = "OzBargain";
    var appName = "OzBargain";
    var version = "1.0.0";
    var buildNumber = "1";

    if(_packageInfo != null)
    {
        packageName = _packageInfo.packageName;
        appName = _packageInfo.appName;
        version = _packageInfo.version;
        buildNumber = _packageInfo.buildNumber;
    }

    return SafeArea(child: Scaffold(
      appBar: AppBar(title:  Text("About"),),
      body: 

      Table(
        
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2)
        },
        children: [
          getRow("App Name", appName),
          getRow("Package Name", packageName),
          getRow("Version", version),
          getRow("Build Number", buildNumber),
          getRow("Developer", "Raj Bandi"),
          getRow("Copyrights", "© 2020 Omkaars"),
          getRow("Website", "https://www.omkaars.dev"),
      ],)
    ),);

  }

  TableRow getRow(String title, String value)
  {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    var color = theme.dividerColor;

    var borderSide = BorderSide(color:color,width: 0.2);
   
    Widget valueWidget;
    if(value.startsWith("http"))
    {
       var textWidget = Text(value, style: textTheme.subtitle1.copyWith(color:Colors.blue, decoration: TextDecoration.underline));
      valueWidget = InkWell(child: textWidget, onTap: () => AppHelper.openUrl(context, "", value),);
    }
    else
    {
      valueWidget =  Text(value, style: textTheme.subtitle1);
    }
    return TableRow(
        
          children: [
          TableCell(
                
            child: Container(
              padding: EdgeInsets.all(10),
              child:  Text(title, style: textTheme.bodyText1.copyWith(color:Colors.grey.shade500)),
            decoration: BoxDecoration(
              border: Border.fromBorderSide(borderSide)
            ),
            ),
            
            ),
          TableCell(child: Container(
              padding: EdgeInsets.all(10),
              child:  valueWidget,
            decoration: BoxDecoration(
              border: Border.fromBorderSide(borderSide)
            ),
            ),
            )
        ]);  
        
        }

  void _loadPackageInfo() async
  {
    _packageInfo = await PackageInfo.fromPlatform();
  }
}