/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'dart:math';
import 'package:flutter/material.dart';
import '../keyboard/painted_keyboard.dart';
import 'embed_layout.dart';

class EnglishLayout extends EmbedLayout {
  const EnglishLayout.create(super.embedKeyboardState)
      : super(
          key: null,
        );

  @override
  State<StatefulWidget> createState() => _EnglishLayoutState();
}

class _EnglishLayoutState
    extends BaseEmbedTextInputControlState<EnglishLayout> {
  var _type = EnglishLayoutType.letter;
  var _capslock = false;
  var _qwerty = 'qwertyuiopasdfghjklzxcvbnm';
  final _punctuation1 = '1234567890-/:;()\$&@".,?!\'';
  final _punctuation2 = '[]{}#%^*+=_\\|~<>€£¥•.,?!\'';

  @override
  String get layoutName => 'English';

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

    return Container(
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
    final row3Gap = row3TotalGaps / 10; // 9 keys = 10 gaps with spaceAround

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

    // Row 4: 123 + language + space + enter
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
        ? _punctuation1
        : _punctuation2;

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
    final row3Gap = row3TotalGaps / 8; // 7 keys = 8 gaps with spaceAround

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
      keys.add(KeyData(
        label: punctuation[i],
        type: KeyType.letter,
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
    final spaceKeyWidth = 5 * letterKeyWidth + 20;
    final enterKeyWidth = 2.5 * letterKeyWidth + 7.5;

    final totalKeyWidth = switchKeyWidth + languageKeyWidth + spaceKeyWidth + enterKeyWidth;
    final totalGaps = keyboardWidth - totalKeyWidth;
    final gap = totalGaps / 5; // 4 keys = 5 gaps with spaceAround

    double x = gap / 2;
    final y = KeyboardLayoutBuilder.topPadding + 3 * (letterKeyHeight + KeyboardLayoutBuilder.rowGap);

    // 123/ABC switch key
    keys.add(KeyData(
      label: _type == EnglishLayoutType.letter ? '123' : 'ABC',
      type: KeyType.function,
      fontSize: 16,
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

    // Space bar
    keys.add(KeyData(
      label: 'English',
      insertText: ' ',
      type: KeyType.space,
      fontSize: 16,
      visualRect: Rect.fromLTWH(x, y, spaceKeyWidth, letterKeyHeight),
      hitRect: _buildHitRect(x, y, spaceKeyWidth, letterKeyHeight, 3, builder),
    ));
    x += spaceKeyWidth + gap;

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

enum EnglishLayoutType { letter, punctuation1, punctuation2 }
