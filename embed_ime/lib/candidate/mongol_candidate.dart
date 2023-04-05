/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'dart:math';

import 'package:embed_ime/util/util.dart';
import 'package:flutter/material.dart';

import '../keyboard/layout_text_converter.dart';

/// A class that shows the candidate words with calling [_showOrRefresh] method
/// and dismisses the candidate words with calling [dismiss] method.
///
/// It has two cotnent styles: [_buildHardContent] and [_buildSoftContent].
///
/// [_buildHardContent] is shown when the user is typing using hard keyboard.
/// Candidate overlay follows the caret position both in vertical and horizontal.
///
/// [_buildSoftContent] is shown when the user is typing using soft keyboard.
/// Candidate overlay is shown at the top of the soft keyboard in vertical and
/// follows the caret position in horizontal.
class MongolCandidate {
  MongolCandidate(
      {required this.context,
      required this.layoutTextConverter,
      required this.directInsert});

  final BuildContext context;
  final LayoutTextConverter layoutTextConverter;
  final void Function(String insertText) directInsert;

  Point<double> caretRightBottomPoint = const Point(0, 0);
  double caretLongSize = 0;
  bool typingSoftKeyboard = false;

  OverlayEntry? _candidateBox;
  int _currentPage = 0;
  bool get isVisible => _candidateBox != null;

  String? convertInsert(String text) {
    final insertText = _selectWordFromSuggestionsIfNeeded(text);
    if (insertText != text) {
      layoutTextConverter.confirmWord(insertText);
      _showOrRefresh();
      return insertText;
    }
    final nextPageSuggestion = text == '=';
    final previousPageSuggestion = text == '-';
    if (nextPageSuggestion || previousPageSuggestion) {
      final suggestionWords = layoutTextConverter.suggestionWords;
      if (suggestionWords.isEmpty) {
        return text;
      }
      final page = _currentPage;
      final nextPage = page + 1;
      final previousPage = page - 1;
      final maxPage = (suggestionWords.length / 10).ceil() - 1;
      final nextPageIndex = nextPage > maxPage ? 0 : nextPage;
      final previousPageIndex = previousPage < 0 ? maxPage : previousPage;
      _currentPage = nextPageSuggestion ? nextPageIndex : previousPageIndex;
      _showOrRefresh();
      return null;
    }
    final latin = RegExp(r'[a-zA-Z]').matchAsPrefix(text) != null;
    if (latin) {
      layoutTextConverter.appendLayoutText(text);
      _showOrRefresh();
      return null;
    } else {
      final insertText = _selectWordFromSuggestionsIfNeeded(' ');
      if (' ' == insertText) {
        return '$text ';
      } else {
        layoutTextConverter.confirmWord(insertText);
        _showOrRefresh();
        return '$insertText$text ';
      }
    }
  }

  bool backspace() {
    if (layoutTextConverter.layoutText.isNotEmpty) {
      layoutTextConverter.backspaceLayoutText(false);
      _showOrRefresh();
      return true;
    }
    return false;
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
    if (layoutTextConverter.suggestionWords.length > numberIndex) {
      return '${layoutTextConverter.suggestionWords[numberIndex]} ';
    }
    return index;
  }

  void _showOrRefresh() {
    if (layoutTextConverter.layoutText.isEmpty &&
        layoutTextConverter.suggestionWords.isEmpty) {
      dismiss();
      return;
    }
    if (_candidateBox != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _candidateBox?.markNeedsBuild();
      });
      return;
    }
    _candidateBox = OverlayEntry(
      builder: (context) => typingSoftKeyboard
          ? _buildSoftContent(context)
          : _buildHardContent(context),
    );
    Overlay.of(context).insert(_candidateBox!);
  }

  Widget _buildSoftContent(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _buildHardContent(BuildContext context) {
    final suggestionWords = layoutTextConverter.suggestionWords;
    final layoutText = layoutTextConverter.layoutText;
    const candidateHeight = 200.0;
    final bool isLastPage;
    if (suggestionWords.isEmpty) {
      isLastPage = _currentPage == 0;
    } else {
      isLastPage = _currentPage == (suggestionWords.length - 1) ~/ 10;
    }
    final lastPageWordCount = suggestionWords.length % 10;
    final candidateWidth = isLastPage ? lastPageWordCount * 30.0 : 30.0 * 10;
    final currentPageMaxLength =
        isLastPage ? suggestionWords.length : _currentPage * 10 + 10;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // get app window size
    final windowSize = Util.windowSize;
    final left = caretRightBottomPoint.x + candidateWidth < windowSize.width
        ? caretRightBottomPoint.x
        : caretRightBottomPoint.x - candidateWidth - caretLongSize;
    final top = caretRightBottomPoint.y + candidateHeight < windowSize.height
        ? caretRightBottomPoint.y
        : caretRightBottomPoint.y - candidateHeight - caretLongSize;

    return Positioned(
      left: left,
      top: top,
      child: TextFieldTapRegion(
        child: Card(
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: candidateHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
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
                          index < currentPageMaxLength;
                          index++)
                        InkWell(
                          child: SizedBox(
                            width: 30,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Text(
                                  '${(index + 1) % 10}. ${suggestionWords[index]}',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: index % 10 == 0
                                        ? colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            final indexText = '1234567890'[index % 10];
                            final willInsertText = convertInsert(indexText);
                            if (willInsertText != null) {
                              directInsert(willInsertText);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void dismiss() {
    layoutTextConverter.backspaceLayoutText(true);
    _candidateBox?.remove();
    _candidateBox = null;
  }
}
