import "package:flutter/material.dart";

import "localizations.dart";

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("edit-profile")),
      ),
      body: ListView(
        children: <Widget>[
          DropdownButton(items: [], onChanged: null),
        ],
      ),
    );
  }
}
