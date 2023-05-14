/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Util {
  static bool get isDesktop {
    return defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  // Here it is!
  static Size textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}

extension ContextEx on BuildContext {
  double get pixelRatio => View.of(this).devicePixelRatio;

  Size get windowSize => View.of(this).physicalSize / pixelRatio;

  double get windowWidth => windowSize.width;

  double get windowHeight => windowSize.height;
}
