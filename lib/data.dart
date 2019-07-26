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

Future<String> createGroup(String name) async {
  String groups = await _getData("groups");
  if (groups == "null") groups = "{";
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
  return name + "\n\n(" + roomCode + ")";
}

Future<String> joinGroup(String roomCode) async {
  String raw = await _getData("group_" + roomCode);
  if (raw == "null") return null;
  String name = json.decode(raw)["name"].toString();
  await _addToList("group_" + roomCode + "/people", savedNameId.toString());
  await _addToList("person_" + savedNameId.toString() + "/groups", roomCode);
  if (!myself._groups.containsKey(roomCode))
    myself._groups.addAll({roomCode: name});
  return name;
}

/*Future leaveGroup(String roomCode) async {
  _putData("group_" + roomCode + "/people/" + savedNameId.toString(), '{}');
}*/

void getRequestsToMe() async {
  print(
      "----------------------------------------------------------------------------------------");
  //print("10 seconds passed, pinging...");
  requestsOfMyGroups.clear();
  requestsForMe.clear();

  //Getting all of my groups
  List<String> myGroups = new List<String>();
  myself._groups.forEach((key, value) {
    myGroups.add(key);
  });

  //print("myGroups: " + myGroups.toString());

  //Getting all requests in my groups
  for (String group in myGroups) {
    String route = 'group_' + group + '/requests';
    String response = await _getData(route);

    if (response != "null") {
      var requestMap = json.decode(response);
      requestMap.forEach((key, value) {
        requestsOfMyGroups.add(key.toString());
      });
      //print('Requests from my Groups: ' + requestsOfMyGroups.toString());
    }
  }

  //Getting all requests that match me
  for (String request in requestsOfMyGroups) {
    String route = 'request_'+request;
    String response = await _getData(route);
    //print("Reponse: " + response);
    if (response != "null") {
      var requestMap = json.decode(response);
      bool fitsMe = true;

      int birthYear = myself._birthYear;
      int birthMonth = myself._birthMonth;
      int birthDay = myself._birthDay;
      int myAge = calculateAge(birthYear, birthMonth, birthDay);

      if (requestMap.containsKey("age_lower") &&
          requestMap["age_lower"] > myAge) {
        fitsMe = false;
        print("Age lower doesn't fit you");
      }

      if (requestMap.containsKey("age_upper") &&
          requestMap["age_upper"] < myAge) {
        fitsMe = false;
        print("Age upper doesn't fit you");
      }

      if (requestMap.containsKey("sex") &&
          requestMap["sex"] != 0 &&
          requestMap["sex"].toString() != myself._sex.index.toString()) {
        fitsMe = false;
        print("Sex doesn't fit you");
      }

      //Get the sender's name
      if (fitsMe && requestMap.containsKey("sender") && int.parse(requestMap["sender"]) != savedNameId && requestMap.containsKey("type")) {
        String personRoute = 'person_' + requestMap["sender"].toString();
        String personResponse = await _getData(personRoute);
        var personMap = json.decode(personResponse);
        if (personResponse != "null" && personMap.containsKey("name")) {
          String name = personMap["name"];
          String message = requestMap["message"];
          String type = requestMap["type"];

          Request newRequestForMe = new Request(name, message, type);
          requestsForMe.add(newRequestForMe);
        }
      }
    }
  }

  for (Request r in requestsForMe) {
    print("FOUND REQUEST(S) FOR ME {name: " +
        r.getName() +
        " || message: " +
        r.getMessage() +
        " || type: " +
        r.getType()+
        '}');
  }
}

int calculateAge(int year, int month, int day) {
  DateTime currentDate = DateTime.now();
  int age = currentDate.year - year;
  int month1 = currentDate.month;
  int month2 = month;
  if (month2 > month1) {
    age--;
  } else if (month1 == month2) {
    int day1 = currentDate.day;
    int day2 = day;
    if (day2 > day1) {
      age--;
    }
  }
  return age;
}

Future _addToList(String route, String newData) async {
  String existing = await _getData(route);
  if (existing == "null") existing = "{";
  _putData(route, _addToExistingJson(existing, newData));
}

String _addToExistingJson(String existing, String add) {
  return existing.replaceAll("}", ",") + '"' + add + '":"true"}';
}

String listToJson(List<String> s) {
  String body = "";
  s.forEach((value) {
    body += '"' + value + '":"true",';
  });
  body = body.substring(0, body.length - 1);
  return "{" + body + "}";
}

void createMeetRequest(String meetingType, String message, int distance,
    int ageLower, int ageUpper, String sex, List<String> selectedGroups) async {
  String requestId = DateTime.now().millisecondsSinceEpoch.toString();
  requestId = requestId.substring(4, requestId.length);
  String body = '{';
  if (meetingType != null) {
    body += '"type":"';
    body += meetingType;
    body += '",';
  }
  if (distance > 0) {
    body += '"distance":"';
    body += distance.toString();
    body += '",';
  }
  if (ageLower != null) {
    body += '"age-lower":"';
    body += ageLower.toString();
    body += '",';
  }
  if (ageUpper != null) {
    body += '"age-upper":"';
    body += ageUpper.toString();
    body += '",';
  }
  if (sex != null) {
    body += '"sex":"';
    body += sex;
    body += '",';
  }
  body += '"groups":' + listToJson(selectedGroups) + ",";
  body += '"sender":"' + savedNameId.toString() + '",';
  body += '"message":"' + message + '"}';
  await _putData("request_" + requestId, body);
  for (String group in selectedGroups)
    await _addToList("group_" + group + "/requests", requestId);
}

class Request {
  String _name = "";
  String _message = "";
  String _type = "";

  Request(String name, String message, String type) {
    this._name = name;
    this._message = message;
    this._type = type;
  }

  String getName() {
    return _name;
  }

  String getMessage() {
    return _message;
  }

  String getType() {
    return _type;
  }
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
    } else
      _birthYear = _birthMonth = _birthDay = -1;
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
    body += '","groups":';
    body += listToJson(_groups.keys);
    body += "}";
    _putData("person_" + _nameId.toString(), body);
  }
}
