import "dart:convert";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";
import "dart:math";

import "main.dart";

Future<int> init() async {
  final _prefs = await SharedPreferences.getInstance();
  int id = _prefs.getInt("nameId");
  if (id == null) return 0;
  if (!await myself._getPersonFromDatabase(id)) return 0;
  return id;
}

Future<String> _getData(String route) async {
  if (!route.startsWith("/")) route = "/" + route;
  final response = await http
      .get("https://faithlifehackathon2019.firebaseio.com" + route + ".json")
      .timeout(Duration(seconds: 10));
  if (response.statusCode == 200)
    return response.body;
  else
    return "";
}

Future _putData(String route, String body) async {
  if (!route.startsWith("/")) route = "/" + route;
  await http
      .put("https://faithlifehackathon2019.firebaseio.com" + route + ".json",
          body: body)
      .timeout(Duration(seconds: 10));
}

Future createGroup(String name) async {
  String groups = await _getData("groups");
  String roomCode;
  Random r = new Random();
  do {
    roomCode = r.nextInt(100000000).toString();
  } while (groups.contains(roomCode));
  String body = '{"name":"';
  body += name;
  body += '"}';
  await _putData("group_" + roomCode, body);
  await _putData("groups", _addToExistingJson(groups, roomCode));
  await joinGroup(roomCode);
}

Future joinGroup(String roomCode) async {
  await _addToList("group_" + roomCode + "/people", savedNameId.toString());
  await _addToList("person_" + savedNameId.toString() + "/groups", roomCode);
  if (!myself._groups.containsKey(roomCode))
    myself._groups.addAll({
      roomCode:
          json.decode(await _getData("group_" + roomCode))["name"].toString()
    });
}

/*Future leaveGroup(String roomCode) async {
  _putData("group_" + roomCode + "/people/" + savedNameId.toString(), '{}');
}*/

void getRequests() async {
  requestsOfMyGroups.clear();
  List<String> myGroups = myself._groups.keys;
  //print("5 seconds passed, pinging...");
  for (String group in myGroups) {
    String route = 'group_' + group + '/requests';
    var response = await _getData(route);
    var requestMap = json.decode(response);
    requestMap.forEach((key, value) {
      requestsOfMyGroups.add(key.toString());
    });

    //print('My Requests: ' + requestsOfMyGroups.toString());
  }
}

Future _addToList(String route, String newData) async {
  String existing = await _getData(route);
  if (existing == "null") existing = "{";
  _putData(route, _addToExistingJson(existing, newData));
}

String _addToExistingJson(String existing, String add) {
  return existing.replaceAll("}", ",") + '"' + add + '":"true"}';
}

void createMeetRequest(String meetingType, String message, int distance,
    int ageStart, int ageEnd, String sex, List<String> selectedGroups) {
  String actualSelectedGroups = selectedGroups.toString().replaceAll('[', '{"');
  actualSelectedGroups = actualSelectedGroups.replaceAll(', ', '": "true", "');
  actualSelectedGroups = actualSelectedGroups.replaceAll(']', '": "true"}');

  String route = "RequestTest4";
  String body = '{"age_lower": "' +
      ageStart.toString() +
      '", ' +
      '"age_upper": "' +
      ageEnd.toString() +
      '", ' +
      '"answered": "false", ' +
      '"distance": "' +
      distance.toString() +
      '", ' +
      '"message": "' +
      message +
      '", ' +
      '"sender": "' +
      savedNameId.toString() +
      '", ' +
      '"sex": "' +
      sex +
      '", ' +
      '"type": "' +
      meetingType +
      '", ' +
      '"groups": ' +
      actualSelectedGroups +
      '}';
  print(body);
  _putData(route, body);
}

class Person {
  String _name = "";
  int _nameId = 0;
  Mood _mood = Mood.none;
  int _birthYear = -1, _birthMonth = -1, _birthDay = -1, _phone = -1;
  Sex _sex = Sex.none;
  Map<String, String> _groups = new Map<String, String>();

  void generate(String n) {
    _nameId = DateTime.now().millisecondsSinceEpoch;
    _name = n;
    savedNameId = _nameId;
    _setPreference();
    _writeToDatabase();
  }

  void _setPreference() async {
    final _prefs = await SharedPreferences.getInstance();
    _prefs.setInt("nameId", _nameId);
  }

  String getName() {
    return _name;
  }

  Mood getMood() {
    return _mood;
  }

  Sex getSex() {
    return _sex;
  }

  DateTime getBirthday() {
    if (_birthYear > 0 && _birthMonth > 0 && _birthDay > 0)
      return DateTime(_birthYear, _birthMonth, _birthDay);
    else
      return null;
  }

  String getPhone() {
    return _phone > 0 ? _phone.toString() : "";
  }

  Map<String, String> getGroups() {
    return _groups;
  }

  void setData({
    String name,
    Mood mood,
    DateTime birthday,
    int phone,
    Sex sex,
  }) {
    if (name != null) _name = name;
    if (mood != null) _mood = mood;
    if (birthday != null) {
      _birthYear = birthday.year;
      _birthMonth = birthday.month;
      _birthDay = birthday.day;
    }
    if (phone != null) _phone = phone;
    if (sex != null) _sex = sex;
    _writeToDatabase();
  }

  Future<bool> _getPersonFromDatabase(int nameId) async {
    var data = json.decode(await _getData("person_" + nameId.toString()));
    if (data == null) return false;
    _name = data["name"];
    _nameId = nameId;
    try {
      _mood = Mood.values[int.parse(data["mood"])];
      _birthYear = int.parse(data["birthYear"]);
      _birthMonth = int.parse(data["birthMonth"]);
      _birthDay = int.parse(data["birthDay"]);
      _sex = Sex.values[int.parse(data["sex"])];
      _phone = int.parse(data["phone"]);
      data["groups"].forEach((key, value) async {
        _groups.addAll({
          key.toString(): json
              .decode(await _getData("group_" + key.toString()))["name"]
              .toString()
        });
      });
    } catch (e) {
      _mood = Mood.none;
      _birthYear = -1;
      _birthMonth = -1;
      _birthDay = -1;
      _sex = Sex.none;
      _phone = -1;
    }
    return true;
  }

  void _writeToDatabase() {
    String body = '{"name":"';
    body += _name;
    body += '","mood":"';
    body += _mood.index.toString();
    body += '","birthYear":"';
    body += _birthYear.toString();
    body += '","birthMonth":"';
    body += _birthMonth.toString();
    body += '","birthDay":"';
    body += _birthDay.toString();
    body += '","sex":"';
    body += _sex.index.toString();
    body += '","phone":"';
    body += _phone.toString();
    body += '"}';
    _putData("person_" + _nameId.toString(), body);
  }
}
