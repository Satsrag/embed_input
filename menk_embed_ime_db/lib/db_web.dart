import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqlite3/wasm.dart';

CommonDatabase? menkDB;
const dbLength = 22212608;

/// init menk word database for web.
///
/// Upload [menk_ime.db](https://github.com/Satsrag/embed_input/blob/main/menk_embed_ime_db/db/menk_ime.db)
/// and [sqlite3.wasm](https://github.com/Satsrag/embed_input/blob/main/menk_embed_ime_db/sqlite3.wasm)
/// to your object server supporting CDN. These files are too large to maybe
/// freeze your Web app server if you do not set [dbUrl] and [sqlite3Url]. If
/// you not setting these parameters, this package will fetch these files from
/// your Web app server.
///
/// [dbUrl] is the URL of the `menk_ime.db` file you uploaded.
/// [sqlite3Url] is the URL of the `sqlite3.wasm` file you uploaded.
void internalMenkDBInit({String? dbUrl, String? sqlite3Url}) async {
  final fs = await IndexedDbFileSystem.open(dbName: 'indexedDB');
  // do not ignore slash, use absolute path
  final wordDbName = "/${basename(dbUrl ?? "/menk_ime.db")}";
  final exists = fs.exists(wordDbName);
  final int size;
  if (exists) {
    size = fs.sizeOfFile(wordDbName);
  } else {
    size = 0;
  }
  if (!exists || size != dbLength) {
    final Uint8List data;
    if (dbUrl == null) {
      final key = "packages/menk_embed_ime_db/db$wordDbName";
      final byteData = await rootBundle.load(key);
      final offset = byteData.offsetInBytes;
      final length = byteData.lengthInBytes;
      data = byteData.buffer.asUint8List(offset, length);
    } else {
      final response = await get(Uri.parse(dbUrl));
      data = response.bodyBytes;
    }
    if (!exists) {
      fs.createFile(wordDbName);
    }
    fs.write(wordDbName, data, 0);
    await fs.flush();
  }
  final WasmSqlite3 sqlite;
  final env = SqliteEnvironment(fileSystem: fs);
  if (sqlite3Url == null) {
    const key = "packages/menk_embed_ime_db/sqlite3.wasm";
    final byteData = await rootBundle.load(key);
    final offset = byteData.offsetInBytes;
    final length = byteData.lengthInBytes;
    final data = byteData.buffer.asUint8List(offset, length);
    sqlite = await WasmSqlite3.load(data, env);
  } else {
    final uri = Uri.parse(sqlite3Url);
    sqlite = await WasmSqlite3.loadFromUrl(uri, environment: env);
  }
  menkDB = sqlite.open(wordDbName);
}