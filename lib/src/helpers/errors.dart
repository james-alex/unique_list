/// An error thrown when a value is added to a strict
/// [UniqueList] that already exists in the list.
class DuplicateValueError extends Error {
  DuplicateValueError(this.value);

  final Object value;

  @override
  String toString() =>
      'DuplicateValueError: The list already contains [$value].';
}

/// An error thrown when constructing a strict [UniqueList] from
/// a list that contains multiple instances of the same value.
class DuplicateValuesError extends Error {
  DuplicateValuesError(this.value);

  final Object value;

  @override
  String toString() => 'DuplicateValuesError: '
      'The constructing list contains multiple instances of [$value].';
}
