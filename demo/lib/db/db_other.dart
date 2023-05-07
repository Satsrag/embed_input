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
      String path = join(documentsDirectory.path, "zcode_ime.db");
      if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
        ByteData data = await rootBundle.load('db/zcode_ime.db');
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
    var qlatin = latin.toLowerCase();
    qlatin = qlatin.replaceAll('o', 'ʊ');
    var table = qlatin.substring(0, 1);
    table = table.replaceAll('g', 'h');
    table = table.replaceAll('d', 't');
    final result = db?.select(
        'select word from $table where latin like \'$qlatin%\' order by count desc limit 15');
    final suggestion = result?.rows.map((e) => e[0] as String).toList();
    return suggestion ?? [];
  }

  @override
  List<String> nextSuggestion(String table, String text) {
    final result = db?.select(
      'select relations from $table where word = \'${text.trim()}\'',
    );
    if (result?.isEmpty ?? true) return [];
    final relations = result?.rows.first[0] as String;
    return relations.split(',').map((e) => e.trim()).toList();
  }
}

final DBHelper db = DBOther();
