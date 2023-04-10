import 'package:embed_ime/keyboard/embed_keyboard.dart';
import 'package:embed_ime/layout/english_layout.dart';
import 'package:flutter/material.dart';
import 'package:menk_embed_ime/keyboard/menk_layout.dart';
import 'package:mongol/mongol.dart';

class MenkImeDemo extends StatefulWidget {
  const MenkImeDemo({super.key});

  @override
  State<MenkImeDemo> createState() => _MenkImeDemoState();
}

class _MenkImeDemoState extends State<MenkImeDemo> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(fontFamily: 'MenkQagan'),
      child: Scaffold(
        appBar: AppBar(title: const Text("Embed Ime Demo")),
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
              layoutBuilders: const [MenkLayout.create, EnglishLayout.create],
            ),
          ],
        ),
      ),
    );
  }
}
