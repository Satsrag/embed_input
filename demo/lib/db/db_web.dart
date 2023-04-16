import 'package:demo/db/db_helper.dart';
import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';

class DBWeb extends DBHelper {
  CommonDatabase? _db;
  static const dbLength = 22908928;

  @override
  void init() async {
    final fs = await IndexedDbFileSystem.open(dbName: 'indexedDB');
    // do not ignore slash, use absolute path
    const wordDbName = "/z52words03.db";
    final exists = fs.exists(wordDbName);
    final int size;
    if (exists) {
      size = fs.sizeOfFile(wordDbName);
    } else {
      size = 0;
    }
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
