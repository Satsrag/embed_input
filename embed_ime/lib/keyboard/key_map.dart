/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
import 'package:flutter/services.dart';

class Case {
  final String upperCase;
  final String lowerCase;

  String get character {
    return isUppercase ? upperCase : lowerCase;
  }

  const Case(this.upperCase, this.lowerCase);
}

bool get isShiftPressed {
  return HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.shiftLeft) ||
      HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.shiftRight);
}

bool get isUppercase {
  return HardwareKeyboard.instance.lockModesEnabled
          .contains(KeyboardLockMode.capsLock) ||
      (!HardwareKeyboard.instance.lockModesEnabled
              .contains(KeyboardLockMode.capsLock) &&
          isShiftPressed);
}

final keyMap = {
  PhysicalKeyboardKey.keyA: const Case('A', 'a'),
  PhysicalKeyboardKey.keyB: const Case('B', 'b'),
  PhysicalKeyboardKey.keyC: const Case('C', 'c'),
  PhysicalKeyboardKey.keyD: const Case('D', 'd'),
  PhysicalKeyboardKey.keyE: const Case('E', 'e'),
  PhysicalKeyboardKey.keyF: const Case('F', 'f'),
  PhysicalKeyboardKey.keyG: const Case('G', 'g'),
  PhysicalKeyboardKey.keyH: const Case('H', 'h'),
  PhysicalKeyboardKey.keyI: const Case('I', 'i'),
  PhysicalKeyboardKey.keyJ: const Case('J', 'j'),
  PhysicalKeyboardKey.keyK: const Case('K', 'k'),
  PhysicalKeyboardKey.keyL: const Case('L', 'l'),
  PhysicalKeyboardKey.keyM: const Case('M', 'm'),
  PhysicalKeyboardKey.keyN: const Case('N', 'n'),
  PhysicalKeyboardKey.keyO: const Case('O', 'o'),
  PhysicalKeyboardKey.keyP: const Case('P', 'p'),
  PhysicalKeyboardKey.keyQ: const Case('Q', 'q'),
  PhysicalKeyboardKey.keyR: const Case('R', 'r'),
  PhysicalKeyboardKey.keyS: const Case('S', 's'),
  PhysicalKeyboardKey.keyT: const Case('T', 't'),
  PhysicalKeyboardKey.keyU: const Case('U', 'u'),
  PhysicalKeyboardKey.keyV: const Case('V', 'v'),
  PhysicalKeyboardKey.keyW: const Case('W', 'w'),
  PhysicalKeyboardKey.keyX: const Case('X', 'x'),
  PhysicalKeyboardKey.keyY: const Case('Y', 'y'),
  PhysicalKeyboardKey.keyZ: const Case('Z', 'z'),
  PhysicalKeyboardKey.digit1: const Case('!', '1'),
  PhysicalKeyboardKey.digit2: const Case('@', '2'),
  PhysicalKeyboardKey.digit3: const Case('#', '3'),
  PhysicalKeyboardKey.digit4: const Case('\$', '4'),
  PhysicalKeyboardKey.digit5: const Case('%', '5'),
  PhysicalKeyboardKey.digit6: const Case('^', '6'),
  PhysicalKeyboardKey.digit7: const Case('&', '7'),
  PhysicalKeyboardKey.digit8: const Case('*', '8'),
  PhysicalKeyboardKey.digit9: const Case('(', '9'),
  PhysicalKeyboardKey.digit0: const Case(')', '0'),
  PhysicalKeyboardKey.minus: const Case('_', '-'),
  PhysicalKeyboardKey.equal: const Case('+', '='),
  PhysicalKeyboardKey.bracketLeft: const Case('{', '['),
  PhysicalKeyboardKey.bracketRight: const Case('}', ']'),
  PhysicalKeyboardKey.backslash: const Case('|', '\\'),
  PhysicalKeyboardKey.semicolon: const Case(';', ':'),
  PhysicalKeyboardKey.quote: const Case('"', "'"),
  PhysicalKeyboardKey.backquote: const Case('~', '`'),
  PhysicalKeyboardKey.comma: const Case('<', ','),
  PhysicalKeyboardKey.period: const Case('>', '.'),
  PhysicalKeyboardKey.slash: const Case('?', '/'),
  PhysicalKeyboardKey.space: const Case(' ', ' '),
};
