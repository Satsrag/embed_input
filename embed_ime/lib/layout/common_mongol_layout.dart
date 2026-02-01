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
      final willInsertText = _candidate?.convertInsert('\n');
      if ('\n' == willInsertText) {
        return super.onKeyEvent(event);
      }
      if (willInsertText != null) {
        super.insert(willInsertText);
        return true;
      }
    }
    if (event.isUp && _stopEditingState) {
      _stopEditingState = false;
      widget.embedTextInput.updateEditingValue(editingValue);
      return true;
    }
    return super.onKeyEvent(event);
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

    if (_capslock) {
      _qwerty = _qwerty.toUpperCase();
    } else {
      _qwerty = _qwerty.toLowerCase();
    }

    final backgroundColor = light
        ? const Color.fromARGB(255, 200, 201, 208)
        : const Color.fromARGB(255, 83, 83, 83);

    final builder = KeyboardLayoutBuilder(
      keyboardWidth: width,
      portrait: portrait,
    );

    final keys = _type == EnglishLayoutType.letter
        ? _buildLetterKeys(builder, light)
        : _buildPunctuationKeys(builder, light);

    return GestureDetector(
      // On IOS, user tap on left bottom corner of the screen, the keyboard will dismiss.
      // So we need to intercept the tap event.
      onTap: () {},
      child: Container(
        width: double.infinity,
        color: backgroundColor,
        child: SafeArea(
          child: Center(
            child: PaintedKeyboard(
              keys: keys,
              keyboardWidth: width,
              keyboardHeight: builder.totalHeight,
              light: light,
              backgroundColor: backgroundColor,
              onKeyTap: _onKeyTap,
            ),
          ),
        ),
      ),
    );
  }

  void _onKeyTap(KeyData key) {
    insert(key.textToInsert);
    // Reset capslock after typing uppercase letter
    if (_capslock && key.type == KeyType.letter) {
      final letter = key.textToInsert;
      if (letter == letter.toUpperCase() && letter != letter.toLowerCase()) {
        setState(() => _capslock = false);
      }
    }
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

  List<KeyData> _buildLetterKeys(KeyboardLayoutBuilder builder, bool light) {
    final List<KeyData> keys = [];
    final letterKeyWidth = builder.letterKeyWidth;
    final letterKeyHeight = builder.letterKeyHeight;
    final keyboardWidth = builder.keyboardWidth;
    final horizontalGap = builder.horizontalGap;

    // Row 1: q-p (10 keys)
    keys.addAll(_buildRow(
      rowIndex: 0,
      labels: _qwerty.substring(0, 10).split(''),
      startX: horizontalGap / 2,
      keyWidth: letterKeyWidth,
      builder: builder,
      light: light,
    ));

    // Row 2: a-l (9 keys) with half-key padding on sides
    final row2StartX = letterKeyWidth / 2 + horizontalGap;
    keys.addAll(_buildRow(
      rowIndex: 1,
      labels: _qwerty.substring(10, 19).split(''),
      startX: row2StartX,
      keyWidth: letterKeyWidth,
      builder: builder,
      light: light,
    ));

    // Row 3: capslock + z-m + backspace
    final capslockWidth = letterKeyWidth * 3 / 2 + 2.5;
    final backspaceWidth = letterKeyWidth * 3 / 2 + 2.5;
    final row3Letters = _qwerty.substring(19, 26).split('');

    // Calculate row 3 layout
    final row3TotalKeyWidth = capslockWidth + 7 * letterKeyWidth + backspaceWidth;
    final row3TotalGaps = keyboardWidth - row3TotalKeyWidth;
    final row3Gap = row3TotalGaps / 10;

    double x = row3Gap / 2;
    final y = KeyboardLayoutBuilder.topPadding + 2 * (letterKeyHeight + KeyboardLayoutBuilder.rowGap);

    // Capslock key
    keys.add(KeyData(
      label: '',
      icon: Icons.keyboard_capslock,
      type: KeyType.function,
      selected: _capslock,
      visualRect: Rect.fromLTWH(x, y, capslockWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, capslockWidth, letterKeyHeight, 2, builder, isFirst: true),
      onTap: () => setState(() => _capslock = !_capslock),
    ));
    x += capslockWidth + row3Gap;

    // Letter keys z-m
    for (int i = 0; i < 7; i++) {
      final letter = row3Letters[i];
      keys.add(KeyData(
        label: letter,
        type: KeyType.letter,
        isVertical: verticalLetters.contains(letter),
        visualRect: Rect.fromLTWH(x, y, letterKeyWidth, letterKeyHeight),
        hitRect: _buildHitRect(x, y, letterKeyWidth, letterKeyHeight, 2, builder),
        onLongPress: () {
          final uppercase = letter.toUpperCase();
          final lowercase = letter.toLowerCase();
          final isUppercase = uppercase == letter;
          insert(isUppercase ? lowercase : uppercase);
        },
      ));
      x += letterKeyWidth + row3Gap;
    }

    // Backspace key
    keys.add(KeyData(
      label: '',
      icon: Icons.backspace_outlined,
      type: KeyType.function,
      visualRect: Rect.fromLTWH(x, y, backspaceWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, backspaceWidth, letterKeyHeight, 2, builder, isLast: true),
      onTap: backspace,
    ));

    // Row 4
    keys.addAll(_buildFourthRowKeys(builder, light));

    return keys;
  }

  List<KeyData> _buildPunctuationKeys(KeyboardLayoutBuilder builder, bool light) {
    final List<KeyData> keys = [];
    final letterKeyWidth = builder.letterKeyWidth;
    final letterKeyHeight = builder.letterKeyHeight;
    final keyboardWidth = builder.keyboardWidth;
    final horizontalGap = builder.horizontalGap;

    final punctuation = _type == EnglishLayoutType.punctuation1
        ? softPunctuation
        : softPunctuationShift;

    // Row 1: first 10 punctuation
    keys.addAll(_buildRow(
      rowIndex: 0,
      labels: punctuation.substring(0, 10).split(''),
      startX: horizontalGap / 2,
      keyWidth: letterKeyWidth,
      builder: builder,
      light: light,
      enableLongPress: false,
    ));

    // Row 2: next 10 punctuation
    keys.addAll(_buildRow(
      rowIndex: 1,
      labels: punctuation.substring(10, 20).split(''),
      startX: horizontalGap / 2,
      keyWidth: letterKeyWidth,
      builder: builder,
      light: light,
      enableLongPress: false,
    ));

    // Row 3: #+= + 5 punctuation + backspace
    final switchWidth = (letterKeyWidth + 2) * 5 / 3;
    final punctKeyWidth = letterKeyWidth * 4 / 3 + 5 / 3;
    final backspaceWidth = (letterKeyWidth + 2) * 5 / 3;

    final row3TotalKeyWidth = switchWidth + 5 * punctKeyWidth + backspaceWidth;
    final row3TotalGaps = keyboardWidth - row3TotalKeyWidth;
    final row3Gap = row3TotalGaps / 8;

    double x = row3Gap / 2;
    final y = KeyboardLayoutBuilder.topPadding + 2 * (letterKeyHeight + KeyboardLayoutBuilder.rowGap);

    // #+= or 123 switch key
    keys.add(KeyData(
      label: _type == EnglishLayoutType.punctuation1 ? '#+=' : '123',
      type: KeyType.function,
      fontSize: 20,
      backgroundColor: _iconKeyBackgroundColor(false, light),
      visualRect: Rect.fromLTWH(x, y, switchWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, switchWidth, letterKeyHeight, 2, builder, isFirst: true),
      onTap: () => setState(() {
        if (_type == EnglishLayoutType.punctuation1) {
          _type = EnglishLayoutType.punctuation2;
        } else {
          _type = EnglishLayoutType.punctuation1;
        }
      }),
    ));
    x += switchWidth + row3Gap;

    // 5 punctuation keys
    for (int i = 20; i < 25; i++) {
      final label = punctuation[i];
      keys.add(KeyData(
        label: label,
        type: KeyType.letter,
        isVertical: verticalLetters.contains(label),
        visualRect: Rect.fromLTWH(x, y, punctKeyWidth, letterKeyHeight),
        hitRect: _buildHitRect(x, y, punctKeyWidth, letterKeyHeight, 2, builder),
      ));
      x += punctKeyWidth + row3Gap;
    }

    // Backspace key
    keys.add(KeyData(
      label: '',
      icon: Icons.backspace_outlined,
      type: KeyType.function,
      visualRect: Rect.fromLTWH(x, y, backspaceWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, backspaceWidth, letterKeyHeight, 2, builder, isLast: true),
      onTap: backspace,
    ));

    // Row 4
    keys.addAll(_buildFourthRowKeys(builder, light));

    return keys;
  }

  List<KeyData> _buildRow({
    required int rowIndex,
    required List<String> labels,
    required double startX,
    required double keyWidth,
    required KeyboardLayoutBuilder builder,
    required bool light,
    bool enableLongPress = true,
  }) {
    final List<KeyData> keys = [];
    final letterKeyHeight = builder.letterKeyHeight;
    final horizontalGap = builder.horizontalGap;
    final y = KeyboardLayoutBuilder.topPadding + rowIndex * (letterKeyHeight + KeyboardLayoutBuilder.rowGap);

    double x = startX;
    for (int i = 0; i < labels.length; i++) {
      final label = labels[i];
      keys.add(KeyData(
        label: label,
        type: KeyType.letter,
        isVertical: verticalLetters.contains(label),
        visualRect: Rect.fromLTWH(x, y, keyWidth, letterKeyHeight),
        hitRect: _buildHitRect(
          x, y, keyWidth, letterKeyHeight, rowIndex, builder,
          isFirst: i == 0,
          isLast: i == labels.length - 1,
        ),
        onLongPress: enableLongPress
            ? () {
                final uppercase = label.toUpperCase();
                final lowercase = label.toLowerCase();
                final isUppercase = uppercase == label;
                insert(isUppercase ? lowercase : uppercase);
              }
            : null,
      ));
      x += keyWidth + horizontalGap;
    }
    return keys;
  }

  List<KeyData> _buildFourthRowKeys(KeyboardLayoutBuilder builder, bool light) {
    final List<KeyData> keys = [];
    final letterKeyWidth = builder.letterKeyWidth;
    final letterKeyHeight = builder.letterKeyHeight;
    final keyboardWidth = builder.keyboardWidth;

    final switchKeyWidth = letterKeyWidth * 5 / 4 + 1.25;
    final languageKeyWidth = letterKeyWidth * 5 / 4 + 1.25;
    final commaKeyWidth = letterKeyWidth;
    final spaceKeyWidth = 3 * letterKeyWidth + 10;
    final fullstopKeyWidth = letterKeyWidth;
    final enterKeyWidth = 2.5 * letterKeyWidth + 7.5;

    final totalKeyWidth = switchKeyWidth + languageKeyWidth + commaKeyWidth +
        spaceKeyWidth + fullstopKeyWidth + enterKeyWidth;
    final totalGaps = keyboardWidth - totalKeyWidth;
    final gap = totalGaps / 7; // 6 keys = 7 gaps with spaceAround

    double x = gap / 2;
    final y = KeyboardLayoutBuilder.topPadding + 3 * (letterKeyHeight + KeyboardLayoutBuilder.rowGap);

    // 123/mongolEA switch key
    final switchLabel = _type == EnglishLayoutType.letter ? '123' : mongolEA;
    keys.add(KeyData(
      label: switchLabel,
      type: KeyType.function,
      fontSize: 16,
      isVertical: verticalLetters.contains(switchLabel),
      backgroundColor: _iconKeyBackgroundColor(false, light),
      visualRect: Rect.fromLTWH(x, y, switchKeyWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, switchKeyWidth, letterKeyHeight, 3, builder, isFirst: true),
      onTap: () => setState(() {
        if (_type == EnglishLayoutType.letter) {
          _type = EnglishLayoutType.punctuation1;
        } else {
          _type = EnglishLayoutType.letter;
        }
      }),
    ));
    x += switchKeyWidth + gap;

    // Language switch key
    keys.add(KeyData(
      label: '',
      icon: Icons.language,
      type: KeyType.function,
      visualRect: Rect.fromLTWH(x, y, languageKeyWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, languageKeyWidth, letterKeyHeight, 3, builder),
      onTap: () => widget.embedTextInput.switchLayout(),
    ));
    x += languageKeyWidth + gap;

    // Comma key
    final comma = mongolCommaFullstop[0];
    keys.add(KeyData(
      label: comma,
      type: KeyType.letter,
      isVertical: verticalLetters.contains(comma),
      visualRect: Rect.fromLTWH(x, y, commaKeyWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, commaKeyWidth, letterKeyHeight, 3, builder),
    ));
    x += commaKeyWidth + gap;

    // Space bar
    keys.add(KeyData(
      label: layoutName,
      insertText: ' ',
      type: KeyType.space,
      fontSize: 16,
      visualRect: Rect.fromLTWH(x, y, spaceKeyWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, spaceKeyWidth, letterKeyHeight, 3, builder),
    ));
    x += spaceKeyWidth + gap;

    // Full-stop key
    final fullstop = mongolCommaFullstop[1];
    keys.add(KeyData(
      label: fullstop,
      type: KeyType.letter,
      isVertical: verticalLetters.contains(fullstop),
      visualRect: Rect.fromLTWH(x, y, fullstopKeyWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, fullstopKeyWidth, letterKeyHeight, 3, builder),
    ));
    x += fullstopKeyWidth + gap;

    // Enter key
    keys.add(KeyData(
      label: '',
      icon: configuration?.enterIcon ?? Icons.keyboard_return,
      type: KeyType.enter,
      backgroundColor: configuration?.enterBackground,
      foregroundColor: configuration?.enterForeground,
      visualRect: Rect.fromLTWH(x, y, enterKeyWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, enterKeyWidth, letterKeyHeight, 3, builder, isLast: true),
      onTap: performEnter,
    ));

    return keys;
  }

  Rect _buildHitRect(
    double x,
    double y,
    double width,
    double height,
    int rowIndex,
    KeyboardLayoutBuilder builder, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final horizontalGap = builder.horizontalGap;
    final keyboardWidth = builder.keyboardWidth;

    double hitLeft = isFirst ? 0 : x - horizontalGap / 2;
    double hitRight = isLast ? keyboardWidth : x + width + horizontalGap / 2;
    double hitTop = y - (rowIndex == 0 ? KeyboardLayoutBuilder.topPadding : KeyboardLayoutBuilder.rowGap / 2);
    double hitBottom = y + height + (rowIndex == 3 ? KeyboardLayoutBuilder.bottomPadding : KeyboardLayoutBuilder.rowGap / 2);

    return Rect.fromLTRB(hitLeft, hitTop, hitRight, hitBottom);
  }
}
