/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:embed_ime/keyboard/key_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../layout/embed_layout.dart';
import '../layout/english_layout.dart';
import '../util/util.dart';
import 'embed_text_input.dart';

typedef ConfirmedTextCallback = Function(String confirmedText);

typedef LayoutBuilder = EmbedLayout Function(EmbedTextInput embedTextInput);

class EmbedKeyboard extends StatefulWidget {
  EmbedKeyboard({
    super.key,
    this.layoutBuilders = const [EnglishLayout.create],
    this.assumeControlNotifier,
  }) : assert(layoutBuilders.isNotEmpty);

  final List<LayoutBuilder> layoutBuilders;
  final ValueNotifier<bool>? assumeControlNotifier;

  @override
  State<StatefulWidget> createState() {
    return EmbedKeyboardState();
  }
}

class EmbedKeyboardState extends State<EmbedKeyboard>
    with TextInputControl, EmbedTextInput {
  EmbedTextInputControl? _inputControl;
  bool _layoutDidAttach = false;
  bool _hasHardKeyboard = Util.isDesktop;
  bool _softLayoutShowing = false;
  bool _handleShowLayout = !Util.isDesktop;
  ValueNotifier<bool>? _internalAssumeControlNotifier;
  int _index = 0;
  TextEditingValue _editingState = const TextEditingValue();
  Matrix4 _editableTransform = Matrix4.identity();
  Size _editableSize = Size.zero;
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
    _assumeControlNotifier.addListener(_assumeControlChange);
    _assumeControlNotifier.value = true;
  }

  @override
  void dispose() {
    super.dispose();
    _assumeControlNotifier.value = false;
    _assumeControlNotifier.removeListener(_assumeControlChange);
    _internalAssumeControlNotifier?.dispose();
    _hideLayoutShower();
  }

  void _assumeControlChange() {
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
    if (_layoutDidAttach) {
      _inputControl?.attach();
    }
    if (_softLayoutShowing) {
      _inputControl?.showSoftLayout();
    } else {
      _inputControl?.hideSoftLayout();
    }
    _inputControl?.setCaretRectAndTransform(_caretRect, _editableTransform);
    _inputControl?.setEditingState(_editingState);
    if (!_layoutDidAttach) {
      _inputControl?.detach();
    }
  }

  @override
  void attach(TextInputClient client, TextInputConfiguration configuration) {
    super.attach(client, configuration);
    HardwareKeyboard.instance.removeHandler(onKeyEvent);
    HardwareKeyboard.instance.addHandler(onKeyEvent);
    debugPrint(
        'embed_keyboard -> attach: client: $client, config: ${configuration.toJson()}');
  }

  @override
  void detach(TextInputClient client) {
    super.detach(client);
    HardwareKeyboard.instance.removeHandler(onKeyEvent);
    debugPrint('embed_keyboard -> detach');
  }

  @override
  void show() {
    super.show();
    debugPrint('embed_keyboard -> keyboard show');
    _inputControl?.attach();
    _layoutDidAttach = true;
    if (_handleShowLayout) {
      _softLayoutShowing = true;
      _inputControl?.showSoftLayout();
    }
    if (_hasHardKeyboard && !_softLayoutShowing) {
      _showLayoutSwither();
    }
  }

  @override
  void hide() {
    super.hide();
    debugPrint('embed_keyboard -> keyboard hide');
    _softLayoutShowing = false;
    _inputControl?.hideSoftLayout();
    _inputControl?.detach();
    _layoutDidAttach = false;
    _hideLayoutShower();
  }

  void _showLayoutSwither() {
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
    final textTheme = theme.textTheme;
    final textStyle = textTheme.bodySmall?.copyWith(height: 1);
    final layoutNameSize =
        Util.textSize(_inputControl?.layoutName ?? '', textStyle!);
    const switcherWidth = 30.0;
    final switcherHeight = layoutNameSize.width + switcherWidth;
    final editableLT = _editableTransform.transform3(vector.Vector3(0, 0, 0));
    final editableRB = _editableTransform.transform3(
      vector.Vector3(_editableSize.width, _editableSize.height, 0),
    );
    final switcherLeft = editableRB.x + 10 + switcherWidth > context.windowWidth
        ? editableLT.x - 10 - switcherWidth
        : editableRB.x + 10;

    double switcherTop = editableRB.y - switcherHeight - 10;
    if (switcherTop < 10) {
      switcherTop = 10;
    }

    return Positioned(
        left: switcherLeft,
        top: switcherTop,
        child: TextFieldTapRegion(
          child: Theme(
            data: Theme.of(this.context),
            child: Card(
              child: SizedBox(
                width: switcherWidth,
                height: switcherHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        _softLayoutShowing = true;
                        _inputControl?.showSoftLayout();
                        _handleShowLayout = true;
                        _hideLayoutShower();
                      },
                      child: const Icon(Icons.keyboard_outlined, size: 20),
                    ),
                    const Divider(height: 0),
                    InkWell(
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
    debugPrint("embed_keyboard -> setEditingState($value)");
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
    _editableSize = editableBoxSize;
    _inputControl?.setCaretRectAndTransform(_caretRect, _editableTransform);
  }

  bool onKeyEvent(KeyEvent event) {
    _hasHardKeyboard = true;
    if (_softLayoutShowing) {
      _softLayoutShowing = false;
      _inputControl?.hideSoftLayout();
    }
    _handleShowLayout = false;
    _showLayoutSwither();

    if (event.isDoubleClickShift) {
      switchLayout();
      return true;
    }

    final handled = _inputControl?.onKeyEvent(event) ?? false;
    return handled;
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldTapRegion(
      child: widget.layoutBuilders[_index].call(this),
    );
  }

  @override
  void switchLayout() {
    if (_softLayoutShowing) {
      _inputControl?.hideSoftLayout();
    }
    _inputControl?.detach();
    _refreshLayoutSwitcher();
    setState(() {
      ++_index;
      if (_index >= widget.layoutBuilders.length) _index = 0;
    });
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    _editingState = value;
    TextInput.updateEditingValue(value);
  }
}
