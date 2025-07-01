import 'package:flutter/material.dart';
import 'package:menk_embed_ime_db/menk_embed_ime_db.dart';
import 'package:mongol/mongol.dart';

class MenkImeDemo extends StatefulWidget {
  const MenkImeDemo({super.key});

  @override
  State<MenkImeDemo> createState() => _MenkImeDemoState();
}

class _MenkImeDemoState extends State<MenkImeDemo> {
  @override
  Widget build(BuildContext context) {
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final theme = ThemeData(fontFamily: 'MenkQagan', brightness: brightness);
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text("Menk Embed Ime Demo")),
        body: Column(
          children: [
            const Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: MongolTextField(
                        expands: true,
                        minLines: null,
                        maxLines: null,
                        textAlignHorizontal: TextAlignHorizontal.left,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        minLines: null,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        expands: true,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextFieldTapRegion(
              child: EmbedKeyboard(
                layoutBuilders: [
                  (i) => MenkLayout(i, converter: DBMenkLayoutConverter()),
                  EnglishLayout.create,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A [TapRegion] that adds its children to the tap region group for widgets
/// based on the [EditableText] text editing widget, such as [TextField] and
/// [CupertinoTextField].
///
/// Widgets that are wrapped with a [TextFieldTapRegion] are considered to be
/// part of a text field for purposes of unfocus behavior. So, when the user
/// taps on them, the currently focused text field won't be unfocused by
/// default. This allows controls like spinners, copy buttons, and formatting
/// buttons to be associated with a text field without causing the text field to
/// lose focus when they are interacted with.
///
/// {@tool dartpad}
/// This example shows how to use a [TextFieldTapRegion] to wrap a set of
/// "spinner" buttons that increment and decrement a value in the text field
/// without causing the text field to lose keyboard focus.
///
/// This example includes a generic `SpinnerField<T>` class that you can copy/paste
/// into your own project and customize.
///
/// ** See code in examples/api/lib/widgets/tap_region/text_field_tap_region.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [TapRegion], the widget that this widget uses to add widgets to the group
///    of text fields.
class TextFieldTapRegion extends TapRegion {
  /// Creates a const [TextFieldTapRegion].
  ///
  /// The [child] field is required.
  const TextFieldTapRegion({
    super.key,
    required super.child,
    super.enabled,
    super.onTapOutside,
    super.onTapInside,
    super.consumeOutsideTaps,
    super.debugLabel,
  }) : super(groupId: MongolEditableText);
}
