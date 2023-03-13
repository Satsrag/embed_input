/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
import 'package:embed_ime/embed_ime.dart';
import 'package:flutter/widgets.dart';

class MenkLayout extends EmbedKeyboardLayout {
  const MenkLayout.create(super.embedKeyboardState) : super(key: null);

  @override
  State<MenkLayout> createState() => _MenkLayoutState();
}

class _MenkLayoutState extends BaseEmbedTextInputControlState<MenkLayout> {
  @override
  String get layoutName => 'Menk';

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
