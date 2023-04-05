import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      body: Focus(
        onKeyEvent: (node, event) {
          debugPrint('event: $event');
          return KeyEventResult.handled;
        },
        child: const Center(
          child: TextField(),
        ),
      ),
    );
  }
}
