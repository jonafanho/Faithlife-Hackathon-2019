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


class RequestMeet extends StatefulWidget {
  @override
  _RequestMeetState createState() => _RequestMeetState();
}

class _RequestMeetState extends State<RequestMeet> {
  // This widget is the root of your application.
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
              title: Text(
                "[Group Name]",
              )),
          ListTile(
              title: Row(children: [
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
                              ? Colors.deepOrange
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
                "Filters",
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
              Text("within  "),
              Flexible(
                child: new Container(
                  width: 50.0,
                  child: TextField(
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(4),
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      proximityValue = int.parse(text);
                    },
                  ),
                ),
              ),
              Text(" km"),
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
              Text("Gender:  "),
              DropdownButton<String>(
                hint: Text(
                  "Sex",
                  textAlign: TextAlign.center,
                ),
                style: new TextStyle(
                  color: Colors.black,
                ),
                value: sexValue,
                onChanged: (String newValue) {
                  setState(() {
                    sexValue = newValue;
                  });
                },
                items: <String>["Male", "Female", "None"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        color: value == sexValue
                            ? Colors.deepOrange
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
                child: new Container(
                  width: 50.0,
                  child: TextField(
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      ageStart = int.parse(text);
                    },
                  ),
                ),
              ),
              Text(" years old to "),
              Flexible(
                child: new Container(
                  width: 50.0,
                  child: TextField(
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      ageEnd = int.parse(text);
                    },
                  ),
                ),
              ),
              Text(" years old"),
            ]),
          ),
        ],
      ),
    );
  }
}
