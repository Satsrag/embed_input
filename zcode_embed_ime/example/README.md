```dart
void main() {
  runApp(const DemoApp());
  db.init();
}

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zcode Embed IME Demo',
      theme: ThemeData(),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Zcode Embed IME Demo')),
        body: Column(children: [
          const Expanded(child: TextField()),
          EmbedKeyboard(
            layoutBuilders: const [
              ZcodeLayout.create,
              EnglishLayout.create,
            ],
          ),
        ]),
      ),
    );
  }
}
```