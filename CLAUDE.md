# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Mongolian Input Method Editor (IME) project that embeds into Flutter applications. The project consists of multiple Dart/Flutter packages that provide different Mongolian script input methods:

- **embed_ime**: Core base library with fundamental IME components (keyboard, layouts, text input handling)
- **menk_embed_ime**: Menksoft's old standard Mongolian script implementation
- **menk_embed_ime_db**: Database-backed version of Menksoft implementation with SQLite support
- **zcode_embed_ime**: Zcode 52 standard Mongolian script implementation  
- **zcode_embed_ime_db**: Database-backed version of Zcode implementation with SQLite support
- **demo**: Flutter demo application showcasing all IME implementations

## Architecture

### Core Components (embed_ime)
- `EmbedKeyboard`: Main keyboard widget that handles both soft and hard keyboard input
- `EmbedLayout`: Abstract base class for different keyboard layouts
- `EmbedTextInput`: Text input control and management
- `LayoutConverter`: Abstract converter for text transformation between input and display formats
- `MongolCandidate`: Candidate word suggestion component

### Layout System
- Layouts are modular and pluggable via `LayoutBuilder` functions
- Each IME implementation provides its own layout converter
- Supports both desktop (hard keyboard) and mobile (soft keyboard) input
- English layout fallback for non-Mongolian input

### Database Integration  
- Web support uses SQLite WASM (`sqlite3.wasm`)
- Native platforms use standard SQLite
- Database files stored in `db/` directories contain IME-specific data

## Common Development Commands

### Running the Demo
```bash
cd demo
flutter pub get
flutter run
```

### Running Tests
```bash
# Test specific package
cd [package_name]
flutter test

# Test all packages
flutter test demo/test/
flutter test embed_ime/test/
flutter test menk_embed_ime/test/
flutter test zcode_embed_ime/test/
```

### Building for Different Platforms
```bash
cd demo
flutter build web
flutter build apk
flutter build ios
flutter build macos
flutter build linux
flutter build windows
```

### Package Management
```bash
# Get dependencies for all packages
cd embed_ime && flutter pub get
cd menk_embed_ime && flutter pub get
cd menk_embed_ime_db && flutter pub get
cd zcode_embed_ime && flutter pub get  
cd zcode_embed_ime_db && flutter pub get
cd demo && flutter pub get
```

## Key Implementation Notes

### Font Dependencies
- MenkQagan font (`MQG8F02.ttf`) for Menksoft script
- ZcodeQagan font (`z52tsagaantig.ttf`) for Zcode script
- Fonts are bundled in demo app and must be declared in `pubspec.yaml`

### Platform Considerations
- Desktop platforms automatically detect hard keyboard presence
- Mobile platforms default to soft keyboard layout
- Web builds require WASM SQLite files for database functionality

### Text Input Flow
1. `EmbedKeyboard` captures input events
2. Active layout processes keys through its converter
3. Converter transforms input using IME-specific logic
4. Candidate suggestions provided via database lookup
5. Final text committed to Flutter's text input system

## Package Dependencies Structure
```
embed_ime (base)
├── menk_embed_ime → depends on embed_ime
├── menk_embed_ime_db → depends on menk_embed_ime  
├── zcode_embed_ime → depends on embed_ime
└── zcode_embed_ime_db → depends on zcode_embed_ime

demo → depends on menk_embed_ime_db, zcode_embed_ime_db
```