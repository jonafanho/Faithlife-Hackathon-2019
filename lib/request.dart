import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "main.dart";
import "localizations.dart";
import "welcome.dart";

String typeDropdownValue;
String message;
bool proximityChecked = false;
int proximityValue;
bool sexChecked = false;
String sexValue;
bool ageChecked = false;
int ageStart;
int ageEnd;
bool groupChecked = false;
String groupValue;

class RequestMeet extends StatefulWidget {
  @override
  _RequestMeetState createState() => _RequestMeetState();
}

class _RequestMeetState extends State<RequestMeet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Request"),
      ),
      body: ListView(
        padding: EdgeInsets.all(32),
        children: <Widget>[
          ListTile(
              title: Row(children: [
            Text("Type:   "),
            DropdownButton<String>(
              hint: Text(
                "Meeting Type",
                textAlign: TextAlign.center,
              ),
              style: TextStyle(
                color: Colors.black,
              ),
              value: typeDropdownValue,
              onChanged: (newValue) {
                setState(() {
                  typeDropdownValue = newValue;
                });
              },
              items: <String>['Prayer', 'Bible', 'Service', 'Chat']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: value == typeDropdownValue
                          ? Colors.deepOrange
                          : Colors.black,
                    ),
                  ),
                Text("Type:   "),
                DropdownButton<String>(
                  hint: Text(
                    "Meeting Type",
                    textAlign: TextAlign.center,
                  ),
                  style: new TextStyle(
                    color: Colors.black,
                  ),
                  value: typeDropdownValue,
                  onChanged: (String newValue) {
                    setState(() {
                      typeDropdownValue = newValue;
                    });
                  },
                  items: <String>['Prayer', 'Bible', 'Service', 'Chat']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                          color: value == typeDropdownValue
                              ? themeColour
                              : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ])),
          ListTile(
              title: Text(
            "Message",
          )),
          ListTile(
              title: TextField(
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your message...'),
            onChanged: (text) {
              message = text;
            },
          )),
          ListTile(
              title: Text(
                "Filters:",
              )),
          CheckboxListTile(
            value: proximityChecked,
            onChanged: (bool value) {
              setState(() {
                proximityChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(children: [
              Text(
                "within  ",
                style: new TextStyle(
                  color: proximityChecked
                      ? Colors.black
                      : Colors.grey,
                  ),
              ),
              Flexible(
                child: Container(
                  width: 50.0,
                  child: TextField(
                    style: new TextStyle(color: proximityChecked ? themeColour : Colors.grey),
                    enabled: proximityChecked,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      proximityValue = int.parse(text);
                    },
                  ),
                ),
              ),
              Text(
                " km",
                style: new TextStyle(
                  color: proximityChecked
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
            ]),
          ),
          CheckboxListTile(
            value: sexChecked,
            onChanged: (bool value) {
              setState(() {
                sexChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(children: [
              Text(
                "Gender:  ",
                style: new TextStyle(
                  color: sexChecked
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
              DropdownButton<String>(
                hint: Text(
                  "Sex",
                  textAlign: TextAlign.center,
                ),
                style: TextStyle(
                  color: Colors.black,
                ),
                value: sexValue,
                onChanged: sexChecked ? (String newValue) {
                  if(sexChecked) {
                    setState(() {
                      sexValue = newValue;
                    });
                  }
                } : null,
                items: <String>["Male", "Female", "None"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: value == sexValue
                            ? themeColour
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ),
          CheckboxListTile(
            value: ageChecked,
            onChanged: (bool value) {
              setState(() {
                ageChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(children: [
              Flexible(
                child: Container(
                  width: 50.0,
                  child: TextField(
                    style: new TextStyle(color: ageChecked ? themeColour : Colors.grey),
                    enabled: ageChecked,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      ageStart = int.parse(text);
                    },
                  ),
                ),
              ),
              Text(
                " years old to ",
                style: new TextStyle(
                  color: ageChecked
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
              Flexible(
                child: Container(
                  width: 50.0,
                  child: TextField(
                    style: new TextStyle(color: ageChecked ? themeColour : Colors.grey),
                    enabled: ageChecked,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      ageEnd = int.parse(text);
                    },
                  ),
                ),
              ),
              Text(
                " years old",
                style: new TextStyle(
                  color: ageChecked
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
            ]),
          ),
          CheckboxListTile(
            value: groupChecked,
            onChanged: (bool value) {
              setState(() {
                groupChecked = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(children: [
              Text(
                "Send to: ",
                style: new TextStyle(
                  color: groupChecked
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
              DropdownButton<String>(
                hint: Text(
                  "Your Groups",
                  textAlign: TextAlign.center,
                ),
                style: new TextStyle(
                  color: Colors.black,
                ),
                value: groupValue,
                onChanged: groupChecked ? (String newValue) {
                  if(groupChecked) {
                    setState(() {
                      groupValue = newValue;
                    });
                  }
                } : null,
                items: <String>["Group1", "Group2", "Group3"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        color: value == groupValue
                            ? themeColour
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ),
          RaisedButton(
            child: groupChecked && groupValue != null ?
              Text('Send to group', style: new TextStyle(color: Colors.white)) : Text('Send to all groups', style: new TextStyle(color: Colors.white)),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: () {
              // Perform some action
            },
          ),
        ],
      ),
    );
  }
}
