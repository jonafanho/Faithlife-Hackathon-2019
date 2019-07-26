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
  String _request;
  String _message = "";
  bool _distanceChecked = false;
  int _distance = -1;
  String _sexValue;
  bool _ageLowerChecked = false, _ageUpperChecked = false;
  int _ageLower, _ageUpper;
  bool _groupChecked = false;
  String _selectedGroup;

  @override
  Widget build(BuildContext context) {
    List<String> _requestList = [
      AppLocalizations.of(context).translate("request-prayer"),
      AppLocalizations.of(context).translate("request-bible"),
      AppLocalizations.of(context).translate("request-service"),
      AppLocalizations.of(context).translate("request-chat")
    ];
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
            title: DropdownButton<String>(
              hint:
                  Text(AppLocalizations.of(context).translate("request-type")),
              value: _request,
              onChanged: (String newValue) {
                setState(() {
                  _request = newValue;
                });
              },
              isExpanded: true,
              items: _requestList.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
            value: _distanceChecked,
            onChanged: (bool value) {
              setState(() {
                _distanceChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(
              children: [
                Text(
                  "within  ",
                  style: TextStyle(
                    color: _distanceChecked ? Colors.black : Colors.grey,
                  ),
                ),
                Flexible(
                  child: Container(
                    width: 50.0,
                    child: TextField(
                      style: TextStyle(
                        color: _distanceChecked ? themeColour : Colors.grey,
                      ),
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
                    color: _distanceChecked ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          CheckboxListTile(
            value: _ageLowerChecked,
            onChanged: (bool value) {
              setState(() {
                _ageLowerChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(children: [
              Text(
                AppLocalizations.of(context).translate("at-least") + " ",
                style: TextStyle(
                  color: _ageLowerChecked ? Colors.black : Colors.grey,
                ),
              ),
              Flexible(
                child: Container(
                  width: 50.0,
                  child: TextField(
                    style: TextStyle(
                      color: _ageLowerChecked ? themeColour : Colors.grey,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      _ageLower = int.parse(text);
                    },
                  ),
                ),
              ),
              Text(
                " " + AppLocalizations.of(context).translate("years-old"),
                style: TextStyle(
                  color: _ageLowerChecked ? Colors.black : Colors.grey,
                ),
              ),
            ]),
          ),
          CheckboxListTile(
            value: _ageUpperChecked,
            onChanged: (bool value) {
              setState(() {
                _ageUpperChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(children: [
              Text(
                AppLocalizations.of(context).translate("at-most") + " ",
                style: TextStyle(
                  color: _ageUpperChecked ? Colors.black : Colors.grey,
                ),
              ),
              Flexible(
                child: Container(
                  width: 50.0,
                  child: TextField(
                    style: TextStyle(
                      color: _ageUpperChecked ? themeColour : Colors.grey,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      _ageUpper = int.parse(text);
                    },
                  ),
                ),
              ),
              Text(
                " " + AppLocalizations.of(context).translate("years-old"),
                style: TextStyle(
                  color: _ageUpperChecked ? Colors.black : Colors.grey,
                ),
              ),
            ]),
          ),
          ListTile(
            leading: Text(AppLocalizations.of(context).translate("sex")),
            title: DropdownButton<String>(
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
          CheckboxListTile(
            value: _groupChecked,
            onChanged: (bool value) {
              setState(() {
                _groupChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(children: [
              Text(
                AppLocalizations.of(context).translate("send-only") + " ",
                style: TextStyle(
                  color: _groupChecked ? Colors.black : Colors.grey,
                ),
              ),
              Flexible(
                child: DropdownButton<String>(
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
                      child: Text(
                        value,
                        style: TextStyle(
                          color: _groupChecked ? themeColour : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ]),
          ),
          ListTile(
            title: RaisedButton(
              child: Text(AppLocalizations.of(context).translate("send-to") +
                  " " +
                  (_groupChecked
                      ? '"' + _selectedGroup + '"'
                      : AppLocalizations.of(context).translate("all-groups"))),
              textColor: Colors.white,
              color: themeColour,
              onPressed: _message == "" || _request == null
                  ? null
                  : () {
                      List<String> _groupList = new List<String>();
                      if (_groupChecked)
                        _groupList.add(
                            getKeyFromMap(myself.getGroups(), _selectedGroup));
                      else
                        _groupList.addAll(myself.getGroups().keys);
                      createMeetRequest(
                          _request,
                          _message,
                          _distanceChecked ? _distance : 0,
                          _ageLowerChecked ? _ageLower : null,
                          _ageUpperChecked ? _ageUpper : null,
                          _sexValue == sexStringList.first ? null : _sexValue,
                          _groupList);
                      Navigator.pop(context);
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class ViewRequest extends StatefulWidget {
  @override
  _ViewRequestState createState() => _ViewRequestState();
}

class _ViewRequestState extends State<ViewRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Requests'),
      ),
      body: ListView.builder(
          itemCount: (requestsForMe.length),
          itemBuilder: (BuildContext context, int i) {
            return ListTile(
              title: Text(
                requestsForMe[i].getName(),
                style: TextStyle(color: themeColour, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            );
          }),
    );
  }
}
