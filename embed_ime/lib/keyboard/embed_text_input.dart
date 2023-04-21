/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/services.dart';

mixin EmbedTextInput {
  void setTextInputControl(EmbedTextInputControl inputControl);

  void switchLayout();

  /// The [EmbedTextInputControl] that is currently attached to this call this
  /// method to update the editing state, instead of calling
  /// [TextInput.updateEditingValue].
  /// Because the [EmbedTextInput] will not receive the update if we call the
  /// [TextInput.updateEditingValue] to update editing state.
  void updateEditingValue(TextEditingValue value);
}

mixin EmbedTextInputControl {
  String get layoutName;

  void attach();

  void detach();

  void showSoftLayout();

  void hideSoftLayout();

  void setEditingState(TextEditingValue value);

  /// Informs the text input control about caret area changes.
  ///
  /// This method is called when the attached input client's caret area
  /// changes.
  void setCaretRectAndTransform(Rect rect, Matrix4 transform) {}

  bool onKeyEvent(KeyEvent event) => false;
}
