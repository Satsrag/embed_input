import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqlite3/wasm.dart';

CommonDatabase? menkDB;
const dbLength = 20621312;

/// init menk word database for web.
///
/// This library is using asset files `sqlite3.wasm` and `menk_ime.db`.
/// On the Web, these asset files may freeze your web app server because these
/// files are too large and load from the web app server. In that case,
/// I recommend you upload all asset files to your CDN server and customize
/// initializing the engine using `initializeEngine`method with `assetBase`
/// parameter, see [this](https://docs.flutter.dev/platform-integration/web/initializing-the-engine) for more details.
void internalMenkDBInit() async {
  final fs = await IndexedDbFileSystem.open(dbName: 'indexedDB');
  // do not ignore slash, use absolute path
  final wordDbName = "/${basename("/menk_ime.db")}";
  final xOpenResult =
      fs.xOpen(Sqlite3Filename(wordDbName), SqlFlag.SQLITE_OPEN_READWRITE|SqlFlag.SQLITE_OPEN_CREATE);
  final int size = xOpenResult.file.xFileSize();
  xOpenResult.file.xClose();
  if (size != dbLength) {
    final key = "packages/menk_embed_ime_db/db$wordDbName";
    final byteData = await rootBundle.load(key);
    final offset = byteData.offsetInBytes;
    final length = byteData.lengthInBytes;
    final data = byteData.buffer.asUint8List(offset, length);
    final xOpenResult =
        fs.xOpen(Sqlite3Filename(wordDbName), SqlFlag.SQLITE_OPEN_READWRITE|SqlFlag.SQLITE_OPEN_CREATE);
    xOpenResult.file.xWrite(data, 0);
    await fs.flush();
  }
  const key = "packages/menk_embed_ime_db/sqlite3.wasm";
  final byteData = await rootBundle.load(key);
  final offset = byteData.offsetInBytes;
  final length = byteData.lengthInBytes;
  final data = byteData.buffer.asUint8List(offset, length);
  WasmSqlite3 sqlite = await WasmSqlite3.load(data);
  sqlite.registerVirtualFileSystem(fs, makeDefault: true);
  menkDB = sqlite.open(wordDbName);
}
