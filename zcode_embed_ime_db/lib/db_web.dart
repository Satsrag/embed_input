import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqlite3/wasm.dart';

CommonDatabase? zcodeDB;
const dbLength = 22212608;

void internalZcodeDBInit({String? dbUrl, String? sqlite3Url}) async {
  final fs = await IndexedDbFileSystem.open(dbName: 'indexedDB');
  // do not ignore slash, use absolute path
  final wordDbName = "/${basename(dbUrl ?? "/zcode_ime.db")}";
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
      final key = "packages/zcode_embed_ime_db/db$wordDbName";
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
  final sqlite = await WasmSqlite3.loadFromUrl(
      Uri.parse(sqlite3Url ?? 'sqlite3.wasm'),
      environment: SqliteEnvironment(fileSystem: fs));
  zcodeDB = sqlite.open(wordDbName);
}
