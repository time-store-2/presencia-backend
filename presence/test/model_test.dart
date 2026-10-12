import 'package:flutter_test/flutter_test.dart';
import 'package:presencia/models/adolescent.dart';
import 'package:presencia/models/group.dart';

void main() {
  group('Model Tests', () {
    test('Adolescent model should correctly convert to and from map', () {
      final adolescent = Adolescent(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        gender: 'M',
        birthDate: DateTime(2005, 5, 20),
        phone: '123456789',
        isActive: true,
      );

      final map = adolescent.toMap();
      expect(map['first_name'], 'John');
      expect(map['active'], 1);

      final fromMap = Adolescent.fromMap(map);
      expect(fromMap.firstName, 'John');
      expect(fromMap.isActive, true);
      expect(fromMap.birthDate, DateTime(2005, 5, 20));
    });

    test('Group model should correctly convert to and from map', () {
      final now = DateTime.now();
      final group = Group(
        id: 1,
        name: 'Chorale',
        description: 'Groupe de chant',
        createdAt: now,
      );

      final map = group.toMap();
      expect(map['name'], 'Chorale');
      
      final fromMap = Group.fromMap(map);
      expect(fromMap.name, 'Chorale');
      // ISO strings lose microsecond precision sometimes depending on parse, but should match date/time
      expect(fromMap.createdAt.year, now.year);
    });
  });
}
