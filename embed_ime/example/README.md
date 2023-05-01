```dart
class ZcodeLayout extends EmbedLayout {
  const ZcodeLayout(
    super.embedTextInput, {
    super.converter,
    super.key,
  });

  const ZcodeLayout.create(super.embedKeyboardState) : super(key: null);

  @override
  State<ZcodeLayout> createState() => ZcodeLayoutState();
}

class ZcodeLayoutState extends CommonMongolLayoutState<ZcodeLayout> {
  @override
  LayoutConverter get layoutConverter =>
      widget.converter ?? ZcodeLayoutTextConverter();
  @override
  String get layoutName => 'Zcode';
  @override
  String get softPunctuation => '1234567890-ᡐᡑᡕᡖ᠁@¥ᡡ•.,ᡓᡒ᠄';
  @override
  String get softPunctuationShift => 'ᡝᡞ{}ᡋ%^*+=ᡣ/~ᡛᡜᡗᡘᡙᡚ•.,ᡓᡒ᠄';
  @override
  String get verticalLetters => 'ᡐᡑᡕᡖ᠁ᡓᡒ᠄ᡝᡞ{}ᡣ~ᡛᡜᡗᡘᡙᡚ᠂᠃ᡥᡨ\nᡥᡧ';
  @override
  String mongolEA = 'ᡥᡨ\nᡥᡧ';
  @override
  String mongolCommaFullstop = '᠂᠃';
  @override
  Map<String, String> get hardPunctuations => {
        ',': '\u1802',
        '.': '\u1803',
        '!': '\u1852',
        '^': '\u1801',
        '*': '\u1861',
        '(': '\u1855',
        ')': '\u1856',
        '<': '\u1857',
        '>': '\u1858',
        '[': '\u1859',
        ']': '\u185A',
        ':': '\u1804',
        '"': '\u185B  \u185C',
        '?': '\u1853',
      };
}
```

> For more, [zcode_embed_ime](https://github.com/Satsrag/embed_input/tree/main/zcode_embed_ime)