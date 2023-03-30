/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
import 'package:flutter/services.dart';

/// A [TextInputControl] is a class that receives text input state changes and
/// visual input control requests from the framework, and dispatches them to the
/// hard [TextInputControl] and soft [TextInputControl].
class EmbedProxyTextInputController with TextInputControl {
  TextInputClient? _client;
  TextInputConfiguration? _configuration;
  bool _visible = false;
  TextEditingValue _textEditingValue = TextEditingValue.empty;
  Size _editableBoxSize = Size.zero;
  Matrix4 _editableBoxTransform = Matrix4.zero();
  Rect _composingRect = Rect.zero;
  Rect _caretRect = Rect.zero;
  List<SelectionRect> _selectionRects = List.empty();

  TextInputControl? _hardKeyboardTextInputControl;
  TextInputControl? _softKeyboardTextInputControl;

  void registerHardKeyboard(TextInputControl textInputControl) {
    if (_hardKeyboardTextInputControl == textInputControl) {
      return;
    }
    _hardKeyboardTextInputControl?.hide();
    final client = _client;
    if (client != null) {
      _hardKeyboardTextInputControl?.detach(client);
    }
    _hardKeyboardTextInputControl = textInputControl;
    dispatchAttackedStateIfNeed(textInputControl);
  }

  void unRegisterHardKeyboard(TextInputControl textInputControl) {
    if (textInputControl == _hardKeyboardTextInputControl) {
      dispatchDetachedStateIfNeed(textInputControl);
      _hardKeyboardTextInputControl = null;
    }
  }

  void registerSoftKeyboard(TextInputControl textInputControl) {
    if (_softKeyboardTextInputControl == textInputControl) {
      return;
    }
    _softKeyboardTextInputControl?.hide();
    final client = _client;
    if (client != null) {
      _softKeyboardTextInputControl?.detach(client);
    }
    _softKeyboardTextInputControl = textInputControl;
    dispatchAttackedStateIfNeed(textInputControl);
  }

  void unRegisterSoftKeyboard(TextInputControl textInputControl) {
    if (textInputControl == _softKeyboardTextInputControl) {
      dispatchDetachedStateIfNeed(textInputControl);
      _softKeyboardTextInputControl = null;
    }
  }

  void dispatchAttackedStateIfNeed(TextInputControl textInputControl) {
    final client = _client;
    final configuration = _configuration;

    // EmbedTextInputController has been attached to a TextInputClient.
    final attached = client != null && configuration != null;
    if (attached) {
      textInputControl.attach(client, configuration);
      if (_visible) {
        textInputControl.show();
      } else {
        textInputControl.hide();
      }
      textInputControl.setEditingState(_textEditingValue);
      textInputControl.setEditableSizeAndTransform(
          _editableBoxSize, _editableBoxTransform);
      textInputControl.setComposingRect(_composingRect);
      textInputControl.setCaretRect(_caretRect);
      textInputControl.setSelectionRects(_selectionRects);
    }
  }

  void dispatchDetachedStateIfNeed(TextInputControl textInputControl) {
    final client = _client;
    if (client != null) {
      if (_visible) {
        textInputControl.hide();
      }
      textInputControl.detach(client);
    }
  }

  @override
  void attach(TextInputClient client, TextInputConfiguration configuration) {
    super.attach(client, configuration);
    _client = client;
    _configuration = _configuration;
    _hardKeyboardTextInputControl?.detach(client);
    _softKeyboardTextInputControl?.detach(client);
  }

  @override
  void detach(TextInputClient client) {
    super.detach(client);
    if (_client == client) {
      _hardKeyboardTextInputControl?.detach(client);
      _softKeyboardTextInputControl?.detach(client);
      _client = null;
    }
  }

  @override
  void show() {
    super.show();
    _visible = true;
    _hardKeyboardTextInputControl?.show();
    _softKeyboardTextInputControl?.show();
  }

  @override
  void hide() {
    super.hide();
    _visible = false;
    _hardKeyboardTextInputControl?.hide();
    _softKeyboardTextInputControl?.hide();
  }

  @override
  void updateConfig(TextInputConfiguration configuration) {
    super.updateConfig(configuration);
    _hardKeyboardTextInputControl?.updateConfig(configuration);
    _softKeyboardTextInputControl?.updateConfig(configuration);
    _configuration = configuration;
  }

  @override
  void setEditingState(TextEditingValue value) {
    super.setEditingState(value);
    _hardKeyboardTextInputControl?.setEditingState(value);
    _softKeyboardTextInputControl?.setEditingState(value);
    _textEditingValue = value;
  }

  @override
  void setEditableSizeAndTransform(Size editableBoxSize, Matrix4 transform) {
    super.setEditableSizeAndTransform(editableBoxSize, transform);
    _hardKeyboardTextInputControl?.setEditableSizeAndTransform(
        editableBoxSize, transform);
    _softKeyboardTextInputControl?.setEditableSizeAndTransform(
        editableBoxSize, transform);
    _editableBoxSize = editableBoxSize;
    _editableBoxTransform = transform;
  }

  @override
  void setComposingRect(Rect rect) {
    super.setComposingRect(rect);
    _hardKeyboardTextInputControl?.setComposingRect(rect);
    _softKeyboardTextInputControl?.setComposingRect(rect);
    _composingRect = rect;
  }

  @override
  void setCaretRect(Rect rect) {
    super.setCaretRect(rect);
    _hardKeyboardTextInputControl?.setCaretRect(rect);
    _softKeyboardTextInputControl?.setCaretRect(rect);
    _caretRect = rect;
  }

  @override
  void setSelectionRects(List<SelectionRect> selectionRects) {
    super.setSelectionRects(selectionRects);
    _hardKeyboardTextInputControl?.setSelectionRects(selectionRects);
    _softKeyboardTextInputControl?.setSelectionRects(selectionRects);
    _selectionRects = selectionRects;
  }
}
