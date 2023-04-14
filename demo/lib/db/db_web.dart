import 'dart:io';

import 'package:demo/db/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';

/// web can't use sqlite3, so we just return empty list
class DBWeb extends DBHelper {
  CommonDatabase? _db;

  @override
  void init() async {
    final fs = await IndexedDbFileSystem.open(dbName: 'indexedDB');
    const wordDbName = "/z52words03.db";
    final exists = fs.exists(wordDbName);
    if (!exists) {
      final data = await rootBundle.load("db$wordDbName");
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      debugPrint("not exists -> ${bytes.length}");
      fs.createFile(wordDbName);
      fs.write(wordDbName, bytes, 0);
      await fs.flush();
    } else {
      debugPrint("exists");
    }

    final sqlite = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'),
        environment: SqliteEnvironment(fileSystem: fs));
    _db = sqlite.open(wordDbName);
  }

  @override
  List<String> dbSuggestion(String latin) {
    if (latin.isEmpty) return [];
    final result = _db?.select(
        'select word from ${latin.substring(0, 1)} where latin like \'$latin%\' order by wlen limit 15');
    final suggestion = result?.rows.map((e) => e[0] as String).toList();
    return suggestion ?? [];
  }

  @override
  List<String> nextSuggestion(String text) {
    return [];
  }
}

final DBHelper db = DBWeb();
