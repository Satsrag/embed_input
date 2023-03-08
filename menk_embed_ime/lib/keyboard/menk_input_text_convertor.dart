/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:embed_ime/keyboard/layout_text_converter.dart';

import 'char_convertor.dart';

class MenkLayoutTextConverter with LayoutTextConverter {
  @override
  void appendTextForSuggestionWords(String text) {
    super.appendTextForSuggestionWords(text);
    suggestionWords.clear();
    suggestionWords.addAll(suggestion(layoutText));
  }

  @override
  void confirmWord(String word) {
    final nextWords = nextSuggestion(layoutText, word);
    super.confirmWord(word);
    suggestionWords.addAll(nextWords);
  }
}
