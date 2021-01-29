# unique_list

[![pub package](https://img.shields.io/pub/v/unique_list.svg)](https://pub.dartlang.org/packages/unique_list)

An implementation of [List] that enforces all elements be unique.

## Usage

```dart
import 'package:unique_list/unique_list.dart';
```

[UniqueList] is an implementation of [List] that doesn't allow the same element
to occur in the [List] more than once (much like a [Set].) Elements will be
considered identical if comparing them with the `==` operator returns `true`.

The [UniqueList] class implements [List], as such it has all of the same methods
and parameters of a [List], can be used interchangeably with a [List], and be
provided to any parameter that enforces a [List].

The default constructor is identical to [List]s', accepting an optional [length]
parameter. If [length] is provided the [UniqueList] will be a fixed-length list.

```dart
/// Create an empty [UniqueList].
final list = UniqueList();

/// Create an empty [UniqueList] of [int]s.
final integers = UniqueList<int>();

/// Create a fixed-length [UniqueList] of [int]s.
final fiveIntegers = UniqueList<int>(5);
```

By default, [UniqueList] doesn't allows for multiple instances of `null` to be
contained within the list, unless creating a fixed-lenght list. To create a
[UniqueList] that allows for multiple instances of `null` to occur, the [nullable]
parameter can be set to `true`.

```dart
/// Create an empty [UniqueList] that allows multiple instances of `null`.
final list = UniqueList.empty(nullable: true);
```

## Strict Lists

By default, [UniqueList] behaves like a [Set], when an element that already exists
in the list is added to it, the list will be left as it was. The [UniqueList.strict]
constructor can be used to create a list that will throw a [DuplicateValueError]
instead.

```dart
final list = UniqueList<int>();

list.addAll([0, 1, 2]);

list.add(0);

print(list); // [0, 1, 2]

final strictList = UniqueList<int>.strict();

strictList.addAll([0, 1, 2]);

strictList.add(0); // This will throw a [DuplicateValueError].
```

## Factory Constructors

[UniqueList] has all of the same factory constructors as a regular [List], with
the exception of [List.filled], as the values created by [filled] would not be
unique.

Each of [UniqueList]'s factory constructors have a [strict] and a [nullable]
parameter, and most have a [growable] parameter like [List].

### UniqueList.from

```dart
/// Create a new [UniqueList] list containing all elements from another list.
final list = UniqueList<int>.from([0, 1, 2]);
final strict = UniqueList<int>.from([0, 1, 2], strict: true);
final nullable = UniqueList<int>.from([0, 1, 2], nullable: true);
```

### UniqueList.of

```dart
/// Create a new [UniqueList] list from an iterable.
final list = UniqueList<int>.of([0, 1, 2]);
final strict = UniqueList<int>.of([0, 1, 2], strict: true);
final nullable = UniqueList<int>.of([0, 1, 2], nullable: true);
```

### UniqueList.generate

```dart
/// Generate a new [UniqueList] using a generator.
final list = UniqueList<int>.generate(5, (index) => index); // [0, 1, 2, 3, 4]
final strict = UniqueList<int>.generate(5, (index) => index, strict: true);
final nullable = UniqueList<int>.generate(5, (index) => index, nullable: true);
```

### UniqueList.unmodifiable

[UniqueList.unmodifiable] is the only standard factory constructor without a [strict]
parameter, as it isn't necessary if the list can't be modified.

```dart
/// Create an unmodifiable [UniqueList] from an iterable.
final list = UniqueList<int>.unmodifiable([0, 1, 2]);
final nullable = UniqueList<int>.unmodifiable([0, 1, 2], nullable: true);
```

### Constructor Errors

Attempting to construct a strict list that contains multiple instances of the same
element, will throw a [DuplicateValuesError], as opposed to the [DuplicateValueError]
thrown when attempting to add a duplicate element to a list.

A [DuplicateValuesError] will also be thrown if attempting to construct a fixed-length
list that contains multiple instances of the same element.

## Adding and Inserting Elements

Adding and inserting values into a non-strict [UniqueList] have different behavior
when a duplicate element is provided. Both will throw a [DuplicateValueError]
if adding or inserting duplicate elements into a strict list.

### Add and AddAll

When adding elements into a list with the [add] or [addAll] method, any duplicate
values will be ignored.

```dart
final list = UniqueList<int>.from([0, 1, 2]);

print(list); // [0, 1, 2]

list.add(3);

print(list); // [0, 1, 2, 3]

list.add(2);

print(list); // [0, 1, 2, 3]

list.addAll([0, 1, 4, 5]);

print(list); // [0, 1, 2, 3, 4, 5]
```

### Insert and InsertAll

When inserting one or more elements into the list with the [insert] or [insertAll]
method, any existing instances of any of the elements being inserted will be removed,
shifting the indexes of all elements occuring after the one(s) removed down.

```dart
final list = UniqueList<int>.from([0, 1, 2]);

print(list); // [0, 1, 2]

list.insert(0, 3);

print(list); // [3, 0, 1, 2]

list.insert(3, 3);

print(list); // [0, 1, 2, 3]

list.insertAll(3, [0, 1, 2]);

print(list); // [3, 0, 1, 2]
```

## Setting Values

When setting values with the [setAll], [setRange], [first], [last], or the `[]=`
operator a [DuplicateValueError] will always be thrown, regardless of whether the
list is strict or not, unless the resulting list does not contain any duplicate
values once all values have been set.

```dart
final list = UniqueList<int>.from([0, 1, 2]);

print(list); // [0, 1, 2]

list.setAll(0, [0, 1, 2]); // Throws a [DuplicateValueError].

list.setRange(1, 2, [3, 4]);

print(list); // [0, 3, 4]

list.setRange(0, 1, [2, 3]); // Throws a [DuplicateValueError].
```

__Note:__ In order to comply with [List], the [fillRange] method is provided, but
will always throw a [DuplicateValueError] unless the value being filled is `null`
in a nullable list, or if only a single element is being set.

## The ToUniqueList Extension Method

As many of [List]'s methods return an [Iterable], they're often cast back to a
[List] using [Iterable]'s [toList] method. To follow the same pattern, this package
extends [Iterable] with the [toUniqueList] method.

Like [toList], the [toUniqueList] method contains a [growable] parameter, in
addition to the [nullable] and [strict] parameters, which by default are `true`
and `false` respectively.

```dart
var list = UniqueList<int>.from([0, 1, 2, 3, 4]);

final reversed = list.reversed.toUniqueList();

print(reversed); // [4, 3, 2, 1, 0]
```
