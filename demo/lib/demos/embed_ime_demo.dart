import 'package:embed_ime/keyboard/embed_keyboard.dart';
import 'package:embed_ime/layout/english_layout.dart';
import 'package:flutter/material.dart';
import 'package:menk_embed_ime/keyboard/menk_layout.dart';
import 'package:mongol/mongol.dart';

class EmbedImeDemo extends StatefulWidget {
  const EmbedImeDemo({super.key});

  @override
  State<EmbedImeDemo> createState() => _EmbedImeDemoState();
}

class _EmbedImeDemoState extends State<EmbedImeDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Embed Ime Demo")),
      body: Column(
        children: [
          Expanded(
              child: Row(
            children: const [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: MongolTextField(
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: TextField(
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                ),
              ),
            ],
          )),
          EmbedKeyboard(
            layoutProviders: const [
              LayoutProvider(layoutBuilder: EnglishLayout.create),
              LayoutProvider(layoutBuilder: MenkLayout.create),
            ],
          ),
        ],
      ),
    );
  }
}
