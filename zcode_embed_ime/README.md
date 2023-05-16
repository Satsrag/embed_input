English is not my mother tongue, please correct the mistake.

Zcode 52 standard Mongolian Embed IME.

![](https://raw.githubusercontent.com/Satsrag/embed_input/main/desktop_screenshot.gif)

Web Demo [click here](https://satsrag.github.io)

## Features

* Embed into the Flutter app, support all platform.

* On mobile, use a soft keyboard by default.

* On mobile, the soft keyboard auto show or hide when one MongolTextField or TextField gets or loses focus.

* On the Desktop, use a hard keyboard by default.

* support database

* support [`MongolTextField`](https://pub.dev/packages/mongol) and `TextField`.

## Getting started

> Although the [mongol](https://pub.dev/packages/mongol) library is optional, I recommend adding it. It contains `MongolTextField`, `MongolText`, and other vertical Mongol components. For convenience, in this guide, I did not import the `mongol` libray.
If you want to use the `mongol` library, import the  the `mongol` library following the [official guide](https://pub.dev/packages/mongol) and replace `TextField` used in this guide with `MongolTextField`.

#### 1. Add needed library

```yaml
dependencies:
  zcode_embed_ime: ^0.0.2
```

Run `Flutter pub get`.

#### 2. Add Zcode 52 Mongol Font

> If you using the `mongol` library, skip this step. However, please ensure that you are using a `Zcode 52 font` in your project.

* Get a [Zcode font](https://install.zcodetech.com/)

* Add the font to your project

   > Basically you just need to create an fonts folder for it and then declare the font in pubspec.yaml like this:

   ```yaml
    flutter:
    fonts:
        - family: ZcodeQagan
        fonts:
            - asset: fonts/z52tsagaantig.ttf
   ```

* Set the default Mongol font for your app
   
   In your `main.dart` file, set the `fontFamily` for the app theme.

   ```dart
   MaterialApp(
      theme: ThemeData(fontFamily: 'ZcodeQagan'),
      // ...
   );
   ```

   Now you won't have to manually set the font for every text widget. If you want to use a different font for some widgets, though, you can still set the fontFamily as you normally would inside TextStyle.

#### 3. Use zcode_embed_ime

* Import library

   ```dart
   import 'package:zcode_embed_ime/zcode_embed_ime.dart';
   ```

* Add `EmbedKeyboard`

   ```dart
   @override
   Widget build() {
     return Scaffold(
       body: Column(children: [
         const Expanded(child: TextField()),
         EmbedKeyboard(
           layoutBuilders: const [
             ZcodeLayout.create,
             EnglishLayout.create,
           ],
         ),
       ]),
     );
   }
   ```
After completing this step, the library is imported at the lowest cost. You run your project and see what's going on. 

However, after this step, there is no supporting the thesaurus database. Some words cannot be typed without supporting the thesaurus database. In the next version, I will fix this issue so that it can type all the words without relying on the thesaurus database. Thesaurus database should only be auxiliary.

### Supporting thesaurus database

Please use [zcode_embed_ime_db](https://pub.dev/packages/zcode_embed_ime_db) instead of this library, if you want to support the thesaurus database. [zcode_embed_ime_db](https://pub.dev/packages/zcode_embed_ime_db) using [sqlite3](https://pub.dev/packages/sqlite3) libray and [zcode_ime.db](https://github.com/Satsrag/embed_input/tree/main/zcode_embed_ime_db/db) to show candidate words. 

## Statement

The Zcode inputting logic is copied from [Zmongol's](https://github.com/zmongol) [zmongol2021](https://github.com/zmongol/zmongol2021) library.
The copyright belongs to Zmongol.

If someone finds cannot input some words or has any other problem with this library, please feel free to open an issue or PR.