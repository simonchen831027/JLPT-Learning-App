import 'package:uuid/uuid.dart';

/// Creates entity IDs without exposing the UUID package to callers.
final class EntityIdGenerator {
  const EntityIdGenerator();

  static const _uuid = Uuid();

  String generate() => _uuid.v7();
}
