import 'package:flutter/material.dart';
import 'package:menk_embed_ime_db/menk_embed_ime_db.dart';
import 'package:mongol/mongol.dart';

class MenkImeDemo extends StatefulWidget {
  const MenkImeDemo({super.key});

  @override
  State<MenkImeDemo> createState() => _MenkImeDemoState();
}

class _MenkImeDemoState extends State<MenkImeDemo> {
  @override
  Widget build(BuildContext context) {
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final theme = ThemeData(fontFamily: 'MenkQagan', brightness: brightness);
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text("Menk Embed Ime Demo")),
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
                (i) => MenkLayout(i, converter: DBMenkLayoutConverter()),
                EnglishLayout.create,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
