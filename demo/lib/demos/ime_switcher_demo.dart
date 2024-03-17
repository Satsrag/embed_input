/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';
import 'package:zcode_embed_ime_db/zcode_embed_ime_db.dart';

class ImeSwitcherDemo extends StatefulWidget {
  const ImeSwitcherDemo({super.key});

  @override
  State<ImeSwitcherDemo> createState() => _ImeSwitcherDemoState();
}

class _ImeSwitcherDemoState extends State<ImeSwitcherDemo> {
  final showNotificator = ValueNotifier<bool>(false);
  final focusNodes = List<FocusNode?>.filled(4, null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.apply(fontFamily: 'ZcodeQagan');
    return Theme(
      data: theme.copyWith(textTheme: textTheme),
      child: Scaffold(
          appBar: AppBar(title: const Text('IME Switcher Demo')),
          body: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MongolTextField(
                            focusNode: focusNodes[0] ??= WillFocusNode(() {
                              showNotificator.value = true;
                            }),
                            decoration: const InputDecoration(
                              border: MongolOutlineInputBorder(),
                              labelText: 'Use Embed IME',
                            ),
                          ),
                          const SizedBox(width: 8),
                          MongolTextField(
                            focusNode: focusNodes[1] ??= WillFocusNode(() {
                              showNotificator.value = false;
                            }),
                            decoration: const InputDecoration(
                              border: MongolOutlineInputBorder(),
                              labelText: 'Use System IME',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            focusNode: focusNodes[2] ??= WillFocusNode(() {
                              showNotificator.value = true;
                            }),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Use Embed IME',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            focusNode: focusNodes[3] ??= WillFocusNode(() {
                              showNotificator.value = false;
                            }),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Use System IME',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              EmbedKeyboard(
                assumeControlNotifier: showNotificator,
                layoutBuilders: [
                  (i) => ZcodeLayout(i, converter: DBZcodeLayoutConverter()),
                  EnglishLayout.create
                ],
              ),
            ],
          )),
    );
  }
}

class WillFocusNode extends FocusNode {
  WillFocusNode(this.willFocusCallback);

  final VoidCallback willFocusCallback;

  @override
  void requestFocus([FocusNode? node]) {
    willFocusCallback();
    super.requestFocus(node);
  }
}
