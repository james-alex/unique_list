import 'dart:math' show Random;
import 'helpers/errors.dart';
import 'helpers/typedefs.dart';

/// Adds a method to [Iterable] to create a [UniqueList] containing
/// the elements of this iterable.
extension ToUniqueList<E> on Iterable<E> {
  /// Creates an [UniqueList] containing the elements of this iterable.
  ///
  /// The elements are in iteration order.
  ///
  /// The list is fixed-length if [growable] is `false`.
  ///
  /// If [strict] is `true`, every value in this iterable must be unique,
  /// otherwise a [DuplicateValuesError] will be thrown. If `false`, duplicate
  /// values will be removed from the list, with only the first occurence of
  /// the value remaining.
  UniqueList<E> toUniqueList({
    bool growable = true,
    bool nullable = true,
    bool strict = false,
  }) {
    final list = UniqueList._constructListFrom<E>(this,
        nullable: nullable, strict: strict);
    return UniqueList._(List<E>.from(list, growable: growable),
        nullable: nullable, strict: strict);
  }
}

/// An implementation of [List] that enforces all values be unique.
class UniqueList<E> implements List<E> {
  /// Constructs a new [UniqueList].
  ///
  /// If [strict] is `true`, a [DuplicateValueError] will be thrown when a value
  /// is added to the list that already exists in the list.
  ///
  /// If [nullable] is `true`, the list may contain multiple instances of `null`,
  /// otherwise, `null` will be treated like any other value and only
  /// one instance of `null` may be contained in the list.
  UniqueList({
    bool strict = false,
    bool nullable = true,
  })  : _elements = <E>[],
        nullable = false,
        strict = false;

  /// Creates a [UniqueList] wrapped around [_elements].
  UniqueList._(this._elements, {this.nullable = true, this.strict = false})
      : assert(!_containsDuplicateValues(_elements, nullable: nullable));

  /// The underlying [List] containing all of the elements in this list.
  final List<E> _elements;

  /// If `true`, the list may contain multiple instances of `null`,
  /// otherwise, `null` will be treated like any other value and only
  /// one instance of `null` may be contained in the list.
  final bool nullable;

  /// If `true`, a [DuplicateValueError] will be thrown when a value
  /// is added to the list that already exists.
  final bool strict;

  /// Creates a new UniqueList that throws [DuplicateValueError]s if a value
  /// is added to the list already exists in the list.
  ///
  /// If [length] is provided, a fixed-length list will be created, otherwise
  /// a growable list will be created. __Note:__ To create a growable, strict
  /// and non-nullable list, use [UniqueList.empty] and set the [strict] and
  /// [nullable] parameters to `true` and `false` respectively.
  factory UniqueList.strict() => UniqueList._(<E>[], strict: true);

  /// Creates a new empty list.
  ///
  /// If [growable] is `false`, which is the default, the list is a fixed-length
  /// list of length zero. If [growable] is `true`, the list is growable and
  /// equivalent to `<E>[]`.
  ///
  /// If [strict] is `true`, a [DuplicateValueError] will be thrown when a value
  /// is added to the list that already exists in the list.
  ///
  /// If [nullable] is `true`, the list may contain multiple instances of `null`,
  /// otherwise, `null` will be treated like any other value and only
  /// one instance of `null` may be contained in the list.
  factory UniqueList.empty({
    bool growable = false,
    bool strict = false,
    bool nullable = true,
  }) {
    return UniqueList<E>._(List<E>.empty(growable: growable),
        nullable: nullable, strict: strict);
  }

  /// Creates a list containing all [elements].
  ///
  /// The [Iterator] of [elements] provides the order of the elements.
  ///
  /// All the [elements] should be instances of [E].
  /// The `elements` iterable itself may have any element type, so this
  /// constructor can be used to down-cast a `List`, for example as:
  /// ```dart
  /// List<SuperType> superList = ...;
  /// List<SubType> subList =
  ///     new List<SubType>.from(superList.whereType<SubType>());
  /// ```
  ///
  /// This constructor creates a growable list when [growable] is true;
  /// otherwise, it returns a fixed-length list.
  ///
  /// If [strict] is `true`, a [DuplicateValuesError] will be thrown when a value
  /// is added to the list that already exists in the list.
  ///
  /// If [nullable] is `true`, the list may contain multiple instances of `null`,
  /// otherwise, `null` will be treated like any other value and only
  /// one instance of `null` may be contained in the list.
  factory UniqueList.from(
    Iterable<E> elements, {
    bool growable = true,
    bool strict = false,
    bool nullable = true,
  }) {
    final list =
        _constructListFrom<E>(elements, nullable: nullable, strict: strict);
    return UniqueList<E>._(List<E>.from(list, growable: growable),
        nullable: nullable, strict: strict);
  }

