/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'embed_keyboard.dart';

abstract class EmbedKeyboardLayout extends StatefulWidget {
  const EmbedKeyboardLayout(this.inputControl, {super.key});

  final EmbedKeyboardState inputControl;
}

