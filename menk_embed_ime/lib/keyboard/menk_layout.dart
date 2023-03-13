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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  String get layoutName => 'Menk';

  @override
  bool onKeyEvent(KeyEvent event) {
    final case_ = keyMap[event.physicalKey];
    if ((event is KeyDownEvent) && case_ != null) {
      _stopEditingState = true;
      insert(case_.character);
      return true;
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
    final selectSuggestions = text.length == 1 && '1234567890 '.contains(text);
    if (selectSuggestions) {
      final insertText = _selectWordFromSuggestions(text);
      super.insert(insertText);
      layoutTextConverter.confirmWord(insertText);
      _showOrRefreshCandidate();
      return;
    }
    layoutTextConverter.appendTextForSuggestionWords(text);
    _showOrRefreshCandidate();
  }

  String _selectWordFromSuggestions(String index) {
    var numberIndex = 0;
    if (index == ' ') {
      numberIndex = 0;
    } else {
      numberIndex = '1234567890 '.indexOf(index);
    }
    final layoutTextConverter = _layoutTextConverter;
    if (layoutTextConverter.suggestionWords.length > numberIndex) {
      return layoutTextConverter.suggestionWords[numberIndex];
    }
    return index;
  }

  void _showOrRefreshCandidate() {
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
  void hide() {
    if (!visible) return;
    _hideCandidate();
    debugPrint('menk_layout -> hide');
    super.hide();
  }

  @override
  void dispose() {
    super.dispose();
    _hideCandidate();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
