import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:url_launcher/url_launcher.dart" as launcher;
import "package:location/location.dart";

import "localizations.dart";
import "data.dart";
import "welcome.dart";
import "request.dart";

Color themeColour = Colors.deepOrange;
int savedNameId = 0;
Person myself = new Person();

enum Mood { happy, thankful, sad, angry, none }
enum Sex { none, male, female }

Future main() async {
  savedNameId = await init();
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
  @override
  Widget build(BuildContext context) {
    return savedNameId == 0
        ? CreateJoinGroup(
            askName: true,
          )
        : Scaffold(
            appBar: AppBar(
                title: Text(AppLocalizations.of(context).translate("home"))),
            body: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(47.649281, -122.358524), zoom: 10),
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
                  currentAccountPicture: CircleAvatar(
                    child: Text(
                        myself.getName() != ""
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
                  onPressed: () {},
                  heroTag: null,
                  tooltip: "Centre map",
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
                  tooltip: "Create a request",
                  child: Icon(Icons.add),
                ),
              ],
            ),
          );
  }
}
