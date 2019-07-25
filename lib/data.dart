import "dart:convert";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

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

void _putData(String route, String body) async {
  if (!route.startsWith("/")) route = "/" + route;
  await http
      .put("https://faithlifehackathon2019.firebaseio.com" + route + ".json",
          body: body)
      .timeout(Duration(seconds: 10));
}

class Person {
  String _name = "";
  int _nameId = 0;
  Mood _mood = Mood.none;
  int _birthYear = -1, _birthMonth = -1, _birthDay = -1, _phone = -1;
  Sex _sex = Sex.none;

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

  String getPhone() {
    return _phone > 0 ? _phone.toString() : "A child of God";
  }

  void setData({
    String name,
    Mood mood,
    int birthYear,
    int birthMonth,
    int birthDay,
    int phone,
  }) {
    if (name != null) _name = name;
    if (mood != null) _mood = mood;
    if (birthYear != null) _birthYear = birthYear;
    if (birthMonth != null) _birthMonth = birthMonth;
    if (birthDay != null) _birthDay = birthDay;
    if (phone != null) _phone = phone;
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
    } catch (e) {
      _mood = Mood.none;
      _birthYear = -1;
      _birthMonth = -1;
      _birthDay = -1;
      _sex = Sex.none;
      _phone = -1;
    }
    print(data);
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
