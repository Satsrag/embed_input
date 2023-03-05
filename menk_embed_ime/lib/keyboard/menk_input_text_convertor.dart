/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:embed_ime/keyboard/input_text_converter.dart';

class MenkInputTextConvertor with LayoutTextConverter {


  @override
  void appendTextForSuggestionWords(String text) {
    super.appendTextForSuggestionWords(text);
  }

  @override
  void confirmWord(String word) {
    super.confirmWord(word);
  }

  MenkInputTextConvertor();
}