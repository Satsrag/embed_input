/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'dart:math';

import 'package:embed_ime/util/util.dart';
import 'package:flutter/material.dart';
import '../layout/embed_layout.dart';
import '../layout/common_mongol_layout.dart';
import '../layout/layout_converter.dart';

/// The `MongolCandidate` is an overlay that shows the candidate words. It is
/// used by the implementation of the [BaseEmbedTextInputControlState] to show
/// the candidate words. See [CommonMongolLayoutState] for more details.
///
/// When the user taps a key of the soft/hard keyboard, call the [convertInsert]
/// or [backspace] to refresh the candidate words or confirm the word to insert.
/// Such as: pressing the English Letter key will call [convertInsert] to refresh
/// the candidate words, pressing the backspace key will call [backspace] to
/// delete the last character, and pressing the number key will call [convertInsert]
/// select one word from the candidate words.
///
/// It has two content styles: [_buildHardContent] and [_buildSoftContent].
class MongolCandidate {
  MongolCandidate({
    required this.context,
    required this.layoutTextConverter,
    required this.directInsert,
    required this.softLayoutTop,
  });

  final BuildContext context;
  final LayoutConverter layoutTextConverter;

  /// The callback is to insert the text directly. It is called when the user
  /// taps the candidate word. so the [insertText] is a confirmed word and needs
  /// to insert directly without any conversion.
  final void Function(String insertText) directInsert;

  /// The top point of the soft keyboard in the global coordinate system.
  final double Function() softLayoutTop;

  /// The right bottom point of the caret.
  Point<double> caretRightBottomPoint = const Point(0, 0);

  /// caret may be vertical or horizontal, this is the long side of the caret.
  double caretLongSize = 0;

  /// Tell the `MongolCandidate` whether the user is typing the soft keyboard or
  /// hard keyboard. true: soft keyboard, show the [_buildSoftContent],
  /// false: hard keyboard, show the [_buildHardContent].
  bool typingSoftKeyboard = false;

  OverlayEntry? _candidateBox;
  int _currentPage = 0;
  bool get isVisible => _candidateBox != null;

  String? convertInsert(String text) {
    if (text == '\n') {
      final layoutText = layoutTextConverter.layoutText;
      if (layoutText.isNotEmpty) {
        layoutTextConverter.confirmWord(layoutText);
        _showOrRefresh();
        return layoutText;
      } else {
        return text;
      }
    }
    final insertText = _selectWordFromSuggestionsIfNeeded(text);
    if (insertText != text) {
      layoutTextConverter.confirmWord('$insertText ');
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
      // Here the text is a Mongolian punctuation.
      layoutTextConverter.confirmWord(text);
      _showOrRefresh();
      return '$text ';
    }
  }

  bool backspace() {
    if (layoutTextConverter.layoutText.isNotEmpty ||
        layoutTextConverter.suggestionWords.isNotEmpty) {
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
    numberIndex = _currentPage * 10 + numberIndex;
    final suggestionWords = layoutTextConverter.suggestionWords;
    if (suggestionWords.length > numberIndex) {
      final confirmWord = suggestionWords[numberIndex];
      _currentPage = 0;
      return '$confirmWord ';
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

  /// [_buildSoftContent] is shown when the user is typing using soft keyboard.
  /// Candidate overlay is shown at the top of the soft keyboard in vertical and
  /// follows the caret position in horizontal.
  Widget _buildSoftContent(BuildContext context) {
    final windowSize = context.windowSize;
    final candidateWidth =
        30 * min(5, layoutTextConverter.suggestionWords.length);
    final bottom = windowSize.height - softLayoutTop();
    final left = caretRightBottomPoint.x + candidateWidth < windowSize.width
        ? caretRightBottomPoint.x
        : caretRightBottomPoint.x - candidateWidth - caretLongSize;
    final suggestions = layoutTextConverter.suggestionWords;
    // get max length text from suggestions
    final maxLengthText = suggestions.fold('', (previousValue, element) {
      return element.length > previousValue.length ? element : previousValue;
    });
    final labelText = layoutTextConverter.layoutText;
    return Positioned(
      left: left,
      bottom: bottom,
      child: Theme(
        data: Theme.of(this.context),
        child: TextFieldTapRegion(
          child: Card(
            child: Builder(builder: (context) {
              final textTheme = Theme.of(context).textTheme;
              final textStyle = textTheme.bodyMedium ?? const TextStyle();
              final suggestionTextSize =
                  Util.textSize(maxLengthText, textStyle);
              final labelTextSize = Util.textSize(labelText, textStyle);
              final height = max(suggestionTextSize.width, 50.0) +
                  (labelTextSize.height + 32.0);
              final width = max(
                  30.0 * min(5, suggestions.length), labelTextSize.width + 16);
              return SizedBox(
                width: width,
                height: height,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          layoutTextConverter.layoutText,
                          style: textTheme.bodyLarge,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const Divider(height: 0),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: layoutTextConverter.suggestionWords
                            .map(
                              (e) => InkWell(
                                child: SizedBox(
                                  width: 30,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: Text(e, style: textStyle),
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  layoutTextConverter.confirmWord(e);
                                  directInsert('$e ');
                                  _showOrRefresh();
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// [_buildHardContent] is shown when the user is typing using hard keyboard.
  /// Candidate overlay follows the caret position both in vertical and horizontal.
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
    final theme = Theme.of(this.context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final windowSize = context.windowSize;
    final left = caretRightBottomPoint.x + candidateWidth < windowSize.width
        ? caretRightBottomPoint.x
        : caretRightBottomPoint.x - candidateWidth - caretLongSize;
    final top = caretRightBottomPoint.y + candidateHeight < windowSize.height
        ? caretRightBottomPoint.y
        : caretRightBottomPoint.y - candidateHeight - caretLongSize;

    return Theme(
      data: theme,
      child: Positioned(
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
      ),
    );
  }

  void dismiss() {
    layoutTextConverter.backspaceLayoutText(true);
    _candidateBox?.remove();
    _candidateBox = null;
  }
}
