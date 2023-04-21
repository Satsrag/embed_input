/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
import 'package:embed_ime/embed_ime.dart';
import 'package:flutter/material.dart';
import 'menk_layout_converter.dart';

class MenkLayout extends EmbedLayout {
  const MenkLayout(
    super.embedTextInput, {
    super.converter,
    super.key,
  });

  const MenkLayout.create(super.embedTextInput) : super(key: null);

  @override
  State<MenkLayout> createState() => MenkLayoutState();
}

/// Todo: Define the constants to the Menk characters
/// Note: You need to set the one Menk font to the IDE, otherwise, the Menk
/// characters can not be readable.
class MenkLayoutState extends CommonMongolLayoutState<MenkLayout> {
  @override
  LayoutConverter get layoutConverter =>
      widget.converter ?? MenkLayoutConverter();

  @override
  String layoutName = 'Menk';

  @override
  String mongolCommaFullstop = '';

  @override
  String mongolEA = '\n';

  @override
  String softPunctuation = '1234567890()@¥•.,';

  @override
  String softPunctuationShift = '{}#%^*+=/~•.,';

  @override
  String verticalLetters = '(){}~\n';

  @override
  Map<String, String> hardPunctuations = {
    ',': '',
    '.': '',
    '!': '',
    '^': '',
    '*': '',
    '(': '',
    ')': '',
    '<': '',
    '>': '',
    '[': '',
    ']': '',
    ':': '',
    '"': '  ',
    '?': '',
  };
}
