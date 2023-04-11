abstract class DBHelper {
  void init();

  List<String> dbSuggestion(String latin);

  List<String> nextSuggestion(String text);
}
