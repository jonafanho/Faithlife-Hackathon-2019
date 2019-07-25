import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:url_launcher/url_launcher.dart" as launcher;
import "package:location/location.dart";

import "localizations.dart";
import "data.dart";
import "welcome.dart";
import "request.dart";
import "profile.dart";

Color themeColour = Colors.deepOrange;
int savedNameId = 0;
Person myself = new Person();
LatLng _pos = LatLng(47.649281, -122.358524);
Map<Mood, String> moodMap;

enum Mood { happy, thankful, sad, angry, none }
enum Sex { none, male, female }

Future main() async {
  savedNameId = await init();
  var location = new Location();
  location.changeSettings(
      accuracy: LocationAccuracy.POWERSAVE, interval: 20000);
  location.onLocationChanged().listen((LocationData currentLocation) {
    _pos = LatLng(currentLocation.latitude, currentLocation.longitude);
    print("(" +
        currentLocation.latitude.toString() +
        " " +
        currentLocation.longitude.toString() +
        ") " +
        currentLocation.time.toString());
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Faithlife Meets",
      theme: ThemeData(primarySwatch: themeColour),
      home: MyHomePage(),
      supportedLocales: [Locale("en"), Locale("zh")],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales)
          if (supportedLocale.languageCode == "en") //locale?.languageCode)
            return supportedLocale;
        return supportedLocales.first;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    moodMap = {
      Mood.happy:
          "🙂 " + AppLocalizations.of(context).translate("emotion-happy"),
      Mood.thankful:
          "😍 " + AppLocalizations.of(context).translate("emotion-thankful"),
      Mood.sad: "😞 " + AppLocalizations.of(context).translate("emotion-sad"),
      Mood.angry:
          "😠 " + AppLocalizations.of(context).translate("emotion-angry"),
      Mood.none: AppLocalizations.of(context).translate("emotion-none"),
    };
    return savedNameId == 0
        ? CreateJoinGroup(
            askName: true,
          )
        : Scaffold(
            appBar: AppBar(
                title: Text(AppLocalizations.of(context).translate("home"))),
            body: GoogleMap(
              onMapCreated: (controller) {
                _controller = controller;
              },
              initialCameraPosition: CameraPosition(target: _pos, zoom: 10),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
            drawer: Drawer(
                child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(myself.getName()),
                  accountEmail: Text(myself.getPhone()),
                  onDetailsPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Profile()));
                  },
                  currentAccountPicture: CircleAvatar(
                    child: Text(
                        myself.getMood() != Mood.none
                            ? moodMap[myself.getMood()].substring(0, 2)
                            : myself.getName() != ""
                                ? myself.getName().substring(0, 1).toUpperCase()
                                : "",
                        style: TextStyle(fontSize: 40)),
                  ),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).translate("home")),
                  leading: Icon(Icons.home),
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                      AppLocalizations.of(context).translate("create-join")),
                  leading: Icon(Icons.group_add),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateJoinGroup(
                                  askName: false,
                                )));
                  },
                ),
                ListTile(
                  title: Text(
                      AppLocalizations.of(context).translate("address-book")),
                  leading: Icon(Icons.contacts),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Divider(),
                ListTile(
                  title:
                      Text(AppLocalizations.of(context).translate("settings")),
                  leading: Icon(Icons.settings),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).translate("help")),
                  leading: Icon(Icons.help),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("You don't need help."),
                        content: Text("You're smart!"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                                AppLocalizations.of(context).translate("ok")),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            )),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black54,
                  onPressed: () {
                    centre();
                  },
                  heroTag: null,
                  tooltip: AppLocalizations.of(context).translate("centre-map"),
                  child: Icon(Icons.my_location),
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => RequestMeet()));
                  },
                  tooltip: AppLocalizations.of(context).translate("create-request"),
                  child: Icon(Icons.add),
                ),
              ],
            ),
          );
  }

  void centre() async {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: _pos,
      zoom: 15,
    )));
  }
}
