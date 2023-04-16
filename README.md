# Embed Input method

The Mongolian Script has multiple standards: Zcode, MenkCode, UNICODE MONGOLIAN 10.0, UNICODE MONGOLIAN 12.1 SNAPSHOT, GB/T 25914-2010, and so on.
Each standard has its own fonts and IME. This is impossible that one user to install all IME on his/her device. 
And this is also impossible that one app to support all these standards. 
The common way for the developers of the Mongolian app is to choose one standard to support.
However, the users don't know which standard is used by the app and don't know how to install the IME. They don't care about it.
So, we need to choose one standard, implement the input method to it and embed it into the app. This is what this library is for.
Now, this library support Zcode, Menkcode, English layout.

## todo

* Add Database

* Fix bugs (has more bugs right now)

    * Pressed enter insert latin when candidate is showing

    * switch layout with keyboard

* README.md of usage

* Add document
  
* Possibility to add mongolian unicode layout

* Release 0.0.1

* Support input action