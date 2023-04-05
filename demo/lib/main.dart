import 'package:demo/demos/embed_ime_demo.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

import 'demos/test.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MongolTextEditingShortcuts(child: child),
      title: 'Embed IME Demo',
      theme: ThemeData(
        fontFamily: 'OnonSans',
      ),
      darkTheme: ThemeData(
        fontFamily: 'OnonSans',
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
          title: 'Embed Ime Demo',
          destination: EmbedImeDemo(),
        ),
        DemoTile(
          title: 'Test Demo',
          destination: Test(),
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
