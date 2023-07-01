/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'dart:math';

import 'package:embed_ime/embed_ime.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vector_math/vector_math_64.dart' as vector;

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
  TextInputConfiguration? configuration;

  @override
  void initState() {
    widget.embedTextInput.setTextInputControl(this);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    widget.embedTextInput.setTextInputControl(this);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.embedTextInput.unsetTextInputControl(this);
    super.dispose();
  }

  @override
  void attach() {}

  @override
  void detach() {
    configuration = null;
  }

  @override
  void updateConfig(TextInputConfiguration configuration) {
    this.configuration = configuration;
    if (visibleSoftLayout) {
      setState(() {});
    }
  }

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
    final didTrans =
        transform.transform3(vector.Vector3(rect.right, rect.bottom, 0));
    caretRightBottomOffset = Point(didTrans.x, didTrans.y);
  }

  @override
  bool onKeyEvent(KeyEvent event) {
    if (event.isEnter && event.isDown) {
      performEnter();
      return true;
    }
    return false;
  }

  void performEnter() {
    final didPeform = widget.embedTextInput.performTextInputAction();
    if (didPeform) return;
    insert('\n');
  }

  void insert(String insert) {
    final text = editingValue.text;
    final textSelection = editingValue.selection;
    final start = textSelection.start;
    final end = textSelection.end;
    print(
        'editingValue: $editingValue insert: $insert, start: $start, end: $end');
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

extension TextInputConfigurationExtension on TextInputConfiguration {
  IconData get enterIcon {
    switch (inputAction) {
      case TextInputAction.done:
        return Icons.done;
      case TextInputAction.go:
      case TextInputAction.continueAction:
      case TextInputAction.join:
        return Icons.arrow_circle_right;
      case TextInputAction.search:
        return Icons.search;
      case TextInputAction.send:
        return Icons.send;
      case TextInputAction.next:
        return Icons.skip_next;
      case TextInputAction.previous:
        return Icons.skip_previous;
      case TextInputAction.route:
        return Icons.alt_route;
      case TextInputAction.emergencyCall:
        return Icons.call;
      default:
        return Icons.keyboard_return;
    }
  }

  Color? get enterBackground {
    switch (inputAction) {
      case TextInputAction.done:
      case TextInputAction.go:
      case TextInputAction.search:
      case TextInputAction.send:
      case TextInputAction.join:
      case TextInputAction.route:
      case TextInputAction.emergencyCall:
        return Colors.blue;
      default:
        return null;
    }
  }

  Color? get enterForeground {
    switch (inputAction) {
      case TextInputAction.done:
      case TextInputAction.go:
      case TextInputAction.search:
      case TextInputAction.send:
      case TextInputAction.join:
      case TextInputAction.route:
      case TextInputAction.emergencyCall:
        return Colors.white;
      default:
        return null;
    }
  }
}
