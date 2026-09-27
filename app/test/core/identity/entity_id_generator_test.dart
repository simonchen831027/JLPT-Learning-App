import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';

void main() {
  test('generates distinct RFC 9562 UUID v7 strings', () {
    const generator = EntityIdGenerator();
    final ids = List.generate(512, (_) => generator.generate());
    final uuidV7 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    expect(ids, everyElement(isA<String>()));
    expect(ids, everyElement(matches(uuidV7)));
    expect(ids.toSet(), hasLength(ids.length));
  });
}
