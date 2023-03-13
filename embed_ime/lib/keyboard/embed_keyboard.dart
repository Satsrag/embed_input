/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../layout/embed_keyboard_layout.dart';
import '../util/util.dart';
import 'embed_text_input.dart';
import '../layout/english_layout.dart';
import 'layout_text_converter.dart';

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
  bool _hasHardKeyboard = Util.isDesktop;
  bool _layoutShowing = false;
  bool _handleShowHideLayout = !Util.isDesktop;
  ValueNotifier<bool>? _internalAssumeControlNotifier;
  int _index = 0;
  TextEditingValue _editingState = const TextEditingValue();
  Matrix4 _editableTransform = Matrix4.identity();
  Rect _caretRect = Rect.zero;


  OverlayEntry? _keyboardSwitcher;

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
    if (_handleShowHideLayout) {
      _layoutShowing = false;
      _inputControl?.hide();
    }
    _hideLayoutShower();
  }

  void _showLayoutShower() {
    if (_keyboardSwitcher != null) {
      _refreshLayoutSwitcher();
      return;
    }
    _keyboardSwitcher = OverlayEntry(
      builder: _buildKeyboardSwitcherContent,
    );
    Overlay.of(context).insert(_keyboardSwitcher!);
  }

  void _refreshLayoutSwitcher() {
    if (_keyboardSwitcher != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _keyboardSwitcher?.markNeedsBuild();
      });
    }
  }

  Widget _buildKeyboardSwitcherContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;
    final textTheme = theme.textTheme;
    final textStyle = textTheme.bodySmall?.copyWith(height: 1);
    final layoutNameSize =
        Util.textSize(_inputControl?.layoutName ?? '', textStyle!);
    const switcherWidth = 30.0;
    final switcherHeight = layoutNameSize.width + switcherWidth;
    final editableVector =
        _editableTransform.transform3(vector.Vector3(0, 0, 0));
    final double? switcherLeft;
    final double? switcherRight;
    if (editableVector.x <= switcherWidth + 20) {
      switcherLeft = null;
      switcherRight = Util.windowWidth - 20;
    } else {
      switcherLeft = 20;
      switcherRight = null;
    }
    double switcherTop = editableVector.y;
    if (switcherTop + switcherHeight > Util.windowHeight) {
      switcherTop = 50;
    }

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
            width: switcherWidth,
            height: switcherHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _layoutShowing = true;
                    _inputControl?.show();
                    _handleShowHideLayout = true;
                    _hideLayoutShower();
                  },
                  child: const Icon(Icons.keyboard_outlined, size: 20),
                ),
                const Divider(height: 0),
                GestureDetector(
                  onTap: () {
                    setState(switchLayout);
                  },
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      _inputControl?.layoutName ?? '',
                      style: textStyle,
                    ),
                  ),
                )
              ],
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
    _editingState = value;
    _inputControl?.setEditingState(_editingState);
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
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldTapRegion(
      child: widget.layoutProviders[_index].layoutBuilder(this),
    );
  }

  @override
  void switchLayout() {
    _refreshLayoutSwitcher();
    setState(() {
      ++_index;
      if (_index >= widget.layoutProviders.length) _index = 0;
    });
  }
}
