# embed_ime

![](https://raw.githubusercontent.com/Satsrag/embed_input/main/desktop_screenshot.gif)

This library is the basic component of the Mongolian embed IME.

Support all platforms: Android, Ios, Windows, Macos, Linux and web.

Now, this library has two implementations [zcode_embed_ime](https://github.com/Satsrag/embed_input/tree/main/zcode_embed_ime) and [menk_embed_ime](https://github.com/Satsrag/embed_input/tree/main/menk_embed_ime)

We can use this library to implement own any standard Mongolian embed IME. Just provide inputting logic and keyboard layout UI by implementing the `LayoutConverter` and `CommonMongolLayoutState` or `BaseEmbedTextInputControlState`.

## Background

The Mongolian Script has multiple standards: Zcode, MenkCode, UNICODE MONGOLIAN 10.0, UNICODE MONGOLIAN 12.1 SNAPSHOT, GB/T 25914-2010, and so on.

And this is also impossible that one app to support all these standards. 
The common way for the developers of the Mongolian app is to choose one standard to support.

This is impossible that one user to install all IME on his/her device. 
And this is also impossible that one app to support all these standards. 

So, we need to choose one standard, implement the input method to it and embed it into the app. This is what this library is for. 
