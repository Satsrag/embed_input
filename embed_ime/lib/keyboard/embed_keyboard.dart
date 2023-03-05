/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'embed_keyboard_layout.dart';
import 'english_layout.dart';
import 'input_text_converter.dart';
import 'key_map.dart';

typedef ConfirmedTextCallback = Function(String confirmedText);

typedef LayoutBuilder = EmbedKeyboardLayout Function(
    // todo EmbedKeyboardState replace with interface
  EmbedKeyboardState embedKeyboardState,
);

class LayoutProvider {
  final LayoutBuilder layoutBuilder;
  final LayoutTextConverter? layoutTextConverter;

  const LayoutProvider({required this.layoutBuilder, this.layoutTextConverter});
}

class EmbedKeyboard extends StatefulWidget {
  EmbedKeyboard({
    super.key,
    this.layoutProviders = const [
      LayoutProvider(layoutBuilder: EnglishLayout.create),
    ],
  }) : assert(layoutProviders.isNotEmpty);

  final List<LayoutProvider> layoutProviders;

  @override
  State<StatefulWidget> createState() => EmbedKeyboardState();
}

class EmbedKeyboardState extends State<EmbedKeyboard> with TextInputControl {
  bool visible = false;
  int _index = 0;
  TextEditingValue _editingState = const TextEditingValue();
  bool _stopEditingState = false;

  LayoutTextConverter? get _layoutTextConverter {
    return widget.layoutProviders[_index].layoutTextConverter;
  }

  @override
  void initState() {
    super.initState();
    const LayoutProvider(layoutBuilder: EnglishLayout.create);
    TextInput.setInputControl(this);
  }

  @override
  void dispose() {
    super.dispose();
    TextInput.restorePlatformInputControl();
  }

  @override
  void show() {
    super.show();
    setState(() => visible = true);
    HardwareKeyboard.instance.removeHandler(onKeyEvent);
    HardwareKeyboard.instance.addHandler(onKeyEvent);
  }

  @override
  void hide() {
    super.hide();
    setState(() => visible = false);
    HardwareKeyboard.instance.removeHandler(onKeyEvent);
  }

  @override
  void setEditingState(TextEditingValue value) {
    super.setEditingState(value);
    if (kDebugMode) {
      print("embed_keyboard -> setEditingState: $value");
    }
    if (_stopEditingState) {
      return;
    }
    _editingState = value;
  }

  @override
  void setCaretRect(Rect rect) {
    super.setCaretRect(rect);
  }

  bool onKeyEvent(KeyEvent event) {
    // todo move to layout
    final case_ = keyMap[event.physicalKey];
    if ((event is KeyDownEvent) && case_ != null) {
      _stopEditingState = true;
      insert(case_.character);
      return true;
    }
    if (event is KeyUpEvent && case_ != null) {
      _stopEditingState = false;
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldTapRegion(
      child: _buildKeyboard(),
    );
  }

  Widget _buildKeyboard() {
    if (visible) {
      return widget.layoutProviders[_index].layoutBuilder(this);
    } else {
      return const SizedBox.shrink();
    }
  }

  void insert(String text) {
    final layoutTextConverter = _layoutTextConverter;
    if (layoutTextConverter == null) {
      _insert(text);
      return;
    }
    final selectSuggestions = text.length == 1 && '1234567890 '.contains(text);
    if (selectSuggestions) {
      _insert(_selectWordFromSuggestions(text));
      return;
    }
    layoutTextConverter.appendTextForSuggestionWords(text);
  }

  String _selectWordFromSuggestions(String index) {
    var numberIndex = 0;
    if (index == ' ') {
      numberIndex = 0;
    } else {
      numberIndex = '1234567890 '.indexOf(index);
    }
    final layoutTextConverter = _layoutTextConverter;
    if (layoutTextConverter == null) {
      return index;
    }
    if (layoutTextConverter.suggestionWords.length > numberIndex) {
      return layoutTextConverter.suggestionWords[numberIndex];
    }
    return index;
  }

  void _insert(String insert) {
    final text = _editingState.text;
    final textSelection = _editingState.selection;
    final start = textSelection.start;
    final end = textSelection.end;
    final newText = text.replaceRange(start, end, insert);
    final textLength = insert.length;
    _editingState = _editingState.copyWith(
      text: newText,
      selection: textSelection.copyWith(
        baseOffset: textSelection.start + textLength,
        extentOffset: textSelection.start + textLength,
      ),
      composing: TextRange.empty,
    );
    if (kDebugMode) {
      print("embed_keyboard -> insert: $_editingState");
    }
    // Request the attached client to update accordingly.
    TextInput.updateEditingValue(_editingState);
  }

  /// [length] want to delete char count. If there is a selection, just delete
  /// selection and ignore length
  void backspace({int length = 1}) {
    final text = _editingState.text;
    final textSelection = _editingState.selection;
    final selectionLength = textSelection.end - textSelection.start;

    // There is a selection.
    if (selectionLength > 0) {
      final newText =
          text.replaceRange(textSelection.start, textSelection.end, '');
      _editingState = _editingState.copyWith(
          text: newText,
          selection: textSelection.copyWith(
            baseOffset: textSelection.start,
            extentOffset: textSelection.start,
          ));
      // Request the attached client to update accordingly.
      TextInput.updateEditingValue(_editingState);
      return;
    }

    // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return;
    }

    // Delete the previous character
    var newStart = textSelection.start - length;
    if (newStart < 0) {
      newStart = 0;
    }
    final newEnd = textSelection.start;
    final newText = text.replaceRange(newStart, newEnd, '');
    _editingState = _editingState.copyWith(
        text: newText,
        selection: textSelection.copyWith(
          baseOffset: newStart,
          extentOffset: newStart,
        ));
    // Request the attached client to update accordingly.
    TextInput.updateEditingValue(_editingState);
  }

  void switchLayout() {
    setState(() {
      ++_index;
      if (_index >= widget.layoutProviders.length) _index = 0;
    });
  }
}
