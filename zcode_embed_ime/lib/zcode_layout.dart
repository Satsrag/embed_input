/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
import 'dart:math';

import 'package:embed_ime/candidate/mongol_candidate.dart';
import 'package:embed_ime/embed_ime.dart';
import 'package:embed_ime/keyboard/key_map.dart';
import 'package:embed_ime/layout/english_layout.dart';
import 'package:flutter/material.dart';

import 'zcode_input_text_convertor.dart';

class ZcodeLayout extends EmbedKeyboardLayout {
  const ZcodeLayout.create(super.embedKeyboardState) : super(key: null);

  @override
  State<ZcodeLayout> createState() => _ZcodeLayoutState();
}

class _ZcodeLayoutState extends BaseEmbedTextInputControlState<ZcodeLayout> {
  MongolCandidate? _candidate;
  bool _stopEditingState = false;
  var _type = EnglishLayoutType.letter;
  var _capslock = false;
  var _qwerty = 'qwertyuiopasdfghjklzxcvbnm';
  final Map<String, String> punctuations = {
    ',': '\u1802',
    '.': '\u1803',
    '!': '\u1852',
    '^': '\u1801',
    '*': '\u1861',
    '(': '\u1855',
    ')': '\u1856',
    '<': '\u1857',
    '>': '\u1858',
    '[': '\u1859',
    ']': '\u185A',
    ':': '\u1804',
    '"': '\u185B  \u185C',
    '?': '\u1853',
  };
  // \u1801 ᠁ \u1802 ᠂\u1803 ᠃ \u1804 ᠄ \u1805 ᠅ \u1808 ᠈ \u1809 ᠉ \u184A ᡊ
  // \u184B ᡋ \u184C ᡌ \u184D ᡍ \u184E ᡎ \u184F ᡏ \u1850 ᡐ \u1851 ᡑ \u1852 ᡒ
  // \u1853 ᡓ \u1854 ᡔ \u1855 ᡕ \u1856 ᡖ \u1857 ᡗ \u1858 ᡘ \u1859 ᡙ \u185A ᡚ
  // \u185B ᡛ \u185C ᡜ \u185D ᡝ \u185E ᡞ \u185F ᡟ \u1860 ᡠ \u1861 ᡡ \u1862 ᡢ
  // \u1863 ᡣ
  final _punctuation1 = '1234567890ᡢᡐᡑᡕᡖ᠁@¥ᡡ•.,ᡓᡒ᠄';
  // final _punctuation1 = '1234567890\u1862\u1850\u1851\u1855\u1856\u1801@¥\u1861•.,\u1853\u1852\u1804';
  final _punctuation2 = 'ᡝᡞ{}ᡋ%^*+=ᡣ/~ᡛᡜᡗᡘᡙᡚ•.,ᡓᡒ᠄';
  // final _punctuation2 = '\u185D\u185E{}\u184B%^*+=\u1863/~\u185B\u185C\u1857\u1858\u1859\u185A•.,\u1853\u1852\u1804';
  final _verticalLetters = 'ᡢᡐᡑᡕᡖ᠁ᡓᡒ᠄ᡝᡞ{}ᡣ~ᡛᡜᡗᡘᡙᡚ᠂᠃ᡥᡨ\nᡥᡧ';
  @override
  void initState() {
    super.initState();
    _candidate = MongolCandidate(
      context: context,
      layoutTextConverter: ZcodeLayoutTextConverter(),
      directInsert: (insertText) => super.insert(insertText),
      softLayoutTop: () {
        final renderObject = context.findRenderObject();
        debugPrint('softLayoutTop: $renderObject');
        final box = renderObject as RenderBox;
        if (box.hasSize) {
          return box.localToGlobal(Offset.zero).dy;
        } else {
          return 100.0;
        }
      },
    );
  }

  @override
  String get layoutName => 'Zcode';

  @override
  void detach() {
    super.detach();
    _candidate?.dismiss();
  }

  @override
  void showSoftLayout() {
    super.showSoftLayout();
    _candidate?.typingSoftKeyboard = true;
  }

  @override
  void hideSoftLayout() {
    super.hideSoftLayout();
    _candidate?.typingSoftKeyboard = false;
  }

  @override
  void setCaretRectAndTransform(Rect rect, Matrix4 transform) {
    super.setCaretRectAndTransform(rect, transform);
    _candidate?.caretRightBottomPoint = caretRightBottomOffset;
    _candidate?.caretLongSize = max(rect.width, rect.height);
  }

