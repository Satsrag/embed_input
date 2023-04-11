import 'package:demo/db/db_helper.dart';

/// web can't use sqlite3, so we just return empty list
class DBWeb extends DBHelper {
  @override
  List<String> dbSuggestion(String latin) {
    return [];
  }

  @override
  void init() {}

  @override
  List<String> nextSuggestion(String text) {
    return [];
  }
}

final DBHelper db = DBWeb();
