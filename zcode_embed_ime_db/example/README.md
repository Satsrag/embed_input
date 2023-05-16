```dart
void main() {
  runApp(const DemoApp());
  initZcodeDB();
}

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zcode Embed IME Demo',
      theme: ThemeData(fontFamily: 'ZcodeQagan'),
      home: Scaffold(
        appBar: AppBar(title: const Text('Zcode Embed IME Demo')),
        body: Column(children: [
          const Expanded(child: TextField()),
          EmbedKeyboard(
            layoutBuilders: [
              (i) => ZcodeLayout(i, converter: DBZcodeLayoutConverter()),
              EnglishLayout.create,
            ],
          ),
        ]),
      ),
    );
  }
}
```