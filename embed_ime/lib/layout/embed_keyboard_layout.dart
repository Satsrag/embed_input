/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'dart:io';

import 'package:embed_ime/keyboard/embed_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

import '../util/util.dart';

abstract class EmbedKeyboardLayout extends StatefulWidget {
  const EmbedKeyboardLayout(this.embedTextInput, {super.key});

  final EmbedTextInput embedTextInput;
}

abstract class BaseEmbedTextInputControlState<T extends EmbedKeyboardLayout>
    extends State<T> with EmbedTextInputControl {
  TextEditingValue editingValue = TextEditingValue.empty;
  Offset caretRightBottomOffset = Offset.zero;
  bool isSoftLayoutVisible = !Util.isDesktop;

  @override
  void initState() {
    super.initState();
    widget.embedTextInput.setTextInputControl(this);
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.embedTextInput.setTextInputControl(this);
  }

  @override
  void show() {
  }

  @override
  void hide() {
  }

  @override
  void setEditingState(TextEditingValue value) {
    editingValue = value;
  }

  @override
  void setCaretRectAndTransform(Rect rect, Matrix4 transform) {
    super.setCaretRectAndTransform(rect, transform);
    final didTrans = transform.transform3(Vector3(rect.right, rect.bottom, 0));
    caretRightBottomOffset = Offset(didTrans.x, didTrans.y);
  }

  @override
  bool onKeyEvent(KeyEvent event) {
    if (isSoftLayoutVisible) {
      setState(() => isSoftLayoutVisible = false);
    }
    return false;
  }
}