  /// Creates a list from [elements].
  ///
  /// The [Iterator] of [elements] provides the order of the elements.
  ///
  /// This constructor creates a growable list when [growable] is true;
  /// otherwise, it returns a fixed-length list.
  ///
  /// If [strict] is `true`, a [DuplicateValuesError] will be thrown when a value
  /// is added to the list that already exists in the list.
  ///
  /// If [nullable] is `true`, the list may contain multiple instances of `null`,
  /// otherwise, `null` will be treated like any other value and only
  /// one instance of `null` may be contained in the list.
  factory UniqueList.of(
    Iterable<E> elements, {
    bool growable = true,
    bool strict = false,
    bool nullable = true,
  }) {
    final list =
        _constructListFrom<E>(elements, nullable: nullable, strict: strict);
    return UniqueList<E>._(List<E>.of(list, growable: growable),
        nullable: nullable, strict: strict);
  }

  /// Generates a list of values.
  ///
  /// Creates a list with [length] positions and fills it with values created by
  /// calling [generator] for each index in the range `0` .. `length - 1`
  /// in increasing order.
  /// ```dart
  /// List<int>.generate(3, (int index) => index/// index); // [0, 1, 4]
  /// ```
  /// The created list is fixed-length if [growable] is set to false.
  ///
  /// If [strict] is `true`, a [DuplicateValueError] will be thrown when a value
  /// is added to the list that already exists in the list.
  ///
  /// If [nullable] is `true`, the list may contain multiple instances of `null`,
  /// otherwise, `null` will be treated like any other value and only
  /// one instance of `null` may be contained in the list.
  ///
  /// The [length] must be non-negative.
  factory UniqueList.generate(
    int length,
    Generator<E> generator, {
    bool growable = true,
    bool strict = false,
    bool nullable = true,
  }) {
    assert(length >= 0);

    var list = List<E>.generate(length, generator, growable: growable);

    if (!strict && growable) {
      list = _removeDuplicateValues<E>(list, nullable: nullable);
    } else if (_containsDuplicateValues(list, nullable: nullable)) {
      throw DuplicateValuesError(
          UniqueList._getDuplicateValue<E>(list, nullable: nullable));
    }

    return UniqueList<E>._(list, nullable: nullable, strict: strict);
  }

  /// Creates an unmodifiable list containing all [elements].
  ///
  /// The [Iterator] of [elements] provides the order of the elements.
  ///
  /// An unmodifiable list cannot have its length or elements changed.
  /// If the elements are themselves immutable, then the resulting list
  /// is also immutable.
  ///
  /// If [nullable] is `true`, the list may contain multiple instances of
  /// `null`, otherwise, `null` will be treated like any other value and only
  /// one instance of `null` may be contained in the list.
  factory UniqueList.unmodifiable(
    Iterable elements, {
    bool nullable = true,
  }) {
    final list = List<E>.unmodifiable(elements);

    if (_containsDuplicateValues(list, nullable: nullable)) {
      throw DuplicateValuesError(
          UniqueList._getDuplicateValue<E>(list, nullable: nullable));
    }

    return UniqueList<E>._(list, nullable: nullable);
  }

  /// Adapts [source] to be a `UniqueList<T>`.
  ///
  /// Any time the list would produce an element that is not a [T],
  /// the element access will throw.
  ///
  /// Any time a [T] value is attempted stored into the adapted list,
  /// the store will throw unless the value is also an instance of [S].
  ///
  /// If all accessed elements of [source] are actually instances of [T],
  /// and if all elements stored into the returned list are actually instance
  /// of [S], then the returned list can be used as a `List<T>`.
  ///
  /// If [strict] is `true`, a [DuplicateValueError] will be thrown when a value
  /// is added to the list that already exists in the list.
  ///
  /// If [nullable] is `true`, the list may contain multiple instances of `null`,
  /// otherwise, `null` will be treated like any other value and only
  /// one instance of `null` may be contained in the list.
  ///
  /// If [source] contains any duplicate values after being cast, a
  /// [DuplicateValuesError] will be thrown.
  static UniqueList<T> castFrom<S, T>(
    List<S> source, {
    bool strict = false,
    bool nullable = true,
  }) {
    final list = _constructListFrom<T>(List.castFrom<S, T>(source),
        nullable: nullable, strict: strict);
    return UniqueList<T>._(list, nullable: nullable, strict: strict);
  }

