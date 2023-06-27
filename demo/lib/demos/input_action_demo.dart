import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';
import 'package:zcode_embed_ime_db/zcode_embed_ime_db.dart';

class InputActionDemo extends StatefulWidget {
  const InputActionDemo({super.key});

  @override
  State<StatefulWidget> createState() {
    return _InputActionDemoState();
  }
}

class _InputActionDemoState extends State<InputActionDemo> {
  TextInputAction _inputAction = TextInputAction.done;
  bool _bindKeyboard = true;

  @override
  Widget build(BuildContext context) {
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final theme = ThemeData(fontFamily: 'ZcodeQagan', brightness: brightness);
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text("Input Action Demo")),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  SizedBox(
                    width: 250,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Row(children: [
                              Switch(
                                value: _bindKeyboard,
                                onChanged: (v) {
                                  setState(() {
                                    _bindKeyboard = v;
                                  });
                                },
                              ),
                              const Text("Bind Embed Keyboard"),
                            ]);
                          }
                          index -= 1;
                          return Row(children: [
                            Radio(
                              value: TextInputAction.values[index],
                              groupValue: _inputAction,
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _inputAction = v;
                                  });
                                }
                              },
                            ),
                            Text(TextInputAction.values[index].name),
                          ]);
                        },
                        itemCount: TextInputAction.values.length + 1),
                  ),
                  MongolTextField(
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    textInputAction: _inputAction,
                    onSubmitted: (value) {
                      debugPrint("onSubmitted: $value");
                    },
                  ),
                  const SizedBox(width: 8),
                  MongolTextField(
                    maxLines: 2,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    textInputAction: _inputAction,
                    onSubmitted: (value) {
                      debugPrint("onSubmitted: $value");
                    },
                  ),
                ]),
              ),
            ),
            if (_bindKeyboard)
              EmbedKeyboard(
                layoutBuilders: [
                  (i) => ZcodeLayout(i, converter: DBZcodeLayoutConverter()),
                  EnglishLayout.create
                ],
              ),
          ],
        ),
      ),
    );
  }
}
