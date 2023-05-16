import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

CommonDatabase? zcodeDB;

/// init zcode word database for platform other than web.
/// [dbUrl] and [sqlite3Url] will not need to set. They are for web platform.
void internalZcodeDBInit({String? dbUrl, String? sqlite3Url}) async {
  if (zcodeDB == null) {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "zcode_ime.db");
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load('db/zcode_ime.db');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }
    zcodeDB = sqlite3.open(path);
  }
}
