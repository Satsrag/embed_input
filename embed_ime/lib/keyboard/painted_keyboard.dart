/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Key type enumeration for different key styles
enum KeyType {
  letter,    // Normal letter key (white/light background)
  function,  // Function key like capslock, backspace (gray background)
  space,     // Space bar
  enter,     // Enter key (may have custom color)
}

/// Data model for a single key
class KeyData {
  const KeyData({
    required this.label,
    this.insertText,
    this.icon,
    this.type = KeyType.letter,
    required this.visualRect,
    required this.hitRect,
    this.onTap,
    this.onLongPress,
    this.isVertical = false,
    this.fontSize = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.selected = false,
  });

  /// Display text on the key
  final String label;

  /// Text to insert when key is pressed (uses label if null)
  final String? insertText;

  /// Icon to display (mutually exclusive with label for display)
  final IconData? icon;

  /// Type of key for styling
  final KeyType type;

  /// Visual rectangle for drawing (smaller, with gaps)
  final Rect visualRect;

  /// Hit test rectangle (larger, no gaps between keys)
  final Rect hitRect;

  /// Custom tap callback (if null, uses default insert behavior)
  final VoidCallback? onTap;

  /// Long press callback
  final VoidCallback? onLongPress;

  /// Whether to display text vertically (for Mongol text)
  final bool isVertical;

  /// Font size for the label
  final double fontSize;

  /// Custom background color (overrides type-based color)
  final Color? backgroundColor;

  /// Custom foreground color (overrides type-based color)
  final Color? foregroundColor;

  /// Whether this key is in selected state (e.g., capslock on)
  final bool selected;

  /// Get the text to insert
  String get textToInsert => insertText ?? label;

  /// Get center point of visual rect
  Offset get center => visualRect.center;
}

/// Painter for drawing all keyboard keys
class KeyboardPainter extends CustomPainter {
  KeyboardPainter({
    required this.keys,
    required this.light,
    this.pressedKeyIndex,
    required this.backgroundColor,
    required this.defaultTextStyle,
  });

  final List<KeyData> keys;
  final bool light;
  final int? pressedKeyIndex;
  final Color backgroundColor;
  final TextStyle defaultTextStyle;

  // Cache for text painters
  final Map<String, TextPainter> _textPainterCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final keyPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final isPressed = pressedKeyIndex == i;

      // Determine background color
      Color bgColor;
      if (key.backgroundColor != null) {
        bgColor = key.backgroundColor!;
      } else {
        bgColor = _getBackgroundColor(key.type, key.selected, light);
      }

      // Slightly darken if pressed
      if (isPressed) {
        bgColor = _darken(bgColor, 0.1);
      }

      keyPaint.color = bgColor;

      // Draw rounded rectangle background
      final rrect = RRect.fromRectAndRadius(
        key.visualRect,
        const Radius.circular(8),
      );
      canvas.drawRRect(rrect, keyPaint);

      // Determine foreground color
      Color fgColor;
      if (key.foregroundColor != null) {
        fgColor = key.foregroundColor!;
      } else {
        fgColor = light ? Colors.black : Colors.white;
      }

