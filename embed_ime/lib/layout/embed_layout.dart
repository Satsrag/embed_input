/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'dart:math';

import '../keyboard/embed_text_input.dart';
import '../layout/layout_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class EmbedLayout extends StatefulWidget {
  const EmbedLayout(
    this.embedTextInput, {
    this.converter,
    super.key,
  });

  final EmbedTextInput embedTextInput;

  final LayoutConverter? converter;
}

abstract class BaseEmbedTextInputControlState<T extends EmbedLayout>
    extends State<T> with EmbedTextInputControl {
  TextEditingValue editingValue = TextEditingValue.empty;
  Point<double> caretRightBottomOffset = const Point(0, 0);
  bool visibleSoftLayout = false;

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
  void attach() {}

  @override
  void detach() {}

  @override
  void showSoftLayout() {
    if (visibleSoftLayout) return;
    setState(() => visibleSoftLayout = true);
  }

  @override
  void hideSoftLayout() {
    if (!visibleSoftLayout) return;
    setState(() => visibleSoftLayout = false);
  }

  @override
  void setEditingState(TextEditingValue value) {
    editingValue = value;
  }

  @override
  void setCaretRectAndTransform(Rect rect, Matrix4 transform) {
    super.setCaretRectAndTransform(rect, transform);
    final didTrans = transform.transform3(Vector3(rect.right, rect.bottom, 0));
    caretRightBottomOffset = Point(didTrans.x, didTrans.y);
  }

  @override
  bool onKeyEvent(KeyEvent event) {
    return false;
  }

  void insert(String insert) {
    final text = editingValue.text;
    final textSelection = editingValue.selection;
    final start = textSelection.start;
    final end = textSelection.end;
    final newText = text.replaceRange(start, end, insert);
    final textLength = insert.length;
    editingValue = editingValue.copyWith(
      text: newText,
      selection: textSelection.copyWith(
        baseOffset: textSelection.start + textLength,
        extentOffset: textSelection.start + textLength,
      ),
      composing: TextRange.empty,
    );
    // Request the attached client to update accordingly.
    widget.embedTextInput.updateEditingValue(editingValue);
  }

  /// [length] want to delete char count. If there is a selection, just delete
  /// selection and ignore length
  bool backspace({int length = 1}) {
    final text = editingValue.text;
    final textSelection = editingValue.selection;
    final selectionLength = textSelection.end - textSelection.start;

    // There is a selection.
    if (selectionLength > 0) {
      final newText =
          text.replaceRange(textSelection.start, textSelection.end, '');
      editingValue = editingValue.copyWith(
          text: newText,
          selection: textSelection.copyWith(
            baseOffset: textSelection.start,
            extentOffset: textSelection.start,
          ));
      // Request the attached client to update accordingly.
      widget.embedTextInput.updateEditingValue(editingValue);
      return true;
    }

    // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return true;
    }

    // Delete the previous character
    var newStart = textSelection.start - length;
    if (newStart < 0) {
      newStart = 0;
    }
    final newEnd = textSelection.start;
    final newText = text.replaceRange(newStart, newEnd, '');
    editingValue = editingValue.copyWith(
        text: newText,
        selection: textSelection.copyWith(
          baseOffset: newStart,
          extentOffset: newStart,
        ));
    // Request the attached client to update accordingly.
    widget.embedTextInput.updateEditingValue(editingValue);
    return true;
  }
}
