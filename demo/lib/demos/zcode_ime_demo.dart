import 'package:embed_ime/keyboard/embed_keyboard.dart';
import 'package:embed_ime/layout/english_layout.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';
import 'package:zcode_embed_ime/zcode_layout.dart';

class ZcodeImeDemo extends StatefulWidget {
  const ZcodeImeDemo({super.key});

  @override
  State<ZcodeImeDemo> createState() => _ZcodeImeDemoState();
}

class _ZcodeImeDemoState extends State<ZcodeImeDemo> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(fontFamily: 'ZcodeQagan'),
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
              layoutProviders: const [
                LayoutProvider(layoutBuilder: ZcodeLayout.create),
                LayoutProvider(layoutBuilder: EnglishLayout.create),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