  @override
  bool onKeyEvent(KeyEvent event) {
    final printableAsciiKey = printableAsciiKeys[event.physicalKey];
    final interceptForPrintableAscii = event.isDown &&
        printableAsciiKey != null &&
        !isPressOtherThanShiftAndPrintableAsciiKeys;
    // Todo: It not a good way to solve this problem.
    // flutter bug: On the Macos, when the user presses the backspace key with
    // the mete key, and then releases the backspace key, the up event of the
    // backspace key will not call the onKeyEvent method.
    // So we need to intercept the printableAsciiKey when this issure will happen.
    final backspaceBug =
        event.isDown && printableAsciiKey != null && isBackspacePressed;
    if (interceptForPrintableAscii || backspaceBug) {
      _stopEditingState = true;
      final menkPunctuation = punctuations[printableAsciiKey.character];
      if (menkPunctuation != null) {
        insert(menkPunctuation);
      } else {
        insert(printableAsciiKey.character);
      }
      return true;
    }
    if (event.isBackspace && (event.isDown || event.isRepeat)) {
      final didHandle = _candidate?.backspace() ?? false;
      return didHandle;
    }
    final interceptEscape = event.isEscape && _candidate?.isVisible == true;
    if (interceptEscape && event.isDown) {
      _candidate?.dismiss();
      return true;
    }
    if (event.isUp && _stopEditingState) {
      _stopEditingState = false;
      widget.embedTextInput.updateEditingValue(editingValue);
      return true;
    }
    debugPrint('menk_layout: return false');
    return false;
  }

  @override
  void insert(String text) {
    final willInsertText = _candidate?.convertInsert(text);
    if (willInsertText != null) {
      super.insert(willInsertText);
    }
  }

  @override
  bool backspace({int length = 1}) {
    final didHandle = _candidate?.backspace() ?? false;
    if (!didHandle) {
      return super.backspace(length: length);
    } else {
      return didHandle;
    }
  }

  @override
  void setEditingState(TextEditingValue value) {
    if (_stopEditingState) {
      return;
    }
    super.setEditingState(value);
  }

  @override
  void dispose() {
    super.dispose();
    _candidate?.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    if (!visibleSoftLayout) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final query = MediaQuery.of(context);
    final portrait = query.orientation == Orientation.portrait;
    final width = min(query.size.width, (portrait ? 450.0 : 600.0));
    final letterKeyWidth = width / 10 - 5;
    final letterHeight =
        portrait ? letterKeyWidth * 9 / 7 : letterKeyWidth * 32 / 53;
    if (_capslock) {
      _qwerty = _qwerty.toUpperCase();
    } else {
      _qwerty = _qwerty.toLowerCase();
    }
    return SafeArea(
      child: Container(
        width: double.infinity,
        color: light
            ? const Color.fromARGB(255, 200, 201, 208)
            : const Color.fromARGB(255, 83, 83, 83),
        child: Center(
          child: SizedBox(
            width: width,
            child: _type == EnglishLayoutType.letter
                ? _buildLetterLayout(letterKeyWidth, letterHeight, light)
                : _buildPunctuationLayout(letterKeyWidth, letterHeight, light),
          ),
        ),
      ),
    );
  }

