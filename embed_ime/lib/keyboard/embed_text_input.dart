/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/services.dart';

mixin EmbedTextInput {
  void setTextInputControl(EmbedTextInputControl inputControl);

  void switchLayout();

  void insert(String text);

  /// [length] want to delete char count. If there is a selection, just delete
  /// selection and ignore length
  void backspace({int length = 1});
}

mixin EmbedTextInputControl {
  String get layoutName;

  void show();

  void hide();

  void setEditingState(TextEditingValue value);
  /// Informs the text input control about caret area changes.
  ///
  /// This method is called when the attached input client's caret area
  /// changes.
  void setCaretRectAndTransform(Rect rect, Matrix4 transform) {}

  bool onKeyEvent(KeyEvent event) => false;
}
