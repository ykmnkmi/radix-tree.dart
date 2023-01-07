# Radix Tree

[![Pub Package][pub_icon]][pub]
[![Test Status][test_ci_icon]][test_ci]

`Map` based Dart implementation of the [Radix Tree][Radix Tree] data structure.
A radix tree maps strings to values, allowing efficient string lookup and
prefix queries.

Based on [radix-tree](https://github.com/thegedge/radix-tree).

## Usage

A simple usage example:

```dart
import 'package:radix_tree/radix_tree.dart';

void main(List<String> arguments) {
  var tree = RadixTree<int>();
  tree['paku'] = 1;
  tree['piku'] = 2;
  tree['pako'] = 3;
  tree.getValuesWithPrefix('p'); // list contains 1, 2, 3
  tree.getValuesWithPrefix('pa'); // list contains 1, 3
}
```

## License

This project is licensed under the MIT license.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[pub_icon]: https://img.shields.io/pub/v/radix_tree.svg
[pub]: https://pub.dev/packages/radix_tree
[test_ci_icon]: https://github.com/ykmnkmi/radix-tree.dart/actions/workflows/test.yaml/badge.svg
[test_ci]: https://github.com/ykmnkmi/radix-tree.dart/actions/workflows/test.yaml
[radix_tree.svg]: https://img.shields.io/pub/v/radix_tree.svg
[Radix Tree]: https://en.wikipedia.org/wiki/Radix_tree
[tracker]: https://github.com/ykmnkmi/radix-tree.dart/issues
