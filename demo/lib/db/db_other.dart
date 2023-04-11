import 'dart:io';

import 'package:demo/db/db_helper.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DBOther extends DBHelper {
  Database? db;

  @override
  void init() async {
    if (db == null) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, "ime.db");
      if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
        ByteData data = await rootBundle.load('db/z52words03.db');
        final bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes);
      }
      db = sqlite3.open(path);
    }
  }

  @override
  List<String> dbSuggestion(String latin) {
    if (latin.isEmpty) return [];
    final result = db?.select(
        'select word from ${latin.substring(0, 1)} where latin like \'$latin%\' order by wlen limit 15');
    final suggestion = result?.rows.map((e) => e[0] as String).toList();
    return suggestion ?? [];
  }

  @override
  List<String> nextSuggestion(String text) {
    return [];
  }
}

final DBHelper db = DBOther();
