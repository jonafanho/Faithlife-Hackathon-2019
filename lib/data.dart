import "dart:convert";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "main.dart";

Future<int> init() async {
  final _prefs = await SharedPreferences.getInstance();
  int id = _prefs.getInt("nameId");
  if (id == null) return 0;
  return id;
}

Future<String> _getData(String method) async {
  if (!method.startsWith("/")) method = "/" + method;
  final response = await http
      .get("https://faithlifehackathon2019.firebaseio.com" + method + ".json")
      .timeout(Duration(seconds: 10));
  if (response.statusCode == 200)
    return response.body;
  else
    return "";
}

void _putData(String method, String body) async {
  if (!method.startsWith("/")) method = "/" + method;
  await http.put(
      "https://faithlifehackathon2019.firebaseio.com" + method + ".json",
      body: body);
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

  void getPersonFromDatabase(int nameId) async {
    var data = json.decode(await _getData("person_" + nameId.toString()));
    print(data);
  }

  void _writeToDatabase() {
    String body = '{"name":"';
    body += _name;
    body += '","mood":"';
    body += _mood.toString();
    body += '","birthYear":"';
    body += _birthYear.toString();
    body += '","birthMonth":"';
    body += _birthMonth.toString();
    body += '","birthDay":"';
    body += _birthDay.toString();
    body += '","sex":"';
    body += _sex.toString();
    body += '","phone":"';
    body += _phone.toString();
    body += '"}';
    _putData("person_" + _nameId.toString(), body);
  }
}
