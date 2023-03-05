/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/widgets.dart';
import './embed_keyboard_layout.dart';

class PunctuationLayout extends EmbedKeyboardLayout {
  const PunctuationLayout.create(super.embedKeyboardState) : super(key: null);

  @override
  State<StatefulWidget> createState() => _PunctuationLayoutState();
}

class _PunctuationLayoutState extends State<PunctuationLayout> {
  @override
  Widget build(BuildContext context) {
    return const Text("MongolPunctuationLayout");
  }
}
