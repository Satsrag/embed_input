English is not my mother tongue, please correct the mistake.

Menksoft old standard Mongolian Embed IME with the word database. 

![](https://raw.githubusercontent.com/Satsrag/embed_input/main/desktop_screenshot.gif)

Web Demo [click here](https://satsrag.github.io)

> NOTE: This package uses the [sqlite3](https://pub.dev/packages/sqlite3) package. If your app using `sqlite3` or not any `SQLite` package, there is no problem using this package. However, using another library of `SQLite` package instead of sqlite3, such as [sqflite](https://pub.dev/packages/sqflite), may conflict with sqlite3. Anyway, you try to use this package first. After, if something is not working, there may be conflict. In this situation, please use the [menk_embed_ime](https://pub.dev/packages/menk_embed_ime) instead of this package. `menk_embed_ime` does not contain any word databases and SQLite package and just contains inputting logic. In this situation, you will import the Word database yourself and you can reference this package's [source code](https://github.com/Satsrag/embed_input/tree/main/menk_embed_ime_db).

## Features

* Embed into the Flutter app, support all platform.

* On mobile, use a soft keyboard by default.

* On mobile, the soft keyboard auto show or hide when one MongolTextField or TextField gets or loses focus.

* On the Desktop, use a hard keyboard by default.

* Show basic candidate words using the inputting logic.

* Show extra candidate words using the database.

* Show the next candidate words after the user selects a word from the Candidate Box.

* Support [`MongolTextField`](https://pub.dev/packages/mongol) and `TextField`.

## Getting started

> Although the [mongol](https://pub.dev/packages/mongol) library is optional, I recommend adding it. It contains `MongolTextField`, `MongolText`, and other vertical Mongol components. For convenience, in this guide, I did not import the `mongol` libray. 
If you want to use the `mongol` library, import the  the `mongol` library following the [official guide](https://pub.dev/packages/mongol) and replace `TextField` used in this guide with `MongolTextField`.

#### 1. Add needed library

```yaml
dependencies:
  menk_embed_ime_db: ^0.0.1
```

Run `Flutter pub get`.

#### 2. Add Menksoft's Old Dtatdard Mongol Font

> If you using the `mongol` library, skip this step. However, please ensure that you are using a `Menksoft's Old Dtatdard Mongol Font` in your project.

* Get a [Menksoft's Old Dtatdard Mongol Font](https://www.mklai.cn/download-font?productId=a0ec7735b5714334934ff3c094ca0a5e)

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

#### 3. Initialize word database

On your app's main.dart, add `initMenkDB`.

```dart
void main() {
  runApp(const DemoApp());
  initMenkDB();
}
```

> Note: This library is using asset files `sqlite3.wasm` and `menk_ime.db`. On the Web, these asset files may freeze your web app server because these files are too large and load from the web app server. In that case, I recommend you upload all asset files to your CDN server and customize initializing the engine using `initializeEngine`method with `assetBase`parameter, see [this](https://docs.flutter.dev/platform-integration/web/initialization#initializing-the-engine) for more details.

#### 4. Use menk_embed_ime_db

* Import library

   ```dart
   import 'package:menk_embed_ime_db/menk_embed_ime_db.dart';
   ```

* Add `EmbedKeyboard`

   ```dart
   @override
   Widget build() {
     return Scaffold(
       body: Column(children: [
        const Expanded(child: TextField()),
        EmbedKeyboard(
          layoutBuilders: [
            (i) => MenkLayout(i, converter: DBMenkLayoutConverter()),
            EnglishLayout.create,
          ],
        ),
       ]),
     );
   }
   ```
After completing this step, the library is imported at the lowest cost. You run your project and see what's going on. 

## Statement

This library uses the [mongol_code](https://pub.dev/packages/mongol_code) library.
The copyright belongs to [Suragch](https://github.com/suragch)

The word database is provided by [ZUGA](https://github.com/zuga-tech). The copyright belongs to `ZUGA`

If someone finds cannot input some words or has any other problem with this library, please feel free to open an issue or PR.
