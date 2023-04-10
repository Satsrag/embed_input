import 'package:embed_ime/keyboard/embed_keyboard.dart';
import 'package:embed_ime/layout/english_layout.dart';
import 'package:flutter/material.dart';
import 'package:menk_embed_ime/keyboard/menk_input_text_convertor.dart';
import 'package:mongol/mongol.dart';
import 'package:zcode_embed_ime/zcode_input_text_convertor.dart';
import 'package:zcode_embed_ime/zcode_layout.dart';

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
            Expanded(
              child: Row(
                children: const [
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
                (i) => ZcodeLayout(i, converter: ZcodeLayoutTextConverter()),
                EnglishLayout.create
              ],
            ),
          ],
        ),
      ),
    );
  }
}