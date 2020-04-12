import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:ozbargain/views/app.dart';

class DeviceInfoPage extends StatefulWidget {
  DeviceInfoPage({Key key}) : super(key: key){
    OzBargainApp.logCurrentPage("DeviceInfo");
  }

  @override
  _DeviceInfoPageState createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {

 Map<String, dynamic> _deviceData = <String, dynamic>{};

Future initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidInfo(await OzBargainApp.deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosInfo(await OzBargainApp.deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    setState(() {
      _deviceData = deviceData;
    });
  }

 Map<String, dynamic> _readAndroidInfo(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'Security Patch': build.version.securityPatch,
      'Sdk Integer': build.version.sdkInt,
      'Release': build.version.release,
      'Preview Sdk Int': build.version.previewSdkInt,
      'Incremental': build.version.incremental,
      'Codename': build.version.codename,
      'Base OS': build.version.baseOS,
      'Board': build.board,
      'Bootloader': build.bootloader,
      'Brand': build.brand,
      'Device': build.device,
      'Display': build.display,
      'Fingerprint': build.fingerprint,
      'Hardware': build.hardware,
      'Host': build.host,
      'Id': build.id,
      'Manufacturer': build.manufacturer,
      'Model': build.model,
      'Product': build.product,
      '32Bit supported': build.supported32BitAbis,
      '64Bit supported': build.supported64BitAbis,
      'Abis supported': build.supportedAbis,
      'Tags': build.tags,
      'Type': build.type,
      'Physical device': build.isPhysicalDevice,
      'Android Id': build.androidId,
      'System Features': build.systemFeatures,
    };
  }


  
  Map<String, dynamic> _readIosInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'Name': data.name,
      'System Name': data.systemName,
      'System Version': data.systemVersion,
      'Model': data.model,
      'Localized Model': data.localizedModel,
      'Vendor identifier': data.identifierForVendor,
      'Physical device': data.isPhysicalDevice,
      'Sysname': data.utsname.sysname,
      'Nodename': data.utsname.nodename,
      'Release': data.utsname.release,
      'Version': data.utsname.version,
      'Machine': data.utsname.machine,
    };


  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context){

    List<TableRow> rows = new List<TableRow>();
    for(var key in _deviceData.keys)
    {
        var value = _deviceData[key];

        rows.add(getRow(key, "$value"));
    }
      
    return SafeArea(child: Scaffold(
      appBar: AppBar(title: Text("Device Info"),
      ),
      body: ListView(children: <Widget>[

 Table(
        
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2)
        },
        children: rows,)

      ],)  

    ),);
  }
   TableRow getRow(String title, String value)
  {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    var color = theme.dividerColor;

    var borderSide = BorderSide(color:color,width: 0.2);
   
     var valueWidget =  Text(value, style: textTheme.subtitle1);
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
}

