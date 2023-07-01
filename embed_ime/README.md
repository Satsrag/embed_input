English is not my mother tongue, please correct the mistake.

# embed_ime

![](https://raw.githubusercontent.com/Satsrag/embed_input/main/desktop_screenshot.gif)

Web Demo [click here](https://satsrag.github.io)

This library is the basic component of the Mongolian embed IME.

Support all platforms: Android, Ios, Windows, Macos, Linux and web.

Now, this library has two implementations [zcode_embed_ime_db](https://github.com/Satsrag/embed_input/tree/main/zcode_embed_ime_db) and [menk_embed_ime_db](https://github.com/Satsrag/embed_input/tree/main/menk_embed_ime_db)

We can use this library to implement own any standard Mongolian embed IME. Just provide inputting logic and keyboard layout UI by implementing the `LayoutConverter` and `CommonMongolLayoutState` or `BaseEmbedTextInputControlState`.

## Background

The Mongolian Script has multiple standards: Zcode, MenkCode, UNICODE MONGOLIAN 10.0, UNICODE MONGOLIAN 12.1 SNAPSHOT, GB/T 25914-2010, and so on. Each standard maybe has its own IME for some platforms. Usually, Users have installed the IME of one standard on their devices. However, the app usually only supports one standard, and the user may not install the IME of the standard that the app supports. So, we need to embed the IME into the app. This is what this library is for.