  @override
  Iterator<E> get iterator => _elements.iterator;

  @override
  UniqueList<R> cast<R>() =>
      UniqueList._(_elements.cast<R>(), nullable: nullable, strict: strict);

  /// Returns the lazy concatentation of this iterable and [other].
  ///
  /// The returned iterable will provide the same elements as this iterable,
  /// and, after that, the elements of [other], in the same order as in the
  /// original iterables.
  ///
  /// If any of [other]'s values already exist in this list, a
  /// [DuplicateValueError] will be thrown if the list is strict, otherwise
  /// those values will be removed from [other] before concatenation.
  @override
  Iterable<E> followedBy(Iterable<E> other) {
    if (strict) {
      for (var value in other) {
        if (_contains(value)) {
          throw DuplicateValueError(value);
        }
      }
    } else {
      other = other.toList()..removeWhere((value) => _contains(value));
    }

    return _elements.followedBy(other);
  }

  @override
  Iterable<T> map<T>(Mapper<T, E> f) => _elements.map<T>(f);

  @override
  Iterable<E> where(Test<E> test) => _elements.where(test);

  @override
  Iterable<T> whereType<T>() => _elements.whereType<T>();

  @override
  Iterable<T> expand<T>(Expand<T, E> f) => _elements.expand<T>(f);

  @override
  bool contains(Object? element) => _elements.contains(element);

  @override
  void forEach(ForEach<E> f) => _elements.forEach(f);

  @override
  E reduce(Combine<E> combine) => _elements.reduce(combine);

  @override
  T fold<T>(T initialValue, Fold<T, E> combine) =>
      _elements.fold(initialValue, combine);

  @override
  bool every(Test<E> test) => _elements.every(test);

  @override
  bool any(Test<E> test) => _elements.any(test);

  @override
  E get first => _elements.first;

  /// Updates the first position of the list to contain [value].
  ///
  /// Equivalent to `theList[0] = value;`.
  ///
  /// The list must be non-empty.
  ///
  /// If the list is [strict], a [DuplicateValueError] will be thrown
  /// if [value] already exists in the list, unless [value] is equivalent
  /// to the element being set.
  @override
  set first(E value) {
    if (value != _elements.first && _contains(value)) {
      throw DuplicateValueError(value);
    }
    _elements.first = value;
  }

  @override
  E get last => _elements.last;

  /// Updates the last position of the list to contain [value].
  ///
  /// Equivalent to `theList[theList.length - 1] = value;`.
  ///
  /// The list must be non-empty.
  ///
  /// If the list is [strict], a [DuplicateValueError] will be thrown
  /// if [value] already exists in the list, unless [value] is equivalent
  /// to the element being set.
  @override
  set last(E value) {
    if (value != _elements.last && _contains(value)) {
      throw DuplicateValueError(value);
    }

    _elements.last = value;
  }

  @override
  E get single => _elements.single;

  @override
  E firstWhere(Test<E> test, {OrElse<E>? orElse}) =>
      _elements.firstWhere(test, orElse: orElse);

  @override
  E lastWhere(Test<E> test, {OrElse<E>? orElse}) =>
      _elements.lastWhere(test, orElse: orElse);

  @override
  E singleWhere(Test<E> test, {OrElse<E>? orElse}) =>
      _elements.singleWhere(test, orElse: orElse);

  @override
  E elementAt(int index) => _elements.elementAt(index);

  /// Adds [value] to the end of this list,
  /// extending the length by one.
  ///
  /// Throws an [UnsupportedError] if the list is fixed-length.
  ///
  /// If [value] already exists in the list, a [DuplicateValueError] will
  /// be thrown if the list is strict, otherwise the value will just not be
  /// added to the list.
  @override
  void add(E value) {
    if (_contains(value)) {
      if (strict) {
        throw DuplicateValueError(value);
      } else {
        return;
      }
    }

    _elements.add(value);
  }

