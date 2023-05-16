English is not my mother tongue, please correct the mistake.

Zcode 52 standard Mongolian Embed IME with the word database. 

![](https://raw.githubusercontent.com/Satsrag/embed_input/main/desktop_screenshot.gif)

Web Demo [click here](https://satsrag.github.io)

> NOTE: This package uses the [sqlite3](https://pub.dev/packages/sqlite3) package. If your app using `sqlite3` or not any `SQLite` package, there is no problem using this package. However, using another library of `SQLite` package instead of sqlite3, such as [sqflite](https://pub.dev/packages/sqflite), may conflict with sqlite3. Anyway, you try to use this package first. After, if something is not working, there may be conflict. In this situation, please use the [zcode_embed_ime](https://pub.dev/packages/zcode_embed_ime) instead of this package. `zcode_embed_ime` does not contain any word databases and SQLite package and just contains inputting logic. In this situation, you will import the Word database yourself and you can reference this package's [source code](https://github.com/Satsrag/embed_input/tree/main/zcode_embed_ime_db).

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
  zcode_embed_ime_db: ^0.0.1
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

#### 3. Initialize word database

On your app's main.dart, add `initZcodeDB`.

```dart
void main() {
  runApp(const DemoApp());
  initZcodeDB();
}
```

If your app support `Web`, I recommend you to set optional params `dbUrl` and `sqlite3Url`. 

```dart
void main() {
  runApp(const DemoApp());
  initZcodeDB(
    dbUrl: "https://zcode_ime.db/remote/path",
    sqlite3Url: "https://sqlite3.wasm/remote/path",
  );
}
```

Upload [zcode_ime.db](https://github.com/Satsrag/embed_input/blob/main/zcode_embed_ime_db/db/zcode_ime.db) and [sqlite3.wasm](https://github.com/Satsrag/embed_input/blob/main/zcode_embed_ime_db/sqlite3.wasm) to your object server supporting CDN. These files are too large to maybe freeze your Web app server if you do not set `dbUrl` and `sqlite3Url`. If you not setting these parameters, this package will fetch these files from your Web app server.

`dbUrl` is the URL of the `zcode_ime.db` file you uploaded.
`sqlite3Url` is the URL of the `sqlite3.wasm` file you uploaded.

#### 4. Use zcode_embed_ime_db

* Import library

   ```dart
   import 'package:zcode_embed_ime_db/zcode_embed_ime_db.dart';
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
            (i) => ZcodeLayout(i, converter: DBZcodeLayoutConverter()),
            EnglishLayout.create,
          ],
        ),
       ]),
     );
   }
   ```
After completing this step, the library is imported at the lowest cost. You run your project and see what's going on. 

## Statement

The Zcode inputting logic is copied from [Zmongol's](https://github.com/zmongol) [zmongol2021](https://github.com/zmongol/zmongol2021) library. The copyright belongs to Zmongol.

The word database is provided by [ZUGA](https://github.com/zuga-tech). The copyright belongs to `ZUGA`

If someone finds cannot input some words or has any other problem with this library, please feel free to open an issue or PR.
