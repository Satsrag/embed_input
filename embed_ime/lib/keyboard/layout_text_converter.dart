/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

mixin LayoutTextConverter {
  var layoutText = '';
  final List<String> suggestionWords = [];

  void appendLayoutText(String text) {
    layoutText += text;
  }

  void backspaceLayoutText(bool clear) {
    if (layoutText.isEmpty) return;
    if (clear) {
      layoutText = '';
    } else {
      layoutText = layoutText.substring(0, layoutText.length - 1);
    }
  }

  void confirmWord(String word) {
    layoutText = '';
    suggestionWords.clear();
  }
}
