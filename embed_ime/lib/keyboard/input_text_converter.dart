/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

mixin LayoutTextConverter {
  var layoutText = '';
  final List<String> suggestionWords = [];

  void appendTextForSuggestionWords(String text) {
    layoutText += text;
  }

  void confirmWord(String word) {
    layoutText = '';
    suggestionWords.clear();
  }
}