  /// Appends all objects of [iterable] to the end of this list.
  ///
  /// Extends the length of the list by the number of objects in [iterable].
  /// Throws an [UnsupportedError] if this list is fixed-length.
  ///
  /// If any of [iterable]'s values are contained in the list, a
  /// [DuplicateValueError] will be thrown if the list is strict, otherwise
  /// just the values contained within the list will be ignored.
  @override
  void addAll(Iterable<E> iterable) {
    final elements = iterable.toList();

    for (var value in iterable) {
      if (_contains(value)) {
        if (strict) {
          throw DuplicateValueError(value);
        } else {
          elements.remove(value);
        }
      }
    }

    _elements.addAll(elements);
  }

  @override
  Iterable<E> get reversed => _elements.reversed;

  @override
  void sort([Compare<E>? compare]) => _elements.sort(compare);

  @override
  void shuffle([Random? random]) => _elements.shuffle(random);

  @override
  int indexOf(E element, [int start = 0]) => _elements.indexOf(element, start);

  @override
  int indexWhere(Test<E> test, [int start = 0]) =>
      _elements.indexWhere(test, start);

  @override
  int lastIndexWhere(Test<E> test, [int? start]) =>
      _elements.lastIndexWhere(test, start);

  @override
  int lastIndexOf(E element, [int? start]) =>
      _elements.lastIndexOf(element, start);

  @override
  void clear() => _elements.clear();

  /// Inserts the object at position [index] in this list.
  ///
  /// This increases the length of the list by one and shifts all objects
  /// at or after the index towards the end of the list.
  ///
  /// The list must be growable.
  ///
  /// The [index] value must be non-negative and no greater than [length].
  ///
  /// If [element] already exists in the list, a [DuplicateValueError] will
  /// be thrown if the list is strict, otherwise the value will be removed from
  /// the list and re-inserted at [index].
  @override
  void insert(int index, E element) {
    _prepareToInsertElement(element);
    _elements.insert(index, element);
  }

  /// Inserts all objects of [iterable] at position [index] in this list.
  ///
  /// This increases the length of the list by the length of [iterable] and
  /// shifts all later objects towards the end of the list.
  ///
  /// The list must be growable.
  ///
  /// The [index] value must be non-negative and no greater than [length].
  ///
  /// If any of [iterable]'s elements already exist in the list, a
  /// [DuplicateValueError] will be thrown if the list is strict, otherwise
  /// those values will be removed from the list and re-inserted at [index].
  @override
  void insertAll(int index, Iterable<E> iterable) {
    final list =
        _constructListFrom<E>(iterable, strict: strict, nullable: nullable);

    for (var element in list) {
      _prepareToInsertElement(element);
    }

    _elements.insertAll(index, list);
  }

  /// Overwrites objects of `this` with the objects of [iterable], starting
  /// at position [index] in this list.
  ///
  /// ```dart
  ///     List<String> list = ['a', 'b', 'c'];
  ///     list.setAll(1, ['bee', 'sea']);
  ///     list.join(', '); // 'a, bee, sea'
  /// ```
  ///
  /// This operation does not increase the length of `this`.
  ///
  /// The [index] must be non-negative and no greater than [length].
  ///
  /// The [iterable] must not have more elements than what can fit from [index]
  /// to [length].
  ///
  /// If `iterable` is based on this list, its values may change during the
  /// `setAll` operation.
  ///
  /// If any of [iterable]'s elements already exist in the list, a
  /// [DuplicateValueError] will be thrown regardless of whether the list
  /// is strict or not, unless the resulting list does not contain any duplicate
  /// values once all values have been set.
  @override
  void setAll(int index, Iterable<E> iterable) {
    // Check if any of the values in [iterable] already exist in the list.
    for (var value in iterable) {
      if (_contains(value)) {
        // If so, check whether the list will contain any duplicate values once
        // every value has been set.
        final result = List<E>.of(_elements)..setAll(index, iterable);

        if (_containsDuplicateValues(result, nullable: nullable)) {
          throw DuplicateValueError(
              _getDuplicateValue(result, nullable: nullable));
        } else {
          break;
        }
      }
    }

    _elements.setAll(index, iterable);
  }

  @override
  bool remove(Object? value) => _elements.remove(value);

  @override
  E removeAt(int index) => _elements.removeAt(index);

  @override
  E removeLast() => _elements.removeLast();

  @override
  void removeWhere(Test<E> test) => _elements.removeWhere(test);

