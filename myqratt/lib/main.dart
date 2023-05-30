import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 import 'package:myqratt/home.dart';
import 'package:myqratt/ui/dashboard.dart';
  //import 'package:mysql1/mysql1.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MaterialApp(
      title: 'QrAtt',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(34, 34, 34, 1.0),
        accentColor: Color.fromRGBO(15, 156, 213, 1.0),
      ),
      home: Dashboard(),
    ),
  );
}
