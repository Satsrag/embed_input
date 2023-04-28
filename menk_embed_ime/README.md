Menksoft's old standard Mongolian Embed IME.

![](https://raw.githubusercontent.com/Satsrag/embed_input/main/desktop_screenshot.gif)

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
  menk_embed_ime: ^0.0.1
```

Run `Flutter pub get`.

#### 2. Add Zcode 52 Mongol Font

> If you using the `mongol` library, skip this step. However, please ensure that you are using a `Menksoft's old standard font` in your project.

* Get a [Menksoft's old standard font](https://www.mklai.cn/download-font?productId=a0ec7735b5714334934ff3c094ca0a5e)

* Add the font to your project

   > Basically you just need to create an fonts folder for it and then declare the font in pubspec.yaml like this:

   ```yaml
    flutter:
    fonts:
        - family: MenkQagan
        fonts:
            - asset: fonts/MQG8F02.ttf
   ```

* Set the default Mongol font for your app
   
   In your `main.dart` file, set the `fontFamily` for the app theme.

   ```dart
   MaterialApp(
      theme: ThemeData(fontFamily: 'MenkQagan'),
      // ...
   );
   ```

   Now you won't have to manually set the font for every text widget. If you want to use a different font for some widgets, though, you can still set the fontFamily as you normally would inside TextStyle.

#### 3. Use zcode_embed_ime

* Import library

   ```dart
   import 'package:menk_embed_ime/menk_embed_ime.dart';
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
             MenkLayout.create,
             EnglishLayout.create,
           ],
         ),
       ]),
     );
   }
   ```
After completing this step, the library is imported at the lowest cost. You run you project and see what's going on. 

However, after this step, there is no supporting the thesaurus database. Some words cannot be typed without supporting the thesaurus database. In the next version, I will fix this issue so that it can type all the words without relying on the thesaurus database. Thesaurus database should only be auxiliary.

There is no open source Menksoft's old standard thesaurus database. If you have a thesaurus, you can reference [zcode_embed_ime database-supporting](https://github.com/Satsrag/embed_input/tree/main/zcode_embed_ime#database-supporting) to import it to your Flutter app.

## Statement
This library uses the [mongol_code](https://pub.dev/packages/mongol_code) library.
The copyright belongs to [Suragch](https://github.com/suragch)