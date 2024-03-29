import 'package:demo/demos/ime_switcher_demo.dart';
import 'package:demo/demos/input_action_demo.dart';
import 'package:demo/demos/menk_ime_demo.dart';
import 'package:flutter/material.dart';
import 'package:menk_embed_ime_db/menk_embed_ime_db.dart';
import 'package:zcode_embed_ime_db/zcode_embed_ime_db.dart';
import 'package:mongol/mongol.dart';

import 'demos/zcode_ime_demo.dart';

void main() {
  runApp(const DemoApp());
  initZcodeDB();
  initMenkDB();
}

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MongolTextEditingShortcuts(child: child),
      title: 'Embed IME Demo',
      theme: ThemeData(),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Embed IME Demo')),
        body: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const <Widget>[
        DemoTile(
          title: 'Zcode Ime Demo',
          destination: ZcodeImeDemo(),
        ),
        DemoTile(
          title: 'Menk Ime Demo',
          destination: MenkImeDemo(),
        ),
        DemoTile(
          title: 'Input Action Demo',
          destination: InputActionDemo(),
        ),
        DemoTile(
          title: 'Ime Switcher Demo',
          destination: ImeSwitcherDemo(),
        ),
      ],
    );
  }
}

class DemoTile extends StatelessWidget {
  const DemoTile({
    Key? key,
    required this.title,
    required this.destination,
  }) : super(key: key);

  final String title;
  final Widget destination;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
