import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "main.dart";
import "localizations.dart";
import "welcome.dart";
import "data.dart";

class RequestMeet extends StatefulWidget {
  @override
  _RequestMeetState createState() => _RequestMeetState();
}

class _RequestMeetState extends State<RequestMeet> {
  String _meetingTypeValue;
  String _message = "";
  bool _proximityChecked = false;
  int _distance = -1;
  String _sexValue;
  bool _ageStartChecked = false, _ageEndChecked = false;
  int _ageStart, _ageEnd;
  String _selectedGroup;

  @override
  Widget build(BuildContext context) {
    if (_sexValue == null) _sexValue = sexStringList.first;
    if (_selectedGroup == null)
      _selectedGroup = myself.getGroups().values.first;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("create-request")),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Row(
              children: [
                Text(AppLocalizations.of(context).translate("type")),
                SizedBox(width: 16),
                DropdownButton<String>(
                  hint: Text(
                    "Meeting Type",
                    textAlign: TextAlign.center,
                  ),
                  value: _meetingTypeValue,
                  onChanged: (String newValue) {
                    setState(() {
                      _meetingTypeValue = newValue;
                    });
                  },
                  items: <String>['Prayer', 'Bible', 'Service', 'Chat']
                      .map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: value == _meetingTypeValue
                              ? themeColour
                              : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          ListTile(
            title: TextField(
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    AppLocalizations.of(context).translate("enter-message"),
              ),
              onChanged: (text) {
                _message = text;
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).translate("filters")),
          ),
          CheckboxListTile(
            value: _proximityChecked,
            onChanged: (bool value) {
              setState(() {
                _proximityChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(
              children: [
                Text(
                  "within  ",
                  style: TextStyle(
                    color: _proximityChecked ? Colors.black : Colors.grey,
                  ),
                ),
                Flexible(
                  child: Container(
                    width: 50.0,
                    child: TextField(
                      style: TextStyle(
                        color: _proximityChecked ? themeColour : Colors.grey,
                      ),
                      enabled: _proximityChecked,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        _distance = int.parse(text);
                      },
                    ),
                  ),
                ),
                Text(
                  " km",
                  style: TextStyle(
                    color: _proximityChecked ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          CheckboxListTile(
            value: _ageStartChecked,
            onChanged: (bool value) {
              setState(() {
                _ageStartChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(children: [
              Text(
                AppLocalizations.of(context).translate("at-least") + " ",
                style: TextStyle(
                  color: _ageStartChecked ? Colors.black : Colors.grey,
                ),
              ),
              Flexible(
                child: Container(
                  width: 50.0,
                  child: TextField(
                    enabled: _ageStartChecked,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      _ageStart = int.parse(text);
                    },
                  ),
                ),
              ),
              Text(
                " " + AppLocalizations.of(context).translate("years-old"),
                style: TextStyle(
                  color: _ageStartChecked ? Colors.black : Colors.grey,
                ),
              ),
            ]),
          ),
          CheckboxListTile(
            value: _ageEndChecked,
            onChanged: (bool value) {
              setState(() {
                _ageEndChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(children: [
              Text(
                AppLocalizations.of(context).translate("at-most") + " ",
                style: TextStyle(
                  color: _ageEndChecked ? Colors.black : Colors.grey,
                ),
              ),
              Flexible(
                child: Container(
                  width: 50.0,
                  child: TextField(
                    enabled: _ageEndChecked,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      _ageEnd = int.parse(text);
                    },
                  ),
                ),
              ),
              Text(
                " " + AppLocalizations.of(context).translate("years-old"),
                style: TextStyle(
                  color: _ageEndChecked ? Colors.black : Colors.grey,
                ),
              ),
            ]),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).translate("sex")),
            subtitle: DropdownButton<String>(
              value: _sexValue,
              onChanged: (newValue) {
                setState(() {
                  _sexValue = newValue;
                });
              },
              isExpanded: true,
              items: sexStringList.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          ListTile(
            title: Text("Target:"),
            subtitle: DropdownButton<String>(
              value: _selectedGroup,
              onChanged: (String newValue) {
                setState(() {
                  _selectedGroup = newValue;
                });
              },
              isExpanded: true,
              items: myself
                  .getGroups()
                  .values
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          ListTile(
            title: RaisedButton(
              child: Text('Send to "' + _selectedGroup + '"'),
              textColor: Colors.white,
              color: themeColour,
              onPressed: () {
                List<String> _groupList = new List<String>();
                _groupList.add(_selectedGroup);
                createMeetRequest(_meetingTypeValue, _message, _distance,
                    _ageStart, _ageEnd, _sexValue, _groupList);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
