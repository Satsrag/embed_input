/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
import 'package:embed_ime/keyboard/layout_text_converter.dart';
import 'package:zcode_embed_ime/zcode_logic.dart';

class ZcodeLayoutTextConverter with LayoutTextConverter {
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
