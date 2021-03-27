## [1.0.1] - March 26, 2021

* [UniqueList] now extends [BaseList] from the [list_utilities](https://pub.dev/packages/list_utilities) package, instead of implementing [List] directly.

* Added the [growable] parameter to the default constructor.

## [1.0.0] - March 17, 2021

* Migrated to null-safe code.

* [fillRange] is now unimplemented and throws an [UnsupportedError].

## [0.1.2] - October 6, 2020

* Updated the [setAll], [setRange], and [replaceRange] methods to allow
their supplied iterable to contain values already in the list if the resulting
list doesn't contain any duplicate values once all values have been set.

## [0.1.1] - October 2, 2020

* Set [nullable] to `true` by default in the [UniqueList.strict] factory constructor and the [toUniqueList] extension method.

## [0.1.0] - October 2, 2020

* Initial release.
