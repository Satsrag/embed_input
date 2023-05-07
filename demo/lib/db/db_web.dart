import 'package:demo/db/db_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';

class DBWeb extends DBHelper {
  CommonDatabase? _db;
  static const dbLength = 22212608;

  @override
  void init() async {
    final fs = await IndexedDbFileSystem.open(dbName: 'indexedDB');
    // do not ignore slash, use absolute path
    const wordDbName = "/zcode_ime.db";
    final exists = fs.exists(wordDbName);
    final int size;
    if (exists) {
      size = fs.sizeOfFile(wordDbName);
    } else {
      size = 0;
    }
    debugPrint('db size: $size');
    if (!exists || size != dbLength) {
      final data = await rootBundle.load("db$wordDbName");
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      if (!exists) {
        fs.createFile(wordDbName);
      }
      fs.write(wordDbName, bytes, 0);
      await fs.flush();
    }

    final sqlite = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'),
        environment: SqliteEnvironment(fileSystem: fs));
    _db = sqlite.open(wordDbName);
  }

  @override
  List<String> dbSuggestion(String latin) {
    if (latin.isEmpty) return [];
    var qlatin = latin.toLowerCase();
    qlatin = qlatin.replaceAll('o', 'ʊ');
    var table = qlatin.substring(0, 1);
    table = table.replaceAll('g', 'h');
    table = table.replaceAll('d', 't');
    final result = _db?.select(
        'select word from $table where latin like \'$qlatin%\' order by count desc limit 15');
    final suggestion = result?.rows.map((e) => e[0] as String).toList();
    return suggestion ?? [];
  }

  @override
  List<String> nextSuggestion(String table, String text) {
    final sql = 'select relations from $table where word = \'${text.trim()}\'';
    final result = _db?.select(sql);
    if (result?.isEmpty ?? true) return [];
    final relations = result?.rows.first[0] as String;
    return relations.split(',').map((e) => e.trim()).toList();
  }
}

final DBHelper db = DBWeb();
