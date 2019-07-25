import "package:flutter/material.dart";

import "main.dart";
import "localizations.dart";

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _selectedMood = moodMap[myself.getMood()];

  @override
  Widget build(BuildContext context) {
    List<String> _moodStringList = new List<String>();
    moodMap.forEach((mood, string) {
      _moodStringList.add(string);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("edit-profile")),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: DropdownButton<String>(
              hint: Text("Set your mood!"),
              value: _selectedMood,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  _selectedMood = value;
                });
              },
              items: _moodStringList.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(),
          ListTile(
            title: RaisedButton(
              onPressed: () {
                Mood _mood;
                moodMap.forEach((mood, string) {
                  if (string == _selectedMood) _mood = mood;
                });
                myself.setData(mood: _mood);
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
