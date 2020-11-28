# Radix Tree

Dart implementation of the [Radix Tree](en.wikipedia.org/wiki/Radix_tree) data
structure. A radix tree maps strings to values, allowing efficient
string lookup and prefix queries. This implementation implements the
`Map` interface.

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

[tracker]: https://github.com/ykmnkmi/radix-tree.dart/issues
