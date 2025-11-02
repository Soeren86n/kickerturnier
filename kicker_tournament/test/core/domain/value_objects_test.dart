import 'package:flutter_test/flutter_test.dart';
import 'package:kicker_tournament/core/domain/value_objects.dart';
import 'package:kicker_tournament/core/exceptions.dart';

void main() {
  group('PlayerName', () {
    test('accepts valid names', () {
      expect(() => PlayerName('AB'), returnsNormally);
      expect(() => PlayerName('Alice'), returnsNormally);
      expect(() => PlayerName('  Bob  '), returnsNormally);
    });

    test('trims whitespace', () {
      final name = PlayerName('  Alice  ');
      expect(name.value, 'Alice');
    });

    test('throws ValidationException for empty name', () {
      expect(
        () => PlayerName(''),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('nicht leer'),
        )),
      );
    });

    test('throws ValidationException for whitespace-only name', () {
      expect(
        () => PlayerName('   '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException for single-char name', () {
      expect(
        () => PlayerName('A'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('mindestens 2 Zeichen'),
        )),
      );
    });

    test('equality works correctly', () {
      final name1 = PlayerName('Alice');
      final name2 = PlayerName('Alice');
      final name3 = PlayerName('Bob');

      expect(name1, equals(name2));
      expect(name1, isNot(equals(name3)));
    });
  });

  group('Goals', () {
    test('accepts valid goal counts', () {
      expect(() => Goals(0), returnsNormally);
      expect(() => Goals(5), returnsNormally);
      expect(() => Goals(100), returnsNormally);
    });

    test('throws ValidationException for negative goals', () {
      expect(
        () => Goals(-1),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('nicht negativ'),
        )),
      );
    });

    test('equality works correctly', () {
      final goals1 = Goals(5);
      final goals2 = Goals(5);
      final goals3 = Goals(3);

      expect(goals1, equals(goals2));
      expect(goals1, isNot(equals(goals3)));
    });
  });
}
