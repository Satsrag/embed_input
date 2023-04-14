/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/foundation.dart';
import '../layout/embed_keyboard_layout.dart';

mixin LayoutTextConverter {
  var layoutText = '';
  final List<String> suggestionWords = [];

  /// Note: after calling [appendLayoutText], [backspaceLayoutText], and
  /// [confirmWord], [EmbedKeyboardLayout] checks the [suggestionWords] and refreshes
  /// the Candidate.  In this situation above, [suggestionWordsNotifier] is not
  /// needed to be used. But if you get the [suggestionWords] from the server or
  /// the async function, you can use [SuggestionChangeNotifier.notify] to notify
  /// the suggestions are changed.
  final suggestionWordsNotifier = SuggestionChangeNotifier();

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

class SuggestionChangeNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
