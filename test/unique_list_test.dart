import 'package:collection/collection.dart' show ListEquality;
import 'package:unique_list/unique_list.dart';
import 'package:test/test.dart';

void main() {
  final eq = ListEquality().equals;

  final list = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  group('Constructors', () {
    test('Default', () {
      expect(eq(UniqueList<int>(), <int>[]), equals(true));
    });

    test('Strict', () {
      expect(eq(UniqueList<int>.strict(), <int>[]), equals(true));
    });

    test('Empty', () {
      expect(eq(UniqueList<int>.empty(), List<int>.empty()), equals(true));
    });

    group('From', () {
      test('Standard', () {
        final uniqueList = UniqueList<int>.from(list);
        expect(eq(uniqueList, list), equals(true));
      });

      test('Non-Nullable', () {
        final uniqueList =
            UniqueList<int>.from(list + [null, null, null], nullable: false);
        expect(eq(uniqueList, list + [null]), equals(true));
      });

      test('Strict', () {
        Error error;

        try {
          UniqueList<int>.from(list + [0, 1, 2], strict: true);
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValuesError, equals(true));
      });
    });

    group('Of', () {
      test('Standard', () {
        final uniqueList = UniqueList<int>.of(list);

        expect(eq(uniqueList, list), equals(true));
      });

      test('Non-Nullable', () {
        final uniqueList =
            UniqueList<int>.of(list + [null, null, null], nullable: false);

        expect(eq(uniqueList, list + [null]), equals(true));
      });

      test('Strict', () {
        Error error;

        try {
          UniqueList<int>.of(list + [0, 1, 2], strict: true);
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValuesError, equals(true));
      });
    });

    group('Generate', () {
      test('Standard', () {
        final uniqueList = UniqueList<int>.generate(10, (index) => index);
        expect(eq(uniqueList, list), equals(true));
      });

      test('Non-Nullable', () {
        final uniqueList = UniqueList<int>.generate(
            20, (index) => index % 2 != 0 ? null : index ~/ 2,
            nullable: false);

        expect(eq(uniqueList, List<int>.from(list)..insert(1, null)),
            equals(true));
      });

      test('Strict', () {
        Error error;

        try {
          UniqueList<int>.generate(20, (_) => 0, strict: true);
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValuesError, equals(true));
      });
    });

    group('Unmodifiable', () {
      test('Standard', () {
        final uniqueList = UniqueList<int>.unmodifiable(list);

        expect(eq(uniqueList, list), equals(true));
      });

      test('Non-Nullable', () {
        Error error;

        try {
          UniqueList<int>.unmodifiable(list + [null, null], nullable: false);
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValuesError, equals(true));
      });
    });
  });

  group('Methods & Setters', () {
    group('FollowedBy', () {
      test('Standard', () {
        final uniqueList = UniqueList<int>.of([0, 1, 2, 3, 4])
            .followedBy([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]).toUniqueList();

        expect(eq(uniqueList, list), equals(true));
      });

      test('Strict', () {
        var uniqueList = UniqueList<int>.of([0, 1, 2, 3, 4], strict: true);

        Error error;

        try {
          uniqueList.followedBy([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]).toUniqueList();
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValueError, equals(true));

        uniqueList =
            uniqueList.followedBy([5, 6, 7, 8, 9]).toUniqueList(strict: true);

        expect(eq(uniqueList, list), equals(true));
      });
    });

    test('Set First', () {
      final uniqueList = UniqueList<int>.of(list);

      Error error;

      try {
        uniqueList.first = 5;
      } catch (e) {
        error = e;
      }

      expect(error is DuplicateValueError, equals(true));

      uniqueList.first = 0;

      expect(eq(uniqueList, list), equals(true));

      uniqueList.first = 10;

      expect(eq(uniqueList, List<int>.of(list)..first = 10), equals(true));
    });

    test('Set Last', () {
      final uniqueList = UniqueList<int>.of(list);

      Error error;

      try {
        uniqueList.last = 5;
      } catch (e) {
        error = e;
      }

      expect(error is DuplicateValueError, equals(true));

      uniqueList.last = 9;

      expect(eq(uniqueList, list), equals(true));

      uniqueList.last = 10;

      expect(eq(uniqueList, List<int>.of(list)..last = 10), equals(true));
    });

    group('Add', () {
      test('Standard', () {
        final uniqueList = UniqueList<int>.of(list);
        uniqueList.add(0);

        expect(eq(uniqueList, list), equals(true));

        uniqueList.add(10);

        expect(eq(uniqueList, List<int>.of(list)..add(10)), equals(true));
      });

      test('Strict', () {
        final uniqueList = UniqueList<int>.of(list, strict: true);

        Error error;

        try {
          uniqueList.add(0);
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValueError, equals(true));

        uniqueList.add(10);

        expect(eq(uniqueList, List<int>.of(list)..add(10)), equals(true));
      });
    });

    group('AddAll', () {
      test('Standard', () {
        final uniqueList = UniqueList<int>.of(list);

        uniqueList.addAll([0, 1, 2, 3, 4]);

        expect(eq(uniqueList, list), equals(true));

        uniqueList.addAll([8, 9, 10, 11, 12]);

        expect(eq(uniqueList, List<int>.of(list)..addAll([10, 11, 12])),
            equals(true));
      });

      test('Strict', () {
        final uniqueList = UniqueList<int>.of(list, strict: true);

        Error error;

        try {
          uniqueList.addAll([0, 1, 2, 3, 4]);
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValueError, equals(true));

        uniqueList.addAll([10, 11, 12]);

        expect(eq(uniqueList, List<int>.of(list)..addAll([10, 11, 12])),
            equals(true));
      });
    });

    group('Insert', () {
      test('Standard', () {
        final uniqueList = UniqueList<int>.of(list);
        uniqueList.insert(1, 9);

        expect(
            eq(
                uniqueList,
                List<int>.of(list)
                  ..remove(9)
                  ..insert(1, 9)),
            equals(true));
      });

      test('Strict', () {
        final uniqueList = UniqueList<int>.of(list, strict: true);

        Error error;

        try {
          uniqueList.insert(1, 9);
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValueError, equals(true));

        uniqueList.insert(1, 10);

        expect(eq(uniqueList, List<int>.of(list)..insert(1, 10)), equals(true));
      });
    });

    group('InsertAll', () {
      test('Standard', () {
        final uniqueList = UniqueList<int>.of(list);
        final sublist = <int>[7, 8, 9, 10, 11, 12];

        uniqueList.insertAll(1, sublist);

        expect(
            eq(
                uniqueList,
                List<int>.of(list)
                  ..removeRange(7, 10)
                  ..insertAll(1, sublist)),
            equals(true));
      });

      test('Strict', () {
        final uniqueList = UniqueList<int>.of(list, strict: true);

        Error error;

        try {
          uniqueList.insertAll(1, <int>[7, 8, 9]);
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValueError, equals(true));
        expect(eq(uniqueList, list), equals(true));

        final sublist = <int>[10, 11, 12, 13, 14];

        uniqueList.insertAll(1, sublist);

        expect(eq(uniqueList, List<int>.of(list)..insertAll(1, sublist)),
            equals(true));
      });
    });

    test('SetAll', () {
      final uniqueList = UniqueList<int>.of(list);

      Error error;

      try {
        uniqueList.setAll(2, <int>[7, 6, 5, 4, 3]);
      } catch (e) {
        error = e;
      }

      expect(error is DuplicateValueError, equals(true));
      expect(eq(uniqueList, list), equals(true));

      final sublist = <int>[10, 11, 12, 13];

      uniqueList.setAll(2, sublist);

      expect(
          eq(uniqueList, List<int>.of(list)..setAll(2, sublist)), equals(true));
    });

    test('SetRange', () {
      final uniqueList = UniqueList<int>.of(list);

      Error error;

      try {
        uniqueList.setRange(0, 10, list.reversed, 3);
      } catch (e) {
        error = e;
      }

      expect(error is DuplicateValueError, equals(true));
      expect(eq(uniqueList, list), equals(true));

      final sublist = list.map((value) => value + 10);

      uniqueList.setRange(3, 10, sublist, 3);

      expect(eq(uniqueList, List<int>.of(list)..setRange(3, 10, sublist, 3)),
          equals(true));
    });

    group('FillRange', () {
      test('Standard', () {
        final uniqueList = UniqueList<int>.of(list);

        uniqueList.fillRange(5, 10, 10);

        expect(eq(uniqueList, list.sublist(0, 5)..add(10)), equals(true));

        uniqueList.fillRange(0, 6, null);

        expect(uniqueList.every((value) => value == null), equals(true));
      });

      test('Fixed-Length', () {
        final uniqueList = UniqueList<int>.of(list, growable: false);

        uniqueList.fillRange(5, 10, 10);

        final expectedList = List<int>.of(list)
          ..fillRange(5, 10)
          ..[5] = 10;

        expect(eq(uniqueList, expectedList), equals(true));
      });

      test('Fixed-Length & Non-Nullable', () {
        final uniqueList =
            UniqueList<int>.of(list, growable: false, nullable: false);

        Error error;

        try {
          uniqueList.fillRange(5, 10, 10);
        } catch (e) {
          error = e;
        }

        expect(
            error.toString(),
            equals('Unsupported operation: Cannot fill values from '
                'a non-nullable fixed-length list.'));

        uniqueList.fillRange(5, 6, null);

        expect(eq(uniqueList, List<int>.of(list)..[5] = null), equals(true));
      });

      test('Strict', () {
        final uniqueList = UniqueList<int>.of(list, strict: true);

        Error error;

        try {
          uniqueList.fillRange(5, 10, 0);
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValueError, equals(true));
        expect(eq(uniqueList, list), equals(true));

        uniqueList.fillRange(5, 6, 5);

        expect(eq(uniqueList, list), equals(true));
      });
    });

    test('ReplaceRange', () {
      final uniqueList = UniqueList<int>.of(list);
      final sublist1 = list.sublist(3, 7).reversed;

      Error error;

      try {
        uniqueList.replaceRange(3, 7, sublist1);
      } catch (e) {
        error = e;
      }

      expect(error is DuplicateValueError, equals(true));
      expect(eq(uniqueList, list), equals(true));

      final sublist2 = <int>[10, 11, 12, 13];
      final expectedList = List<int>.of(list)..replaceRange(3, 7, sublist2);

      uniqueList.replaceRange(3, 7, sublist2);

      expect(eq(uniqueList, expectedList), equals(true));

      try {
        uniqueList.replaceRange(8, 11, sublist1);
      } catch (e) {
        error = e;
      }

      expect(error is RangeError, equals(true));
      expect(eq(uniqueList, expectedList), equals(true));
    });

    test('[]= Operator', () {
      final uniqueList = UniqueList<int>.of(list);
      uniqueList[5] = 5;

      expect(eq(uniqueList, list), equals(true));

      Error error;

      try {
        uniqueList[5] = 9;
      } catch (e) {
        error = e;
      }

      expect(error is DuplicateValueError, equals(true));
      expect(eq(uniqueList, list), equals(true));

      uniqueList[5] = 12;

      final expectedList = List<int>.of(list);
      expectedList[5] = 12;

      expect(eq(uniqueList, expectedList), equals(true));
    });

    group('+ Operator', () {
      test('Standard', () {
        var uniqueList = UniqueList<int>.of(list);
        final sublist = List<int>.of([1, 2, 3, 10, 11, 12]);

        uniqueList += sublist;

        expect(eq(uniqueList, list + <int>[10, 11, 12]), equals(true));
      });

      test('Non-Nullable', () {
        final uniqueList = UniqueList<int>.of(list, nullable: false);
        final newList = uniqueList + UniqueList<int>.of([1, 2, 3, 10, 11, 12]);

        expect(newList.nullable, equals(false));
        expect(eq(newList, list + <int>[10, 11, 12]), equals(true));
      });

      test('Strict', () {
        final uniqueList = UniqueList<int>.of(list, strict: true);

        Error error;

        try {
          uniqueList + List<int>.of([1, 2, 3, 10, 11, 12]);
        } catch (e) {
          error = e;
        }

        expect(error is DuplicateValueError, equals(true));
        expect(eq(uniqueList, list), equals(true));

        final sublist = List<int>.of([10, 11, 12]);
        final newList = uniqueList + sublist;

        expect(newList.strict, equals(true));
        expect(eq(newList, list + sublist), equals(true));
      });
    });
  });
}
