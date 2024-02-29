/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'dart:math';
import 'package:flutter/material.dart';
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
      child: Text(
        letter,
        style: TextStyle(fontSize: fontSize ?? 20),
      ),
    );
  }

  Widget _buildIconKey(IconData icon, bool light, VoidCallback? onPressed,
      {Color? backgroundColor, Color? foregroundColor, bool selected = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.zero,
        backgroundColor:
            backgroundColor ?? _iconKeyBackgroundColor(selected, light),
        foregroundColor:
            foregroundColor ?? (light ? Colors.black : Colors.white),
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
            _type == EnglishLayoutType.letter ? '123' : 'ABC',
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
          width: 5 * letterKeyWidth + 20,
          height: letterHeight,
          child: _buildLetterKey(
            'English',
            light,
            fontSize: 16,
            onPressed: () => insert(' '),
          ),
        ),
        SizedBox(
          width: 2.5 * letterKeyWidth + 7.5,
          height: letterHeight,
          child: _buildIconKey(
            configuration?.enterIcon ?? Icons.keyboard_return,
            light,
            performEnter,
            backgroundColor: configuration?.enterBackground,
            foregroundColor: configuration?.enterForeground,
          ),
        ),
      ],
    );
  }
}

enum EnglishLayoutType { letter, punctuation1, punctuation2 }
