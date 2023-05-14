import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';
import 'package:zcode_embed_ime_db/zcode_embed_ime_db.dart';

class ZcodeImeDemo extends StatefulWidget {
  const ZcodeImeDemo({super.key});

  @override
  State<ZcodeImeDemo> createState() => _ZcodeImeDemoState();
}

class _ZcodeImeDemoState extends State<ZcodeImeDemo> {
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
        appBar: AppBar(title: const Text("Zcode Ime Demo")),
        body: Column(
          children: [
            const Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: MongolTextField(
                        expands: true,
                        minLines: null,
                        maxLines: null,
                        textAlignHorizontal: TextAlignHorizontal.left,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        minLines: null,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        expands: true,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
