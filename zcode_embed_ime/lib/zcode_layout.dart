/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:embed_ime/embed_ime.dart';
import 'package:flutter/material.dart';

import 'zcode_layout_converter.dart';

/// This class is used to define the Zcode layout.
class ZcodeLayout extends EmbedLayout {
  const ZcodeLayout(
    super.embedTextInput, {
    super.converter,
    super.key,
  });

  const ZcodeLayout.create(super.embedKeyboardState) : super(key: null);

  @override
  State<ZcodeLayout> createState() => ZcodeLayoutState();
}

/// Todo: Define the constants to the Zcode characters
/// Note: You need to set the one Zcode font to the IDE, otherwise, the Zcode
/// characters can not be readable.
class ZcodeLayoutState extends CommonMongolLayoutState<ZcodeLayout> {
  // \u1801 ᠁ \u1802 ᠂\u1803 ᠃ \u1804 ᠄ \u1805 ᠅ \u1808 ᠈ \u1809 ᠉ \u184A ᡊ
  // \u184B ᡋ \u184C ᡌ \u184D ᡍ \u184E ᡎ \u184F ᡏ \u1850 ᡐ \u1851 ᡑ \u1852 ᡒ
  // \u1853 ᡓ \u1854 ᡔ \u1855 ᡕ \u1856 ᡖ \u1857 ᡗ \u1858 ᡘ \u1859 ᡙ \u185A ᡚ
  // \u185B ᡛ \u185C ᡜ \u185D ᡝ \u185E ᡞ \u185F ᡟ \u1860 ᡠ \u1861 ᡡ \u1862 ᡢ
  // \u1863 ᡣ
  @override
  LayoutConverter get layoutConverter =>
      widget.converter ?? ZcodeLayoutTextConverter();
  @override
  String get layoutName => 'Zcode';
  @override
  String get softPunctuation => '1234567890-ᡐᡑᡕᡖ᠁@¥ᡡ•.,ᡓᡒ᠄';
  @override
  String get softPunctuationShift => 'ᡝᡞ{}ᡋ%^*+=ᡣ/~ᡛᡜᡗᡘᡙᡚ•.,ᡓᡒ᠄';
  @override
  String get verticalLetters => 'ᡐᡑᡕᡖ᠁ᡓᡒ᠄ᡝᡞ{}ᡣ~ᡛᡜᡗᡘᡙᡚ᠂᠃ᡥᡨ\nᡥᡧ';
  @override
  String mongolEA = 'ᡥᡨ\nᡥᡧ';
  @override
  String mongolCommaFullstop = '᠂᠃';
  @override
  Map<String, String> get hardPunctuations => {
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
}
