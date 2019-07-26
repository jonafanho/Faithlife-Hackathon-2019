import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "dart:convert";

import "main.dart";
import "localizations.dart";
import "data.dart";

enum WelcomeChoice { joinRoom, createGroup }

class CreateJoinGroup extends StatelessWidget {
  CreateJoinGroup({@required this.askName});

  final bool askName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("welcome") +
            " Faithlife Meets!"),
      ),
      body: askName ? _NamePhoneList() : _CreateJoinGroupList(),
    );
  }
}

class _CreateJoinGroupList extends StatefulWidget {
  @override
  _CreateJoinGroupListState createState() => _CreateJoinGroupListState();
}

class _CreateJoinGroupListState extends State<_CreateJoinGroupList> {
  WelcomeChoice _choice = WelcomeChoice.joinRoom;
  bool _buttonEnabled = false;
  String _text = "";

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate("create-join"),
            style: TextStyle(fontSize: 20),
          ),
        ),
        RadioListTile<WelcomeChoice>(
          value: WelcomeChoice.joinRoom,
          groupValue: _choice,
          onChanged: (value) {
            setState(() {
              _choice = value;
            });
          },
          title: Text(AppLocalizations.of(context).translate("join-room")),
        ),
        RadioListTile<WelcomeChoice>(
          value: WelcomeChoice.createGroup,
          groupValue: _choice,
          onChanged: (value) {
            setState(() {
              _choice = value;
            });
          },
          title: Text(AppLocalizations.of(context).translate("create-group")),
        ),
        SizedBox(height: 64),
        ListTile(
          title: TextField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate(
                  _choice == WelcomeChoice.joinRoom
                      ? "room-code"
                      : "group-name"),
              enabled: true,
            ),
            autocorrect: false,
            maxLength: _choice == WelcomeChoice.joinRoom ? 8 : 100,
            onChanged: (value) {
              _text = value;
              setState(() {
                _buttonEnabled = value.length > 0;
              });
            },
          ),
        ),
        ListTile(
          title: RaisedButton(
            onPressed: _buttonEnabled
                ? () async {
                    switch (_choice) {
                      case WelcomeChoice.createGroup:
                        await createGroup(_text);
                        break;
                      case WelcomeChoice.joinRoom:
                        await joinGroup(_text);
                        break;
                    }
                    while (Navigator.canPop(context)) Navigator.pop(context);
                  }
                : null,
            textColor: Colors.white,
            color: themeColour,
            child: Text(AppLocalizations.of(context).translate("submit")),
          ),
        ),
      ],
    );
  }
}

class _NamePhoneList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String _name = "";
    return ListView(
      children: <Widget>[
        ListTile(
          title: TextField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("name"),
              enabled: true,
            ),
            autofocus: true,
            autocorrect: false,
            maxLength: 100,
            onChanged: (text) {
              _name = text;
            },
          ),
        ),
        ListTile(
          title: RaisedButton(
            onPressed: () {
              if (_name == "")
                showErrorDialog(
                    context,
                    AppLocalizations.of(context).translate("name-error-title"),
                    AppLocalizations.of(context).translate("name-error-text"));
              else {
                myself.generate(_name);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateJoinGroup(
                              askName: false,
                            )));
              }
            },
            textColor: Colors.white,
            color: themeColour,
            child: Text(AppLocalizations.of(context).translate("next")),
          ),
        ),
      ],
    );
  }
}
