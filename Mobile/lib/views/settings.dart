import 'package:flutter/material.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/pagetypes.dart';
import 'package:ozbargain/viewmodels/thememodel.dart';
import 'package:ozbargain/views/bottommenu.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';


class SettingsPage extends StatefulWidget {

  SettingsPage({Key key, this.title}):super(key:key);

  final String title;
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkTheme = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var currentTheme =  AppHelper.getCurrentTheme(context);

    darkTheme = currentTheme == "Dark";
  }
  @override
  Widget build(BuildContext context) {
    return 
    SafeArea(child:Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Common',
            tiles: [
                            SettingsTile.switchTile(
                title: 'Dark Theme',
                leading: Icon(Icons.color_lens),
                switchValue: darkTheme,
                onToggle: (bool value) {
                  setState(() {
                    darkTheme = value;
                    
                    AppHelper.changeTheme(context, darkTheme?"Dark":"Light");
                  });
                },
              ),

            ],
          ),
          SettingsSection(
            title: 'Alerts',
            tiles: [
            ],
          ),
          SettingsSection(
            title: 'About',
            tiles: [
              SettingsTile(
                  title: 'Info', leading: Icon(Icons.description)),
              SettingsTile(
                  title: 'Terms & Conditions',
                  leading: Icon(Icons.collections_bookmark)),
            ],
          )
        ],
      ),
      bottomNavigationBar: BottomMenuView(pageType:PageType.Settings),
    ));
  }
}