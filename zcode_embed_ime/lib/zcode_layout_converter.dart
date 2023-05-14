/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
import 'package:embed_ime/embed_ime.dart';
import 'zcode_logic.dart';

/// This class is used to convert Latin to the Zcode Mongol Words.
/// [layoutText] is the Latin text that is inputted by hard/soft layout.
/// [suggestionWords] is the converted Zcode Mongol Words.
class ZcodeLayoutTextConverter with LayoutConverter {
  final zcode = ZCode();

  @override
  void appendLayoutText(String text) {
    super.appendLayoutText(text);
    suggestionWords.clear();
    if (layoutText.isEmpty) return;
    suggestionWords.addAll(zcode.excuteEx(layoutText));
  }

  @override
  void backspaceLayoutText(bool clear) {
    super.backspaceLayoutText(clear);
    suggestionWords.clear();
    if (layoutText.isEmpty) return;
    suggestionWords.addAll(zcode.excuteEx(layoutText));
  }
}