      // Draw icon or text
      if (key.icon != null) {
        _drawIcon(canvas, key, fgColor);
      } else {
        _drawText(canvas, key, fgColor);
      }
    }
  }

  void _drawIcon(Canvas canvas, KeyData key, Color color) {
    final icon = key.icon!;
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: 24,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(
      key.center.dx - textPainter.width / 2,
      key.center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);
  }

  void _drawText(Canvas canvas, KeyData key, Color color) {
    final fontFamily = defaultTextStyle.fontFamily ?? '';
    final cacheKey = '${key.label}_${key.fontSize}_${color.toARGB32()}_${key.isVertical}_$fontFamily';

    TextPainter textPainter;
    if (_textPainterCache.containsKey(cacheKey)) {
      textPainter = _textPainterCache[cacheKey]!;
    } else {
      textPainter = TextPainter(
        text: TextSpan(
          text: key.label,
          style: defaultTextStyle.copyWith(
            fontSize: key.fontSize,
            color: color,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      _textPainterCache[cacheKey] = textPainter;
    }

    if (key.isVertical) {
      // Rotate 90 degrees for vertical text
      canvas.save();
      canvas.translate(key.center.dx, key.center.dy);
      canvas.rotate(pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    } else {
      final offset = Offset(
        key.center.dx - textPainter.width / 2,
        key.center.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  Color _getBackgroundColor(KeyType type, bool selected, bool light) {
    switch (type) {
      case KeyType.letter:
      case KeyType.space:
        return light ? Colors.white : const Color.fromARGB(255, 130, 130, 130);
      case KeyType.function:
        if (selected) {
          return light ? Colors.white : const Color.fromARGB(255, 130, 130, 130);
        }
        return light
            ? const Color.fromARGB(255, 153, 162, 172)
            : const Color.fromARGB(255, 95, 95, 95);
      case KeyType.enter:
        return light
            ? const Color.fromARGB(255, 153, 162, 172)
            : const Color.fromARGB(255, 95, 95, 95);
    }
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant KeyboardPainter oldDelegate) {
    return oldDelegate.pressedKeyIndex != pressedKeyIndex ||
        oldDelegate.light != light ||
        oldDelegate.keys != keys ||
        oldDelegate.defaultTextStyle != defaultTextStyle;
  }
}

/// A high-performance keyboard widget using CustomPainter
class PaintedKeyboard extends StatefulWidget {
  const PaintedKeyboard({
    super.key,
    required this.keys,
    required this.keyboardHeight,
    required this.keyboardWidth,
    required this.light,
    required this.backgroundColor,
    this.onKeyTap,
    this.onKeyLongPress,
  });

  final List<KeyData> keys;
  final double keyboardHeight;
  final double keyboardWidth;
  final bool light;
  final Color backgroundColor;
  final Function(KeyData key)? onKeyTap;
  final Function(KeyData key)? onKeyLongPress;

  @override
  State<PaintedKeyboard> createState() => _PaintedKeyboardState();
}

class _PaintedKeyboardState extends State<PaintedKeyboard> {
  int? _pressedKeyIndex;
  Timer? _longPressTimer;
  OverlayEntry? _keyPreviewOverlay;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _removeKeyPreview();
    super.dispose();
  }

  void _removeKeyPreview() {
    _keyPreviewOverlay?.remove();
    _keyPreviewOverlay = null;
  }

  void _provideFeedback(KeyType keyType) {
    // Provide haptic feedback based on key type
    // Flutter automatically respects system settings for haptics
    switch (keyType) {
      case KeyType.letter:
      case KeyType.space:
        HapticFeedback.lightImpact();
        break;
      case KeyType.function:
        HapticFeedback.mediumImpact();
        break;
      case KeyType.enter:
        HapticFeedback.mediumImpact();
        break;
    }

    // Play system click sound (respects system settings)
    SystemSound.play(SystemSoundType.click);
  }

  void _showKeyPreview(KeyData key, TextStyle textStyle) {
    _removeKeyPreview();

    final renderBox = context.findRenderObject() as RenderBox;
    final keyboardOffset = renderBox.localToGlobal(Offset.zero);
    
    _keyPreviewOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: keyboardOffset.dx + key.visualRect.left + key.visualRect.width / 2 - 30,
        top: keyboardOffset.dy + key.visualRect.top - 60,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 60,
              height: 75,
              decoration: BoxDecoration(
                color: widget.light ? Colors.white : const Color.fromARGB(255, 130, 130, 130),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: key.icon != null
                    ? Icon(
                        key.icon,
                        size: 28,
                        color: key.foregroundColor ?? (widget.light ? Colors.black : Colors.white),
                      )
                    : key.isVertical
                        ? RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              key.label,
                              style: textStyle.copyWith(
                                fontSize: 28,
                                color: key.foregroundColor ?? (widget.light ? Colors.black : Colors.white),
                                height: 1,
                              ),
                            ),
                          )
                        : Text(
                            key.label,
                            style: textStyle.copyWith(
                              fontSize: 28,
                              color: key.foregroundColor ?? (widget.light ? Colors.black : Colors.white),
                              height: 1,
                            ),
                          ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_keyPreviewOverlay!);
  }

  int? _hitTestIndex(Offset position) {
    for (int i = 0; i < widget.keys.length; i++) {
      if (widget.keys[i].hitRect.contains(position)) {
        return i;
      }
    }
    return null;
  }

  void _onPointerDown(PointerDownEvent event) {
    final index = _hitTestIndex(event.localPosition);
    if (index != null) {
      if (mounted) setState(() => _pressedKeyIndex = index);

      final key = widget.keys[index];

      // Provide haptic and sound feedback (respects system settings)
      _provideFeedback(key.type);

      // Show key preview (iOS style)
      if (key.type == KeyType.letter || key.type == KeyType.space) {
        final defaultTextStyle = DefaultTextStyle.of(context).style;
        _showKeyPreview(key, defaultTextStyle);
      }

      // Trigger tap immediately on pointer down
      if (key.onTap != null) {
        key.onTap!();
      } else {
        widget.onKeyTap?.call(key);
      }

      // Start long press timer
      _longPressTimer?.cancel();
      if (key.onLongPress != null) {
        _longPressTimer = Timer(const Duration(milliseconds: 500), () {
          key.onLongPress?.call();
        });
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();
    _removeKeyPreview();
    if (mounted) setState(() => _pressedKeyIndex = null);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _removeKeyPreview();
    if (mounted) setState(() => _pressedKeyIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: CustomPaint(
        size: Size(widget.keyboardWidth, widget.keyboardHeight),
        painter: KeyboardPainter(
          keys: widget.keys,
          light: widget.light,
          pressedKeyIndex: _pressedKeyIndex,
          backgroundColor: widget.backgroundColor,
          defaultTextStyle: defaultTextStyle,
        ),
      ),
    );
  }
}

/// Helper class to build keyboard layout
class KeyboardLayoutBuilder {
  KeyboardLayoutBuilder({
    required this.keyboardWidth,
    required this.portrait,
  }) {
    letterKeyWidth = keyboardWidth / 10 - 5;
    letterKeyHeight = portrait ? letterKeyWidth * 9 / 7 : letterKeyWidth * 32 / 53;
    // Calculate horizontal gap based on spaceAround distribution
    // Total width = keyboardWidth, 10 keys of letterKeyWidth each
    // spaceAround: gap on edges = half of gap between items
    // Total gaps = keyboardWidth - 10 * letterKeyWidth
    // With spaceAround: 10 gaps between + 2 half gaps on edges = 11 equal portions
    horizontalGap = (keyboardWidth - 10 * letterKeyWidth) / 10;
  }

  final double keyboardWidth;
  final bool portrait;
  late final double letterKeyWidth;
  late final double letterKeyHeight;
  late final double horizontalGap;

  static const double topPadding = 5;
  static const double bottomPadding = 5;
  static const double rowGap = 10;

  double get totalHeight =>
      topPadding + letterKeyHeight * 4 + rowGap * 3 + bottomPadding;

  /// Build a standard row of keys
  List<KeyData> buildRow({
    required int rowIndex,
    required List<String> labels,
    required double startX,
    required double keyWidth,
    List<KeyType>? types,
    List<IconData?>? icons,
    List<VoidCallback?>? onTaps,
    List<VoidCallback?>? onLongPresses,
    List<bool>? verticals,
    List<double>? fontSizes,
    List<Color?>? backgroundColors,
    List<Color?>? foregroundColors,
    List<bool>? selecteds,
    List<String?>? insertTexts,
  }) {
    final List<KeyData> keys = [];
    final double y = topPadding + rowIndex * (letterKeyHeight + rowGap);
    double x = startX;

    for (int i = 0; i < labels.length; i++) {
      final double currentKeyWidth =
          (i < labels.length - 1 || labels.length == 1) ? keyWidth : keyWidth;

      // Visual rect (what user sees)
      final visualRect = Rect.fromLTWH(x, y, currentKeyWidth, letterKeyHeight);

      // Hit rect (extends to cover gaps)
      final hitRect = Rect.fromLTWH(
        x - horizontalGap / 2,
        y - (rowIndex == 0 ? topPadding : rowGap / 2),
        currentKeyWidth + horizontalGap,
        letterKeyHeight + (rowIndex == 0 ? topPadding : rowGap / 2) +
            (rowIndex == 3 ? bottomPadding : rowGap / 2),
      );

      keys.add(KeyData(
        label: labels[i],
        insertText: insertTexts?[i],
        icon: icons?[i],
        type: types?[i] ?? KeyType.letter,
        visualRect: visualRect,
        hitRect: hitRect,
        onTap: onTaps?[i],
        onLongPress: onLongPresses?[i],
        isVertical: verticals?[i] ?? false,
        fontSize: fontSizes?[i] ?? 20,
        backgroundColor: backgroundColors?[i],
        foregroundColor: foregroundColors?[i],
        selected: selecteds?[i] ?? false,
      ));

      x += currentKeyWidth + horizontalGap;
    }

    return keys;
  }

  /// Build row with variable width keys
  List<KeyData> buildVariableRow({
    required int rowIndex,
    required List<String> labels,
    required List<double> widths,
    List<KeyType>? types,
    List<IconData?>? icons,
    List<VoidCallback?>? onTaps,
    List<VoidCallback?>? onLongPresses,
    List<bool>? verticals,
    List<double>? fontSizes,
    List<Color?>? backgroundColors,
    List<Color?>? foregroundColors,
    List<bool>? selecteds,
    List<String?>? insertTexts,
  }) {
    final List<KeyData> keys = [];
    final double y = topPadding + rowIndex * (letterKeyHeight + rowGap);

    // Calculate total width and gaps
    final totalKeyWidth = widths.reduce((a, b) => a + b);
    final totalGaps = keyboardWidth - totalKeyWidth;
    final gapCount = widths.length + 1; // spaceAround has gaps on edges too
    final gap = totalGaps / gapCount;

    double x = gap / 2; // Start with half gap (spaceAround behavior)

    for (int i = 0; i < labels.length; i++) {
      final currentKeyWidth = widths[i];

      // Visual rect
      final visualRect = Rect.fromLTWH(x, y, currentKeyWidth, letterKeyHeight);

      // Hit rect - extend to midpoint between keys
      double hitLeft = i == 0 ? 0 : x - gap / 2;
      double hitRight = i == labels.length - 1
          ? keyboardWidth
          : x + currentKeyWidth + gap / 2;
      final hitRect = Rect.fromLTWH(
        hitLeft,
        y - (rowIndex == 0 ? topPadding : rowGap / 2),
        hitRight - hitLeft,
        letterKeyHeight + (rowIndex == 0 ? topPadding : rowGap / 2) +
            (rowIndex == 3 ? bottomPadding : rowGap / 2),
      );

      keys.add(KeyData(
        label: labels[i],
        insertText: insertTexts?[i],
        icon: icons?[i],
        type: types?[i] ?? KeyType.letter,
        visualRect: visualRect,
        hitRect: hitRect,
        onTap: onTaps?[i],
        onLongPress: onLongPresses?[i],
        isVertical: verticals?[i] ?? false,
        fontSize: fontSizes?[i] ?? 20,
        backgroundColor: backgroundColors?[i],
        foregroundColor: foregroundColors?[i],
        selected: selecteds?[i] ?? false,
      ));

      x += currentKeyWidth + gap;
    }

    return keys;
  }
}
