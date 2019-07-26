import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "main.dart";
import "localizations.dart";

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("settings")),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(AppLocalizations.of(context).translate("language")),
            subtitle: Text(
                AppLocalizations.of(context).translate("language-" + language) +
                    (startLanguage != language
                        ? " (" +
                            AppLocalizations.of(context).translate("restart") +
                            ")"
                        : "")),
            onTap: () async {
              setState(() {
                if (language == "en")
                  language = "zh";
                else
                  language = "en";
              });
              final _prefs = await SharedPreferences.getInstance();
              _prefs.setString("language", language);
            },
          ),
        ],
      ),
    );
  }
}
