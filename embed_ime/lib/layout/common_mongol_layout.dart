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

/// It is used to build a Mongol layout. It is not flexible enough. It has UI and
/// logic like the [EnglishLayout] and you can not change its UI and logic. To
/// build a more flexible Mongol layout, you can use the [BaseEmbedTextInputControlState].
abstract class CommonMongolLayoutState<Layout extends EmbedLayout>
    extends BaseEmbedTextInputControlState<Layout> {
  /// It is used to convert the layout text (English/Latin text) to the Mongol text.
  abstract final LayoutConverter layoutConverter;

  /// Used for the first page of the soft keyboard punctuation keys. Length must
  /// be 25. The first 10 characters are used for the first row. The next 10
  /// characters are used for the second row. The last 5 characters are used for
  /// the third row.
  abstract final String softPunctuation;

  /// Used for the second page of the soft keyboard punctuation keys. On the
  /// punctuation page, press the shift key to switch to the second page. Length
  /// must be 25. The first 10 characters are used for the first row. The next 10
  /// characters are used for the second row. The last 5 characters are used for
  /// the third row.
  abstract final String softPunctuationShift;

  /// On the soft keyboard, some Mongol keys display vertical letters. So we need
  /// to set these letters in this variable.
  abstract final String verticalLetters;

  /// On the soft keyboard, the key that switches the Mongol and punctuation page
  /// uses the Mongol a and e letters.
  abstract final String mongolEA;

  /// At the fourth row of the soft keyboard, uses the Mongol comma and full-stop.
  abstract final String mongolCommaFullstop;

  /// On the hard keyboard, input the Mongol punctuation using the English/Latin
  /// punctuation keys. So this variable is the English/Latin punctuations map to
  /// the Mongol punctuations.
  abstract final Map<String, String> hardPunctuations;

  MongolCandidate? _candidate;
  bool _stopEditingState = false;
  var _type = EnglishLayoutType.letter;
  var _capslock = false;
  var _qwerty = 'qwertyuiopasdfghjklzxcvbnm';

  @override
  void initState() {
    super.initState();
    _candidate = MongolCandidate(
      context: context,
      layoutTextConverter: layoutConverter,
      directInsert: (insertText) => super.insert(insertText),
      softLayoutTop: () {
        final renderObject = context.findRenderObject();
        final box = renderObject as RenderBox;
        if (box.hasSize) {
          return box.localToGlobal(Offset.zero).dy;
        } else {
          return 300.0;
        }
      },
    );
    _candidate?.caretRightBottomPoint = caretRightBottomOffset;
  }

  @override
  void detach() {
    super.detach();
    _candidate?.dismiss();
  }

  @override
  void showSoftLayout() {
    super.showSoftLayout();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _candidate?.typingSoftKeyboard = true;
    });
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
      final punctuation = hardPunctuations[printableAsciiKey.character];
      if (punctuation != null) {
        insert(punctuation);
      } else {
        insert(printableAsciiKey.character);
      }
      return true;
    }
    if (event.isBackspace && (event.isDown || event.isRepeat)) {
      final didHandle = _candidate?.backspace() ?? false;
      if (didHandle) {
        _stopEditingState = true;
      }
      return didHandle;
    }
    final interceptEscape = event.isEscape && _candidate?.isVisible == true;
    if (interceptEscape && event.isDown) {
      _candidate?.dismiss();
      return true;
    }
    if (event.isDown && event.isEnter) {
      insert('\n');
      return true;
    }
    if (event.isUp && _stopEditingState) {
      _stopEditingState = false;
      widget.embedTextInput.updateEditingValue(editingValue);
      return true;
    }
    return false;
  }

  @override
  void insert(String insert) {
    final willInsertText = _candidate?.convertInsert(insert);
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
    final punctuation = _type == EnglishLayoutType.punctuation1
        ? softPunctuation
        : softPunctuationShift;
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
              width: letterKeyWidth * 4 / 3 + 5 / 3,
              height: letterHeight,
              child: _buildLetterKey(punctuation[i], light),
            ),
          SizedBox(
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
      child: verticalLetters.contains(letter)
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
            _type == EnglishLayoutType.letter ? '123' : mongolEA,
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
          child: _buildLetterKey(mongolCommaFullstop[0], light),
        ),
        SizedBox(
          width: 3 * letterKeyWidth + 10,
          height: letterHeight,
          child: _buildLetterKey(
            layoutName,
            light,
            fontSize: 16,
            onPressed: () => insert(' '),
          ),
        ),
        SizedBox(
          width: letterKeyWidth,
          height: letterHeight,
          child: _buildLetterKey(mongolCommaFullstop[1], light),
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
