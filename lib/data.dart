import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:url_launcher/url_launcher.dart" as launcher;
import "dart:math";
import "dart:convert";
import "package:flutter/painting.dart";

import "main.dart";
import "localizations.dart";
import "profile.dart";

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

Future getLocations(BuildContext context) async {
  List<String> people = new List<String>();
  for (String group in myself._groups.keys) {
    var everyone = json.decode(await _getData("group_" + group + "/people"));
    for (var person in everyone.keys)
      if (!people.contains(person) && person != savedNameId.toString())
        people.add(person.toString());
  }
  markers.clear();
  for (String person in people) {
    var data = json.decode(await _getData("person_" + person));
    markers[MarkerId(person)] = Marker(
      markerId: MarkerId(person),
      position: LatLng(
          double.parse(data["latitude"]), double.parse(data["longitude"])),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          HSVColor.fromColor(themeColour).hue),
      infoWindow: await _getPersonDetails(context, person),
    );
  }
  markers[MarkerId("myself")] = Marker(
    markerId: MarkerId("myself"),
    position: LatLng(myself._latitude, myself._longitude),
    infoWindow: InfoWindow(
        title: myself._name +
            " (" +
            AppLocalizations.of(context).translate("me") +
            ")",
        snippet: moodMap[myself._mood],
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Profile()));
        }),
  );
}

Future<InfoWindow> _getPersonDetails(BuildContext context, String id) async {
  Person p = new Person();
  await p._getPersonFromDatabase(int.parse(id));
  return InfoWindow(
    title: p._name,
    snippet: moodMap[p._mood],
    onTap: () {
      String phone = p._phone > 0
          ? p._phone.toString()
          : "(" + AppLocalizations.of(context).translate("no-phone") + ")";
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(p._name + " " + moodMap[p._mood].substring(0, 2)),
          content: ListTile(
            leading: IconButton(
              icon: Icon(Icons.phone),
              onPressed: p._phone > 0
                  ? () {
                      launcher.launch("tel:" + phone);
                    }
                  : null,
            ),
            title: Text(p._groups.values.toString()),
            subtitle: Text(phone),
            trailing: IconButton(
              icon: Icon(Icons.sms),
              onPressed: p._phone > 0
                  ? () {
                      launcher.launch("sms:" + phone);
                    }
                  : null,
            ),
            contentPadding: EdgeInsets.zero,
            isThreeLine: true,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).translate("ok")),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      );
    },
  );
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

Future getRequestsToMe() async {
  //print(
  //"----------------------------------------------------------------------------------------");

  List<String> requestsOfMyGroups = new List<String>();
  //print("10 seconds passed, pinging...");
  requestsOfMyGroups.clear();

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
        if (!requestsOfMyGroups.contains(key.toString()))
          requestsOfMyGroups.add(key.toString());
      });
      //print('Requests from my Groups: ' + requestsOfMyGroups.toString());
    }
  }

  List<Request> _requestsForMe = new List<Request>();
  _requestsForMe.clear();

  //Getting all requests that match me
  for (String request in requestsOfMyGroups) {
    String route = 'request_' + request;
    String response = await _getData(route);
    //print("Reponse: " + response);
    if (response == "null") continue;
    var requestMap = json.decode(response);

    int birthYear = myself._birthYear;
    int birthMonth = myself._birthMonth;
    int birthDay = myself._birthDay;
    if ((birthYear <= 0 || birthMonth <= 0 || birthDay <= 0) &&
        (requestMap.containsKey("age_lower") ||
            requestMap.containsKey("age_upper"))) continue;
    int myAge = calculateAge(birthYear, birthMonth, birthDay);
    if (requestMap.containsKey("age_lower") &&
        int.parse(requestMap["age_lower"]) > myAge) {
      continue;
      //print("Age lower doesn't fit you");
    }
    if (requestMap.containsKey("age_upper") &&
        int.parse(requestMap["age_upper"]) < myAge) {
      continue;
      //print("Age upper doesn't fit you");
    }

    if (myself._sex.index == 0 && requestMap["sex"] != 0) continue;
    if (myself._sex.index != 0 &&
        requestMap["sex"] != 0 &&
        myself._sex.index != requestMap["sex"]) {
      continue;
      //print("Sex doesn't fit you");
    }

    //Get the sender's name
    if (int.parse(requestMap["sender"]) != savedNameId) {
      String personRoute = 'person_' + requestMap["sender"].toString();
      String personResponse = await _getData(personRoute);
      var personMap = json.decode(personResponse);
      if (personResponse != "null" && personMap.containsKey("name")) {
        String name = personMap["name"].toString();
        String message = requestMap["message"].toString();
        String type = requestMap["type"].toString();
        int id = int.parse(request);

        Request newRequestForMe = new Request(name, message, type, id);
        _requestsForMe.add(newRequestForMe);
      }
    }
  }

  requestsForMe = _requestsForMe;
  /*for (Request r in _requestsForMe) {
    print("FOUND REQUEST(S) FOR ME {name: " +
        r.getName() +
        " || message: " +
        r.getMessage() +
        " || type: " +
        r.getType() +
        '}');
  }*/
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
  if (s.length == 0) return "crash";
  String body = "";
  s.forEach((value) {
    body += '"' + value + '":"true",';
  });
  body = body.substring(0, body.length - 1);
  return "{" + body + "}";
}

void createMeetRequest(String meetingType, String message, int distance,
    int ageLower, int ageUpper, int sex, List<String> selectedGroups) async {
  String requestId = DateTime.now().millisecondsSinceEpoch.toString();
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
  body += '"sex":"' + sex.toString() + '",';
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
  int _id = 0;

  Request(String name, String message, String type, int id) {
    this._name = name;
    this._message = message;
    this._type = type;
    this._id = id;
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

  int getId() {
    return _id;
  }
}

class Person {
  String _name = "";
  int _nameId = 0;
  Mood _mood = Mood.none;
  int _birthYear = -1, _birthMonth = -1, _birthDay = -1, _phone = -1;
  Sex _sex = Sex.none;
  Map<String, String> _groups = new Map<String, String>();
  double _latitude = 0, _longitude = 0;

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

  void setData(
      {String name,
      Mood mood,
      DateTime birthday,
      int phone,
      Sex sex,
      double latitude,
      double longitude}) {
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
    if (latitude != null) _latitude = latitude;
    if (longitude != null) _longitude = longitude;
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
    body += '","latitude":"';
    body += _latitude.toString();
    body += '","longitude":"';
    body += _longitude.toString();
    body += '","groups":';
    body += listToJson(_groups.keys.toList());
    body += "}";
    _putData("person_" + _nameId.toString(), body);
  }
}
