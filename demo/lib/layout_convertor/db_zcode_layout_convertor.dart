import 'dart:collection';

import 'package:zcode_embed_ime/zcode_embed_ime.dart';
import '../db/db_web.dart' if (dart.library.io) '../db/db_other.dart';

class DBZcodeLayoutConvertor extends ZcodeLayoutTextConverter {
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

  void _updateSuggestion() {
    if (layoutText.isEmpty) return;
    LinkedHashSet<String> suggestions = LinkedHashSet.from(suggestionWords);
    var latin = layoutText.replaceAll('c', 'C');
    latin = layoutText.replaceAll('q', 'c');
    suggestions.addAll(db.dbSuggestion(latin));
    suggestionWords.clear();
    suggestionWords.addAll(suggestions);
  }
}
