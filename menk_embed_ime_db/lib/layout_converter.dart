import 'dart:collection';

import 'package:menk_embed_ime/char_convertor.dart';
import 'package:menk_embed_ime/menk_embed_ime.dart';
import 'db_web.dart' if (dart.library.io) 'db_other.dart';

/// init menk word database.
///
/// If your app support `Web`, I recommend you to set optional params `dbUrl` and `sqlite3Url`.
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
void initMenkDB({String? dbUrl, String? sqlite3Url}) {
  internalMenkDBInit(dbUrl: dbUrl, sqlite3Url: sqlite3Url);
}

/// Extend [MenkLayoutConverter] to produce extra words for the Candidate
/// using the database. Also, support the next words suggestion.
class DBMenkLayoutConverter extends MenkLayoutConverter {
  @override
  void appendLayoutText(String text) {
    super.appendLayoutText(text);
    _updateSuggestion();
  }

  @override
  void backspaceLayoutText(bool clear) {
    super.backspaceLayoutText(clear);
    _updateSuggestion();
  }

  @override
  void confirmWord(String word) {
    super.confirmWord(word);
    final table = latinForCode(word.trim().codeUnitAt(0));
    if (table.isNotEmpty) {
      final words = _nextSuggestion(table, word);
      suggestionWords.addAll(words);
    }
  }

  void _updateSuggestion() {
    if (layoutText.isEmpty) return;
    LinkedHashSet<String> suggestions = LinkedHashSet.from(suggestionWords);
    var latin = layoutText.replaceAll('o', 'ʊ');
    suggestions.addAll(_dbSuggestion(latin));
    suggestionWords.clear();
    suggestionWords.addAll(suggestions);
  }

  List<String> _dbSuggestion(String latin) {
    if (latin.isEmpty) return [];
    var qlatin = latin.toLowerCase();
    qlatin = qlatin.replaceAll('o', 'ʊ');
    final table = qlatin.substring(0, 1);
    final result = menkDB?.select(
        'select word from $table where latin like \'$qlatin%\' order by count desc limit 15');
    final suggestion = result?.rows.map((e) => e[0] as String).toList();
    return suggestion ?? [];
  }

  List<String> _nextSuggestion(String table, String text) {
    final result = menkDB?.select(
      'select relations from $table where word = \'${text.trim()}\'',
    );
    if (result?.isEmpty ?? true) return [];
    final relations = result?.rows.first[0] as String;
    return relations.split(',').map((e) => e.trim()).toList();
  }
}
