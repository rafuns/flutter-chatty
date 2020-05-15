import 'package:chatty/screens/root_page.dart';
import 'package:chatty/screens/widgets/auth/auth.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatty',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        brightness: Brightness.light,
        accentColor: Colors.blue[700],
        // scaffoldBackgroundColor: Colors.black,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.blue[700],
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: RootPage(Auth()),
    );
  }
}
