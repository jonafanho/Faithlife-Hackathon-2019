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
        title: Text(AppLocalizations.of(context).translate("create-join")),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          ListTile(
            title: TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate("name"),
                hintText: AppLocalizations.of(context).translate("name-details"),
                enabled: true,
              ),
              autofocus: true,
              autocorrect: false,
              maxLength: 100,
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).translate("phone")),
            subtitle: TextField(
              enabled: true,
              autocorrect: false,
              maxLength: 20,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              keyboardType: TextInputType.number,
            ),
          ),
          ListTile(
            title: RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              textColor: Colors.white,
              color: themeColour,
              child: Text(AppLocalizations.of(context).translate("submit")),
            ),
          ),
        ],
      ),
    );
  }
}
