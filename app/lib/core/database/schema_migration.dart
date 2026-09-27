class SchemaMigration {
  SchemaMigration({
    required this.version,
    required this.name,
    required List<String> statements,
  }) : statements = List.unmodifiable(statements);
  final int version;
  final String name;
  final List<String> statements;
}