  @override
  void retainWhere(Test<E> test) => _elements.retainWhere(test);

  @override
  UniqueList<E> sublist(int start, [int? end]) =>
      UniqueList<E>._(_elements.sublist(start, end));

  @override
  Iterable<E> getRange(int start, int end) => _elements.getRange(start, end);

  /// Copies the objects of [iterable], skipping [skipCount] objects first,
  /// into the range [start], inclusive, to [end], exclusive, of the list.
  ///
  /// ```dart
  ///     List<int> list1 = [1, 2, 3, 4];
  ///     List<int> list2 = [5, 6, 7, 8, 9];
  ///     // Copies the 4th and 5th items in list2 as the 2nd and 3rd items
  ///     // of list1.
  ///     list1.setRange(1, 3, list2, 3);
  ///     list1.join(', '); // '1, 8, 9, 4'
  /// ```
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if `0 <= start <= end <= len`, where
  /// `len` is this list's `length`. The range starts at `start` and has length
  /// `end - start`. An empty range (with `end == start`) is valid.
  ///
  /// The [iterable] must have enough objects to fill the range from `start`
  /// to `end` after skipping [skipCount] objects.
  ///
  /// If `iterable` is this list, the operation copies the elements
  /// originally in the range from `skipCount` to `skipCount + (end - start)` to
  /// the range `start` to `end`, even if the two ranges overlap.
  ///
  /// If `iterable` depends on this list in some other way, no guarantees are
  /// made.
  ///
  /// If any of [iterable]'s elements already exist in the list, a
  /// [DuplicateValueError] will be thrown regardless of whether the list
  /// is strict or not, unless the resulting list does not contain any duplicate
  /// values once all values have been set.
  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    assert(start >= 0 && start <= end);
    assert(end >= start && end <= length);
    assert(iterable.length >= end - start);
    assert(skipCount >= 0);

    // Check if any of the values in [iterable] already exist in the list.
    for (var value in iterable) {
      if (_contains(value)) {
        // If so, check whether the list will contain any duplicate values once
        // every value has been set.
        final result = List<E>.of(_elements)
          ..setRange(start, end, iterable, skipCount);

        if (_containsDuplicateValues(result, nullable: nullable)) {
          throw DuplicateValueError(
              _getDuplicateValue(result, nullable: nullable));
        } else {
          break;
        }
      }
    }

