/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
import 'dart:math';

import 'package:embed_ime/embed_ime.dart';
import 'package:embed_ime/keyboard/key_map.dart';
import 'package:embed_ime/layout/english_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menk_embed_ime/keyboard/char_convertor.dart';
import 'package:menk_embed_ime/keyboard/menk_input_text_convertor.dart';
import 'package:mongol/mongol.dart';

class MenkLayout extends EmbedKeyboardLayout {
  const MenkLayout.create(super.embedKeyboardState) : super(key: null);

  @override
  State<MenkLayout> createState() => _MenkLayoutState();
}

class _MenkLayoutState extends BaseEmbedTextInputControlState<MenkLayout> {
  final _layoutTextConverter = MenkLayoutTextConverter();
  bool _stopEditingState = false;
  int _currentPage = 0;
  OverlayEntry? _candidateBox;

  var _type = EnglishLayoutType.letter;
  var _capslock = false;
  var _qwerty = 'qwertyuiopasdfghjklzxcvbnm';
  final _punctuation1 = '1234567890()@¥•.,';
  final _punctuation2 = '{}#%^*+=/~•.,';
  final _verticalLetters = '(){}~\n';

  @override
  String get layoutName => 'Menk';

  @override
  void detach() {
    super.detach();
    _hideCandidate();
  }

  @override
  bool onKeyEvent(KeyEvent event) {
    final case_ = keyMap[event.physicalKey];
    if ((event is KeyDownEvent) && case_ != null) {
      _stopEditingState = true;
      final menkPunctuation = punctuations[case_.character];
      if (menkPunctuation != null) {
        insert(menkPunctuation);
      } else {
        insert(case_.character);
      }
      return true;
    }
    final interceptBackspace =
        (event is KeyDownEvent || event is KeyRepeatEvent) &&
            event.physicalKey == PhysicalKeyboardKey.backspace &&
            _layoutTextConverter.layoutText.isNotEmpty;
    debugPrint("menk_layout -> event: $event interceptBackspace:$interceptBackspace");
    if (interceptBackspace) {
      backspace();
      return true;
    }
    final interceptEscape = (event is KeyDownEvent) &&
        event.physicalKey == PhysicalKeyboardKey.escape &&
        _layoutTextConverter.layoutText.isNotEmpty;
    if (interceptEscape) {
      _layoutTextConverter.backspaceLayoutText(true);
      _showOrRefreshCandidate();
    }
    if (event is KeyUpEvent && case_ != null) {
      _stopEditingState = false;
      TextInput.updateEditingValue(editingValue);
      return true;
    }
    return false;
  }

  @override
  void insert(String text) {
    final layoutTextConverter = _layoutTextConverter;
    final insertText = _selectWordFromSuggestionsIfNeeded(text);
    if (insertText != text) {
      super.insert(insertText);
      layoutTextConverter.confirmWord(insertText);
      _showOrRefreshCandidate();
      return;
    }
    final latin = RegExp(r'[a-zA-Z]').matchAsPrefix(text) != null;
    if (latin) {
      layoutTextConverter.appendLayoutText(text);
      _showOrRefreshCandidate();
    } else {
      final insertText = _selectWordFromSuggestionsIfNeeded(' ');
      if (' ' == insertText) {
        super.insert('$text ');
      } else {
        super.insert('$insertText$text ');
        layoutTextConverter.confirmWord(insertText);
        _showOrRefreshCandidate();
      }
    }
  }

  String _selectWordFromSuggestionsIfNeeded(String index) {
    var numberIndex = 0;
    if (index == ' ') {
      numberIndex = 0;
    } else {
      numberIndex = '1234567890'.indexOf(index);
    }
    if (numberIndex < 0) {
      return index;
    }
    final layoutTextConverter = _layoutTextConverter;
    if (layoutTextConverter.suggestionWords.length > numberIndex) {
      return '${layoutTextConverter.suggestionWords[numberIndex]} ';
    }
    return index;
  }

  @override
  bool backspace({int length = 1}) {
    debugPrint('menk_layout -> backspace');
    if (_layoutTextConverter.layoutText.isNotEmpty) {
      debugPrint('menk_layout -> _layoutTextConverter isNotEmpty');
      _layoutTextConverter.backspaceLayoutText(false);
      _showOrRefreshCandidate();
      return true;
    } else {
      debugPrint('menk_layout -> _layoutTextConverter empty');
      return super.backspace(length: length);
    }
  }

  void _showOrRefreshCandidate() {
    debugPrint("menk_layout -> _showOrRefreshCandidate");
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
    final suggestionWords = layoutTextConverter.suggestionWords;
    if (suggestionWords.isEmpty) {
      return const SizedBox.shrink();
    }
    final layoutText = layoutTextConverter.layoutText;
    const candidateHeight = 200.0;
    final maxLength = min(10 * _currentPage + 10, suggestionWords.length);
    final candidateWidth = (maxLength - 10 * _currentPage) * 30.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;
    final textTheme = theme.textTheme;
    return Positioned(
      top: caretRightBottomOffset.dy,
      left: caretRightBottomOffset.dx,
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
    debugPrint("menk_layout -> _hideCandidate");
    _layoutTextConverter.backspaceLayoutText(true);
    _candidateBox?.remove();
    _candidateBox = null;
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
    _hideCandidate();
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
          ? MongolText(
              letter,
              style: TextStyle(fontSize: fontSize ?? 20, height: 1),
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
            _type == EnglishLayoutType.letter ? '123' : '\n',
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
            '',
            light,
            onPressed: () => insert(''),
          ),
        ),
        SizedBox(
          width: 3 * letterKeyWidth + 10,
          height: letterHeight,
          child: _buildLetterKey(
            'Menk',
            light,
            fontSize: 16,
            onPressed: () => insert(' '),
          ),
        ),
        SizedBox(
          width: letterKeyWidth,
          height: letterHeight,
          child: _buildLetterKey(
            '',
            light,
            onPressed: () => insert(''),
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
