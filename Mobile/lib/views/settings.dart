import 'package:flutter/material.dart';
import 'package:ozbargain/helpers/apphelper.dart';
import 'package:ozbargain/models/pagetypes.dart';
import 'package:ozbargain/viewmodels/appdatamodel.dart';
import 'package:ozbargain/views/bottommenu.dart';
import 'package:ozbargain/views/customsettings.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkTheme = false;
  bool openBrowser = true;
  bool showNotifications = true;
  var _model = AppDataModel();
  @override
  void initState() {
    super.initState();

    var currentTheme = AppHelper.getCurrentTheme(context);

    darkTheme = currentTheme == "Dark";
    openBrowser = _model.settings.openBrowser ?? true;
    showNotifications = _model.settings.showNotifications ?? true;
  }

  @override
  Widget build(BuildContext context) {
    var url = "http://www.omkaars.dev";
    var settingsList = CustomSettingsList(
      sections: [
        SettingsSection(
          title: 'General',
          tiles: [
            SettingsTile.switchTile(
              title: 'Dark Theme',
              leading: Icon(Icons.color_lens),
              switchValue: darkTheme,
              onToggle: (bool value) {
                setState(() {
                  darkTheme = value;

                  AppHelper.changeTheme(context, darkTheme ? "Dark" : "Light");
                });
              },
            ),
            SettingsTile.switchTile(
                leading: Icon(Icons.open_in_new),
                title: 'Open links in native browser',
                onToggle: (bool value) {
                  setState(() {
                    openBrowser = value;

                    _model.settings.openBrowser = openBrowser;
                    _model.updateSettings();
                  });
                },
                switchValue: openBrowser ?? true)
          ],
        ),
        SettingsSection(
          title: 'Alerts',
          tiles: [
            SettingsTile.switchTile(
                leading: Icon(Icons.notifications),
                title: "Show notifications",
                onToggle: (bool value) {
                  setState(() {
                    showNotifications = value;
                    _model.settings.showNotifications = showNotifications;
                    _model.updateSettings();
                  });
                },
                switchValue: showNotifications ?? true)
          ],
        ),
        SettingsSection(
          title: 'Misc',
          tiles: [
            SettingsTile(
              title: 'About',
              leading: Icon(Icons.description),
              onTap: () {
                //Navigator.pushNamed(context, "/about");
                AppHelper.showAlertMessage(context,
                    content: _getAbout());
              },
            ),
            SettingsTile(
              title: 'Device Info',
              leading: Icon(Icons.info),
              onTap: () {
                Navigator.pushNamed(context, "/deviceinfo");
              },
            ),
          ],
        )
      ],
    );

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: settingsList,
      bottomNavigationBar: BottomMenuView(pageType: PageType.Settings),
    ));
  }

  Widget _getAbout() {
    var url = "http://www.omkaars.dev";
    return Container(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("Omkaars", style: Theme.of(context).textTheme.headline6),
            InkWell(
                child: Text(url,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        .copyWith(color: Colors.blue)),
                onTap: () => {AppHelper.openUrl(context, "Omkaars", url)})
          ],
        ));
  }
}
