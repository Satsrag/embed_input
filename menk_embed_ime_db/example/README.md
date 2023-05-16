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
      title: 'Menk Embed IME Demo',
      theme: ThemeData(fontFamily: 'MenkQagan'),
      home: Scaffold(
        appBar: AppBar(title: const Text('Menk Embed IME Demo')),
        body: Column(children: [
          const Expanded(child: TextField()),
          EmbedKeyboard(
            layoutBuilders: [
              (i) => MenkLayout(i, converter: DBMenkLayoutConverter()),
              EnglishLayout.create,
            ],
          ),
        ]),
      ),
    );
  }
}
```