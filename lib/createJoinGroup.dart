import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "main.dart";
import "localizations.dart";

class CreateJoinGroup extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("welcome") +
            " Faithlife Meets!"),
      ),
      body: ListView(
        padding: EdgeInsets.all(32),
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate("create-join"),
            style: TextStyle(fontSize: 16),
          ),
          Radio(value: 0, groupValue: 1, onChanged: (value) {}),
          TextField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("room-code"),
              enabled: true,
            ),
            autofocus: true,
            autocorrect: false,
            maxLength: 8,
          ),
          Radio(value: 0, groupValue: 1, onChanged: (value) {}),
          TextField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("group-name"),
              enabled: true,
            ),
            autocorrect: false,
            maxLength: 100,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            textColor: Colors.white,
            color: themeColour,
            child: Text(AppLocalizations.of(context).translate("next")),
          ),
        ],
      ),
    );
  }
}

class NamePhone extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("welcome") +
            " Faithlife Meets!"),
      ),
      body: ListView(
        padding: EdgeInsets.all(32),
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate("create-join"),
            style: TextStyle(fontSize: 16),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("name"),
              enabled: true,
            ),
            autofocus: true,
            autocorrect: false,
            maxLength: 100,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("phone"),
              enabled: true,
            ),
            autocorrect: false,
            maxLength: 20,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            textColor: Colors.white,
            color: themeColour,
            child: Text(AppLocalizations.of(context).translate("next")),
          ),
        ],
      ),
    );
  }
}