    return _elements.setRange(start, end, iterable, skipCount);
  }

  @override
  void removeRange(int start, int end) => _elements.removeRange(start, end);

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    throw UnsupportedError(
        'UniqueList cannot fill values, as all values must be unique.');
  }

  /// Removes the objects in the range [start] inclusive to [end] exclusive
  /// and inserts the contents of [replacement] in its place.
  ///
  /// ```dart
  ///     List<int> list = [1, 2, 3, 4, 5];
  ///     list.replaceRange(1, 4, [6, 7]);
  ///     list.join(', '); // '1, 6, 7, 5'
  /// ```
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if `0 <= start <= end <= len`, where
  /// `len` is this list's `length`. The range starts at `start` and has length
  /// `end - start`. An empty range (with `end == start`) is valid.
  ///
  /// If any of [replacements]'s elements already exist in the list, a
  /// [DuplicateValueError] will be thrown regardless of whether the list
  /// is strict or not, unless the resulting list does not contain any duplicate
  /// values once all values have been set.
  @override
  void replaceRange(int start, int end, Iterable<E> replacement) {
    // Check if any of the values in [replacement] already exist in the list.
    for (var value in replacement) {
      if (_contains(value)) {
        // If so, check whether the list will contain any duplicate values once
        // every value has been set.
        final result = List<E>.of(_elements)
          ..replaceRange(start, end, replacement);

        if (_containsDuplicateValues(result, nullable: nullable)) {
          throw DuplicateValueError(
              _getDuplicateValue(result, nullable: nullable));
        } else {
          break;
        }
      }
    }

    _elements.replaceRange(start, end, replacement);
  }

  @override
  Iterable<E> take(int count) => _elements.take(count);

  @override
  Iterable<E> takeWhile(Test<E> test) => _elements.takeWhile(test);

  @override
  Iterable<E> skip(int count) => _elements.skip(count);

  @override
  Iterable<E> skipWhile(Test<E> test) => _elements.skipWhile(test);

  @override
  bool get isEmpty => _elements.isEmpty;

  @override
  bool get isNotEmpty => _elements.isNotEmpty;

  @override
  Map<int, E> asMap() => _elements.asMap();

  @override
  List<E> toList({bool growable = true}) =>
      _elements.toList(growable: growable);

  /// Creates a [UniqueList] containing the elements of this list.
  UniqueList<E> toUniqueList(
          {bool growable = true, bool strict = true, bool nullIsVoid = true}) =>
      UniqueList<E>.of(
        _elements,
        growable: growable,
        strict: strict,
        nullable: true,
      );

  @override
  Set<E> toSet() => _elements.toSet();

  @override
  int get length => _elements.length;

  @override
  set length(int newLength) => _elements.length = length;

  @override
  E operator [](int index) => _elements[index];

  /// Sets the value at the given [index] in the list to [value]
  /// or throws a [RangeError] if [index] is out of bounds.
  ///
  /// A [DuplicateValueError] will be thrown if the list already contains [value],
  /// unless the element being set is the equivalent of [value].
  @override
  void operator []=(int index, E value) {
    if (_elements[index] != value && _contains(value)) {
      throw DuplicateValueError(value);
    }

    _elements[index] = value;
  }

  /// Returns the concatenation of this list and [other].
  ///
  /// Returns a new list containing the elements of this list followed by
  /// the elements of [other].
  ///
  /// The returned list will have the same [strict] and [nullable] values
  /// as `this` list.
  ///
  /// If any of [other]'s values already exist in this list, a
  /// [DuplicateValueError] will be thrown if the list is strict, otherwise
  /// those values will be removed from [other] before concatenation.
  @override
  UniqueList<E> operator +(List<E> other) {
    if (strict) {
      for (var value in other) {
        if (_contains(value)) {
          throw DuplicateValueError(value);
        }
      }
    } else {
      other.removeWhere((value) => _contains(value));
    }

    return UniqueList<E>._(_elements + other,
        nullable: nullable, strict: strict);
  }

  @override
  bool operator ==(Object other);

  @override
  String join([String separator = '']) => _elements.join(separator);

  @override
  String toString() => _elements.toString();

  /// Returns `true` if [_elements] contains [value], unless [value] is `null`
  /// and nullable is `false`.
  bool _contains(E? value) =>
      (!nullable || value != null) && _elements.contains(value);

  /// If [_elements] contains [value], throw a [DuplicateValueError] if [strict]
  /// is `true`, otherwise remove the [value] from [_elements].
  void _prepareToInsertElement(E element) {
    if (_contains(element)) {
      if (strict) {
        throw DuplicateValueError(element);
      } else {
        _elements.remove(element);
      }
    }
  }

  /// Returns `true` if [list] contains more than one instance of any element
  /// contained within the list, otherwise returns `false`.
  static bool _containsDuplicateValues(List list, {required bool nullable}) {
    final elementsChecked = [];

    for (var element in list) {
      if (nullable && element == null) {
        continue;
      }

      if (elementsChecked.contains(element)) {
        return true;
      }

      elementsChecked.add(element);
    }

    return false;
  }

  /// Returns the first duplicate value found within [list].
  static E? _getDuplicateValue<E>(List<E> list, {required bool nullable}) {
    final elementsChecked = [];

    for (var element in list) {
      if (nullable && element == null) {
        continue;
      }

      if (elementsChecked.contains(element)) {
        return element;
      }

      elementsChecked.add(element);
    }

    return null;
  }

  /// Removes any duplicate values from [list], leaving only the first occurence
  /// of the value.
  static List<E> _removeDuplicateValues<E>(
    List<E> list, {
    required bool nullable,
  }) {
    final elements = <E>[];

    for (var element in list) {
      if (nullable && element == null) {
        continue;
      }

      if (elements.contains(element)) {
        continue;
      }

      elements.add(element);
    }

    return elements;
  }

  static List<E> _constructListFrom<E>(
    Iterable<E> elements, {
    required bool strict,
    required bool nullable,
  }) {
    var list = elements.toList();

    if (!strict) {
      list = _removeDuplicateValues<E>(list, nullable: nullable);
    } else if (_containsDuplicateValues(list, nullable: nullable)) {
      throw DuplicateValuesError(
          UniqueList._getDuplicateValue<E>(list, nullable: nullable));
    }

    return list;
  }
}
