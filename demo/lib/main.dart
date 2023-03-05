import 'package:embed_ime/keyboard/embed_keyboard.dart';
import 'package:embed_ime/keyboard/english_layout.dart';
import 'package:flutter/material.dart';
import 'package:menk_embed_ime/keyboard/menk_input_text_convertor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Embed IME Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'Embed IME Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ImeInput Demo")),
      body: Column(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: TextField(
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: TextField(
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ),
          ),
          EmbedKeyboard(
            layoutProviders: [
              const LayoutProvider(layoutBuilder: EnglishLayout.create),
              LayoutProvider(
                layoutBuilder: EnglishLayout.create,
                layoutTextConverter: MenkInputTextConvertor(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
