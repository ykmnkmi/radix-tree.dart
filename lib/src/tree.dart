library radix_tree;

import 'dart:collection';

import 'package:meta/meta.dart';

import 'node.dart';
import 'utils.dart' as utils;

/// Signature for callbacks passed to [RadixTree.visit], [RadixTree.visitRoot]
/// and [RadixTree.visitRootPrefixed] methods.
typedef RadixTreeKVVisitor<T> = void Function(String key, T value);

/// Radix trees are String -> T mappings which allow quick lookups
/// on the strings.
@optionalTypeArgs
base class RadixTree<T> extends MapBase<String, T?> {
  /// Default constructor.
  RadixTree({
    RadixTreeNode<T>? root,
    this.putValue = utils.putValue,
    this.removeValue = utils.removeValue,
  }) : root = root ?? RadixTreeNode<T>('');

  /// The root node in this tree.
  @internal
  final RadixTreeNode<T> root;

  /// Called from `[]=` operator to set value.
  ///
  /// Deafults to [utils.removeValue].
  @protected
  final void Function<T>(RadixTreeNode<T> node, String key, T? value) putValue;

  /// Called from `remove` method to delete value.
  ///
  /// Deafults to [utils.removeValue].
  @protected
  final T? Function<T>(RadixTreeNode<T> node, String key) removeValue;

  @override
  Iterable<MapEntry<String, T?>> get entries {
    var entries = <MapEntry<String, T?>>[];

    void visitor(String key, T? value) {
      entries.add(MapEntry<String, T?>(key, value));
    }

    visitRoot(visitor);
    return entries;
  }

  @override
  bool get isEmpty {
    return root.children.isEmpty;
  }

  @override
  bool get isNotEmpty {
    return root.children.isNotEmpty;
  }

  @override
  Iterable<String> get keys {
    var keys = <String>[];

    void visitor(String key, T? value) {
      keys.add(key);
    }

    visitRoot(visitor);
    return keys;
  }

  @override
  int get length {
    var count = 0;

    void visitor(String key, T? value) {
      count += 1;
    }

    visitRoot(visitor);
    return count;
  }

  @override
  Iterable<T?> get values {
    var values = <T?>[];

    void visitor(String key, T? value) {
      values.add(value);
    }

    visitRoot(visitor);
    return values;
  }

  @override
  T? operator [](Object? key) {
    if (key is! String) {
      throw TypeError();
    }

    T? found;

    void visitor(String k, T? v) {
      if (k == key) {
        found = v;
      }
    }

    visitKey(root, key, '', visitor);
    return found;
  }

  @override
  void operator []=(String key, T? value) {
    putValue<T>(root, key, value);
  }

  @override
  void clear() {
    root.children.clear();
  }

  @override
  bool containsKey(Object? key) {
    if (key is! String) {
      throw TypeError();
    }

    var found = false;

    void visitor(String keyToCheck, T? value) {
      if (keyToCheck == key) {
        found = true;
      }
    }

    visitKey(root, key, '', visitor);
    return found;
  }

  /// Warning: This visits every single node regardless of where the value lies!
  @override
  bool containsValue(Object? value) {
    var found = false;

    void visit(String k, T? v) {
      if (value == v) {
        found = true;
      }
    }

    visitRoot(visit);
    return found;
  }

  /// Gets a list of entries whose associated keys have the given prefix.
  List<MapEntry<String, T?>> getEntriesWithPrefix(String prefix) {
    var entries = <MapEntry<String, T?>>[];

    void visitor(String key, T? value) {
      entries.add(MapEntry<String, T?>(key, value));
    }

    visitRootPrefixed(visitor, prefix);
    return entries;
  }

  /// Gets a list of keys with the given prefix.
  List<String> getKeysWithPrefix(String prefix) {
    var keys = <String>[];

    void visitor(String key, T? value) {
      keys.add(key);
    }

    visitRootPrefixed(visitor, prefix);
    return keys;
  }

  /// Gets a list of values whose associated keys have the given prefix.
  List<T> getValuesWithPrefix(String prefix) {
    var values = <T>[];

    void visitor(String key, T? value) {
      if (value != null) {
        values.add(value);
      }
    }

    visitRootPrefixed(visitor, prefix);
    return values;
  }

  /// Visits the given node of this tree with the given key and visitor.
  void visitKey(
    RadixTreeNode<T> node,
    String key,
    String prefix,
    RadixTreeKVVisitor<T?> visitor,
  ) {
    if (node.hasValue && prefix == key) {
      visitor(prefix, node.value);
      return;
    }

    var prefixLength = prefix.length;

    if (key.length > prefixLength) {
      // Search the children only if there's more key remaining.
      // Unfortunately this is O(|your_alphabet|)
      for (var child in node.children) {
        if (child.prefix[0] == key[prefixLength]) {
          return visitKey(child, key, prefix + child.prefix, visitor);
        }
      }
    }
  }

  /// Visits the given node of this tree with the given prefix and visitor.
  ///
  /// Also, recursively visits the left/right subtrees of this node.
  void visit(
    RadixTreeNode<T> node,
    String prefixAllowed,
    String prefix,
    RadixTreeKVVisitor<T?> visitor,
  ) {
    if (node.hasValue && prefix.startsWith(prefixAllowed)) {
      visitor(prefix, node.value);
    }

    var prefixLength = prefix.length;

    for (var child in node.children) {
      if (prefixAllowed.length <= prefixLength ||
          child.prefix[0] == prefixAllowed[prefixLength]) {
        visit(child, prefixAllowed, prefix + child.prefix, visitor);
      }
    }
  }

  /// Traverses this radix tree using the given visitor.
  ///
  /// Note that the tree will be traversed in lexicographical order.
  void visitRoot(RadixTreeKVVisitor<T?> visitor) {
    visit(root, '', '', visitor);
  }

  /// Traverses this radix tree using the given visitor.
  ///
  /// Only values with the given prefix will be visited. Note that the tree
  /// will be traversed in lexicographical order.
  void visitRootPrefixed(RadixTreeKVVisitor<T?> visitor, String prefix) {
    visit(root, prefix, '', visitor);
  }

  @override
  T? remove(Object? key) {
    if (key is! String) {
      throw TypeError();
    }

    if (key.isEmpty) {
      var value = root.value;
      root.value = null;
      return value;
    }

    return removeValue(root, key);
  }
}
