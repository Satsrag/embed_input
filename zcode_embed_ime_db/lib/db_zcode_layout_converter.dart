import 'dart:collection';

import 'package:zcode_embed_ime/zcode_embed_ime.dart';
import 'db_web.dart' if (dart.library.io) 'db_other.dart';

/// init zcode word database.
///
/// This library is using asset files `sqlite3.wasm` and `zcode_ime.db`.
/// On the Web, these asset files may freeze your web app server because these
/// files are too large and load from the web app server. In that case,
/// I recommend you upload all asset files to your CDN server and customize
/// initializing the engine using `initializeEngine` method with `assetBase`
/// parameter, see [this](https://docs.flutter.dev/platform-integration/web/initialization#initializing-the-engine) for more details.
void initZcodeDB() {
  internalZcodeDBInit();
}

/// Extend [ZcodeLayoutTextConverter] to produce extra words for the Candidate
/// using the database. Also, support the next words suggestion.
class DBZcodeLayoutConverter extends ZcodeLayoutTextConverter {
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
    final table = preLatinForText(word.trim());
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
    var table = qlatin.substring(0, 1);
    table = table.replaceAll('g', 'h');
    table = table.replaceAll('d', 't');
    final result = zcodeDB?.select(
        'select word from $table where latin like \'$qlatin%\' order by count desc limit 15');
    final suggestion = result?.rows.map((e) => e[0] as String).toList();
    return suggestion ?? [];
  }

  List<String> _nextSuggestion(String table, String text) {
    final result = zcodeDB?.select(
      'select relations from $table where word = \'${text.trim()}\'',
    );
    if (result?.isEmpty ?? true) return [];
    final relations = result?.rows.first[0] as String;
    return relations.split(',').map((e) => e.trim()).toList();
  }
}