  Widget _buildLetterLayout(
      double letterKeyWidth, double letterHeight, bool light) {
    return Column(children: [
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < 10; i++)
            SizedBox(
              width: letterKeyWidth,
              height: letterHeight,
              child: _buildLetterKey(_qwerty[i], light),
            ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: (letterKeyWidth) / 2),
          for (int i = 10; i < 19; i++)
            SizedBox(
              width: letterKeyWidth,
              height: letterHeight,
              child: _buildLetterKey(_qwerty[i], light),
            ),
          SizedBox(width: (letterKeyWidth) / 2),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: letterKeyWidth * 3 / 2 + 2.5,
            height: letterHeight,
            child: _buildIconKey(Icons.keyboard_capslock, light, () {
              setState(() => _capslock = !_capslock);
            }, selected: _capslock),
          ),
          for (int i = 19; i < 26; i++)
            SizedBox(
              width: letterKeyWidth,
              height: letterHeight,
              child: _buildLetterKey(_qwerty[i], light),
            ),
          SizedBox(
            width: letterKeyWidth * 3 / 2 + 2.5,
            height: letterHeight,
            child: _buildIconKey(Icons.backspace_outlined, light, () {
              backspace();
            }),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _buildFourthLine(letterKeyWidth, letterHeight, light),
      const SizedBox(height: 5),
    ]);
  }

  Widget _buildPunctuationLayout(
      double letterKeyWidth, double letterHeight, bool light) {
    final punctuation =
        _type == EnglishLayoutType.punctuation1 ? _punctuation1 : _punctuation2;
    return Column(children: [
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < 10; i++)
            SizedBox(
              width: letterKeyWidth,
              height: letterHeight,
              child: _buildLetterKey(punctuation[i], light),
            ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 10; i < 20; i++)
            SizedBox(
              width: letterKeyWidth,
              height: letterHeight,
              child: _buildLetterKey(punctuation[i], light),
            ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            /// reference [punctuation.jpg]
            width: (letterKeyWidth + 2) * 5 / 3,
            height: letterHeight,
            child: _buildLetterKey(
              _type == EnglishLayoutType.punctuation1 ? '#+=' : '123',
              light,
              fontSize: 20,
              backgroundColor: _iconKeyBackgroundColor(false, light),
              onPressed: () => setState(() {
                if (_type == EnglishLayoutType.punctuation1) {
                  _type = EnglishLayoutType.punctuation2;
                } else {
                  _type = EnglishLayoutType.punctuation1;
                }
              }),
            ),
          ),
          for (int i = 20; i < 25; i++)
            SizedBox(
              /// reference [punctuation.jpg]
              width: letterKeyWidth * 4 / 3 + 5 / 3,
              height: letterHeight,
              child: _buildLetterKey(punctuation[i], light),
            ),
          SizedBox(
            /// reference [punctuation.jpg]
            width: (letterKeyWidth + 2) * 5 / 3,
            height: letterHeight,
            child: _buildIconKey(Icons.backspace_outlined, light, () {
              backspace();
            }),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _buildFourthLine(letterKeyWidth, letterHeight, light),
      const SizedBox(height: 5),
    ]);
  }

  Widget _buildLetterKey(
    String letter,
    bool light, {
    double? fontSize,
    Color? backgroundColor,
    VoidCallback? onPressed,
    bool enableLongPress = true,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: backgroundColor ??
            (light ? Colors.white : const Color.fromARGB(255, 130, 130, 130)),
        foregroundColor: light ? Colors.black : Colors.white,
      ),
      onPressed: onPressed ??
          () {
            insert(letter);
            if (letter == letter.toUpperCase()) {
              setState(() => _capslock = false);
            }
          },
      onLongPress: enableLongPress
          ? () {
              final uppercase = letter.toUpperCase();
              final lowercase = letter.toLowerCase();
              final isUppercase = uppercase == letter;
              insert(isUppercase ? lowercase : uppercase);
            }
          : null,
      child: _verticalLetters.contains(letter)
          ? RotatedBox(
              quarterTurns: 1,
              child: Text(
                letter,
                style: TextStyle(fontSize: fontSize ?? 20, height: 1),
              ),
            )
          : Text(
              letter,
              style: TextStyle(fontSize: fontSize ?? 20, height: 1),
            ),
    );
  }

  Widget _buildIconKey(IconData icon, bool light, VoidCallback? onPressed,
      {bool selected = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: _iconKeyBackgroundColor(selected, light),
        foregroundColor: light ? Colors.black : Colors.white,
      ),
      onPressed: onPressed,
      child: Icon(icon),
    );
  }

  Color _iconKeyBackgroundColor(bool selected, bool light) {
    if (selected) {
      return light ? Colors.white : const Color.fromARGB(255, 130, 130, 130);
    } else {
      return light
          ? const Color.fromARGB(255, 153, 162, 172)
          : const Color.fromARGB(255, 95, 95, 95);
    }
  }

  Widget _buildFourthLine(
      double letterKeyWidth, double letterHeight, bool light) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: letterKeyWidth * 5 / 4 + 1.25,
          height: letterHeight,
          child: _buildLetterKey(
            _type == EnglishLayoutType.letter ? '123' : 'ᡥᡨ\nᡥᡧ',
            light,
            fontSize: 16,
            backgroundColor: _iconKeyBackgroundColor(false, light),
            onPressed: () {
              setState(() {
                if (_type == EnglishLayoutType.letter) {
                  _type = EnglishLayoutType.punctuation1;
                } else {
                  _type = EnglishLayoutType.letter;
                }
              });
            },
            enableLongPress: false,
          ),
        ),
        SizedBox(
          width: letterKeyWidth * 5 / 4 + 1.25,
          height: letterHeight,
          child: _buildIconKey(
            Icons.language,
            light,
            () => widget.embedTextInput.switchLayout(),
          ),
        ),
        SizedBox(
          width: letterKeyWidth,
          height: letterHeight,
          child: _buildLetterKey(
            '᠂',
            light,
            onPressed: () => insert('᠂ '),
          ),
        ),
        SizedBox(
          width: 3 * letterKeyWidth + 10,
          height: letterHeight,
          child: _buildLetterKey(
            'Zcode',
            light,
            fontSize: 16,
            onPressed: () => insert(' '),
          ),
        ),
        SizedBox(
          width: letterKeyWidth,
          height: letterHeight,
          child: _buildLetterKey(
            '᠃',
            light,
            onPressed: () => insert('᠃ '),
          ),
        ),
        SizedBox(
          width: 2.5 * letterKeyWidth + 7.5,
          height: letterHeight,
          child: _buildIconKey(
            Icons.keyboard_return,
            light,
            () => insert('\n'),
          ),
        ),
      ],
    );
  }
}
