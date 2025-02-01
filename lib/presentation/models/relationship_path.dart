class RelationshipPath {
  List<String> from;
  List<String> to;
  RelationshipPath({required this.from, required this.to});

  String makePathString() {
    String fromString = from.map((String e) => '"$e"').join(", ");
    String toString = to.map((String e) => '"$e"').join(", ");
    String finalString = 'paths(from = c($fromString), to = c($toString))';
    return finalString;
  }
}
