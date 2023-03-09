/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mongol/mongol.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../layout/embed_keyboard_layout.dart';
import '../util/util.dart';
import 'embed_text_input.dart';
import '../layout/english_layout.dart';
import 'layout_text_converter.dart';
import 'key_map.dart';

typedef ConfirmedTextCallback = Function(String confirmedText);

typedef LayoutBuilder = EmbedKeyboardLayout Function(
  EmbedTextInput embedTextInput,
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
    this.assumeControlNotifier,
  }) : assert(layoutProviders.isNotEmpty);

  final List<LayoutProvider> layoutProviders;
  final ValueNotifier<bool>? assumeControlNotifier;

  @override
  State<StatefulWidget> createState() {
    return EmbedKeyboardState();
  }
}

class EmbedKeyboardState extends State<EmbedKeyboard>
    with TextInputControl, EmbedTextInput {
  EmbedTextInputControl? _inputControl;
  bool _hasHardKeyboard = false;
  bool _layoutShowing = false;
  bool _handleShowHideLayout = !Util.isDesktop;
  ValueNotifier<bool>? _internalAssumeControlNotifier;
  int _index = 0;
  TextEditingValue _editingState = const TextEditingValue();
  bool _stopEditingState = false;
  Size _editableBoxSize = Size.zero;
  Matrix4 _editableTransform = Matrix4.identity();
  Rect _caretRect = Rect.zero;

  int _currentPage = 0;
  OverlayEntry? _candidateBox;
  OverlayEntry? _keyboardSwitcher;

  LayoutTextConverter? get _layoutTextConverter {
    return widget.layoutProviders[_index].layoutTextConverter;
  }

  ValueNotifier<bool> get _assumeControlNotifier {
    return widget.assumeControlNotifier ??
        (_internalAssumeControlNotifier ??= ValueNotifier(false));
  }

  @override
  void initState() {
    super.initState();
    debugPrint('embed_keyboard -> initState');
    const LayoutProvider(layoutBuilder: EnglishLayout.create);
    HardwareKeyboard.instance.removeHandler(onKeyEvent);
    HardwareKeyboard.instance.addHandler(onKeyEvent);
    _assumeControlNotifier.addListener(_assumeControlChange);
    _assumeControlNotifier.value = true;
  }

  @override
  void dispose() {
    super.dispose();
    _assumeControlNotifier.value = false;
    _assumeControlNotifier.removeListener(_assumeControlChange);
    _internalAssumeControlNotifier?.dispose();
    HardwareKeyboard.instance.removeHandler(onKeyEvent);
    _hideCandidate();
    _hideLayoutShower();
  }

  void _assumeControlChange() {
    debugPrint(
        "embed_keyboard -> _assumeControlChange: ${_assumeControlNotifier.value}");
    if (_assumeControlNotifier.value) {
      TextInput.setInputControl(this);
    } else {
      TextInput.restorePlatformInputControl();
    }
  }

  @override
  void setTextInputControl(EmbedTextInputControl inputControl) {
    if (_inputControl == inputControl) {
      return;
    }
    _inputControl = inputControl;
    _inputControl?.setCaretRectAndTransform(_caretRect, _editableTransform);
    _inputControl?.setEditingState(_editingState);
  }

  @override
  void show() {
    super.show();
    debugPrint('embed_keyboard -> keyboard show');
    if (_handleShowHideLayout) {
      _layoutShowing = true;
      _inputControl?.show();
    }
    if (_hasHardKeyboard && !_layoutShowing) {
      _showLayoutShower();
    }
  }

  @override
  void hide() {
    super.hide();
    debugPrint('embed_keyboard -> keyboard hide');
    _hideCandidate();
    if (_handleShowHideLayout) {
      _layoutShowing = false;
      _inputControl?.hide();
    }
    _hideLayoutShower();
  }

  void _showLayoutShower() {
    if (_keyboardSwitcher != null) {
      _refreshLayoutShower();
      return;
    }
    _keyboardSwitcher = OverlayEntry(
      builder: _buildKeyboardSwitcherContent,
    );
    Overlay.of(context).insert(_keyboardSwitcher!);
  }

  void _refreshLayoutShower() {
    if (_keyboardSwitcher != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _keyboardSwitcher?.markNeedsBuild();
      });
    }
  }

  Widget _buildKeyboardSwitcherContent(BuildContext context) {
    const switcherSize = 30.0;
    final editableVector =
        _editableTransform.transform3(vector.Vector3(0, 0, 0));
    final double? switcherLeft;
    final double? switcherRight;
    if (editableVector.x <= switcherSize + 20) {
      switcherLeft = null;
      switcherRight = Util.windowWidth - 20;
    } else {
      switcherLeft = 20;
      switcherRight = null;
    }
    final double switcherTop = editableVector.y;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;
    return Positioned(
        left: switcherLeft,
        top: switcherTop,
        right: switcherRight,
        child: TextFieldTapRegion(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: onSurface.withOpacity(0.1)),
              color: colorScheme.surface,
            ),
            width: switcherSize,
            height: switcherSize,
            child: GestureDetector(
              onTap: () {
                _layoutShowing = true;
                _inputControl?.show();
                _handleShowHideLayout = true;
                _hideLayoutShower();
              },
              child: const Icon(Icons.keyboard_outlined, size: 20),
            ),
          ),
        ));
  }

  void _hideLayoutShower() {
    _keyboardSwitcher?.remove();
    _keyboardSwitcher = null;
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
    _caretRect = rect;
    _inputControl?.setCaretRectAndTransform(_caretRect, _editableTransform);
  }

  @override
  void setEditableSizeAndTransform(Size editableBoxSize, Matrix4 transform) {
    super.setEditableSizeAndTransform(editableBoxSize, transform);
    _editableTransform = transform;
    _editableBoxSize = editableBoxSize;
    _inputControl?.setCaretRectAndTransform(_caretRect, _editableTransform);
  }

  bool onKeyEvent(KeyEvent event) {
    debugPrint("embed_keyboard -> onKeyEvent: $event");
    _hasHardKeyboard = true;
    _layoutShowing = false;
    _inputControl?.hide();
    _handleShowHideLayout = false;
    _showLayoutShower();
    final handled = _inputControl?.onKeyEvent(event) ?? false;
    return handled;
    // todo move to layout
    final case_ = keyMap[event.physicalKey];
    if ((event is KeyDownEvent) && case_ != null) {
      _stopEditingState = true;
      insert(case_.character);
      return true;
    }
    if (event is KeyUpEvent && case_ != null) {
      _stopEditingState = false;
      TextInput.updateEditingValue(_editingState);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldTapRegion(
      child: _buildLayout(),
    );
  }

  Widget _buildLayout() {
    return widget.layoutProviders[_index].layoutBuilder(this);
  }

  @override
  void insert(String text) {
    final layoutTextConverter = _layoutTextConverter;
    if (layoutTextConverter == null) {
      _insert(text);
      return;
    }
    final selectSuggestions = text.length == 1 && '1234567890 '.contains(text);
    if (selectSuggestions) {
      final insertText = _selectWordFromSuggestions(text);
      _insert(insertText);
      layoutTextConverter.confirmWord(insertText);
      _showOrRefreshCandidate();
      return;
    }
    layoutTextConverter.appendTextForSuggestionWords(text);
    _showOrRefreshCandidate();
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

  void _showOrRefreshCandidate() {
    if (_candidateBox != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _candidateBox?.markNeedsBuild();
      });
      return;
    }
    _candidateBox = OverlayEntry(
      builder: (context) => _buildCandidateContent(context),
    );
    Overlay.of(context).insert(_candidateBox!);
  }

  Widget _buildCandidateContent(BuildContext context) {
    final layoutTextConverter = _layoutTextConverter;
    final transform = _editableTransform;
    final caretRect = _caretRect;
    if (layoutTextConverter == null || transform == null || caretRect == null) {
      return const SizedBox.shrink();
    }
    final suggestionWords = layoutTextConverter.suggestionWords;
    if (suggestionWords.isEmpty) {
      return const SizedBox.shrink();
    }
    final layoutText = layoutTextConverter.layoutText;
    final caretEndPoint = vector.Vector3(caretRect.right, caretRect.bottom, 0);
    debugPrint("embed_keyboard -> caretEndPoint: $caretEndPoint");
    transform.transform3(caretEndPoint);
    debugPrint("embed_keyboard -> abs caretEndPoint: $caretEndPoint");
    const candidateHeight = 200.0;
    final maxLength = min(10 * _currentPage + 10, suggestionWords.length);
    final candidateWidth = (maxLength - 10 * _currentPage) * 30.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;
    final textTheme = theme.textTheme;
    return Positioned(
      top: caretEndPoint.y,
      left: caretEndPoint.x,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: candidateHeight,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: onSurface.withOpacity(0.1)),
          color: colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: Text(
                layoutText,
                style: textTheme.bodyLarge,
              ),
            ),
            SizedBox(
              width: candidateWidth,
              child: const Divider(),
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int index = 10 * _currentPage;
                      index < maxLength;
                      index++)
                    SizedBox(
                      width: 30,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: MongolText(
                          '${(index + 1) % 10}. ${suggestionWords[index]}',
                          style: textTheme.bodyLarge?.copyWith(
                            color: index % 10 == 0 ? colorScheme.primary : null,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hideCandidate() {
    _candidateBox?.remove();
    _candidateBox = null;
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
  @override
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

  @override
  void switchLayout() {
    setState(() {
      ++_index;
      if (_index >= widget.layoutProviders.length) _index = 0;
    });
  }
}
