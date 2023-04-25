import 'package:embed_ime/embed_ime.dart';
import 'package:flutter/material.dart';
import 'package:zcode_embed_ime/zcode_layout.dart';

/// The thesaurus database did not combine into this library.
/// In the demo, use the [sqlite3](https://pub.dev/packages/sqlite3) to load the thesaurus database
class Test extends StatelessElement {
  Test(super.widget);
  @override
  Widget build() {
    return Scaffold(
      body: Column(children: [
        const Expanded(child: TextField()),
        EmbedKeyboard(
          layoutBuilders: const [
            ZcodeLayout.create,
            EnglishLayout.create,
          ],
        ),
      ]),
    );
  }
}
