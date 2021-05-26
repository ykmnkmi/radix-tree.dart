library radix_tree;

import 'dart:collection';

import 'package:meta/meta.dart';

import 'node.dart';
import 'utils.dart';

/// Signature for callbacks passed to [RadixTree.visit], [RadixTree.visitRoot]
/// and [RadixTree.visitRootPrefixed] methods.
typedef RadixTreeKVVisitor<T> = void Function(String key, T value);

/// Radix trees are String -> T mappings which allow quick lookups
/// on the strings.
@optionalTypeArgs
class RadixTree<T> extends MapBase<String, T?> {
  /// Default constructor.
  RadixTree({
    RadixTreeNode<T>? root,
    this.putValue = RadixTreeUtils.putValue,
    this.removeValue = RadixTreeUtils.removeValue,
  }) : root = root ?? RadixTreeNode<T>('');

  /// The root node in this tree.
  RadixTreeNode<T> root;

  /// Called from `[]=` operator to set value.
  ///
  /// Deafults to [RadixTreeUtils.removeValue].
  @protected
  void Function<T>(RadixTreeNode<T> node, String key, T? value) putValue;

  /// Called from `remove` method to delete value.
  ///
  /// Deafults to [RadixTreeUtils.removeValue].
  @protected
  T? Function<T>(RadixTreeNode<T> node, String key) removeValue;

  @override
  Iterable<MapEntry<String, T?>> get entries {
    final entries = <MapEntry<String, T?>>[];

    void visit(String key, T? value) {
      entries.add(MapEntry<String, T?>(key, value));
    }

    visitRoot(visit);
    return entries;
  }

  @override
  bool get isEmpty => root.childrend.isEmpty;

  @override
  bool get isNotEmpty => root.childrend.isNotEmpty;

  @override
  Iterable<String> get keys {
    final keys = <String>[];

    void visit(String key, T? value) {
      keys.add(key);
    }

    visitRoot(visit);
    return keys;
  }

  @override
  int get length {
    var count = 0;

    void visit(String key, T? value) {
      ++count;
    }

    visitRoot(visit);
    return count;
  }

  @override
  Iterable<T?> get values {
    final values = <T?>[];

    void visit(String key, T? value) {
      values.add(value);
    }

    visitRoot(visit);
    return values;
  }

  @override
  T? operator [](Object? key) {
    if (key == null) {
      throw NullThrownError();
    }

    if (key is! String) {
      throw TypeError();
    }

    T? found;

    void visit(String k, T? v) {
      if (k == key) {
        found = v;
      }
    }

    visitRootPrefixed(visit, key);
    return found;
  }

  @override
  void operator []=(String key, T? value) {
    putValue<T>(root, key, value);
  }

  @override
  void clear() {
    root.childrend.clear();
  }

  @override
  bool containsKey(Object? key) {
    if (key == null) {
      throw NullThrownError();
    }

    if (key is! String) {
      throw TypeError();
    }

    var found = false;

    void visit(String keyToCheck, T? value) {
      if (keyToCheck == key) {
        found = true;
      }
    }

    visitRootPrefixed(visit, key);
    return found;
  }

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
    final entries = <MapEntry<String, T?>>[];

    void visit(String key, T? value) {
      entries.add(MapEntry<String, T?>(key, value));
    }

    visitRootPrefixed(visit, prefix);
    return entries;
  }

  /// Gets a list of keys with the given prefix.
  List<String> getKeysWithPrefix(String prefix) {
    final keys = <String>[];

    void visit(String key, T? value) {
      keys.add(key);
    }

    visitRootPrefixed(visit, prefix);
    return keys;
  }

  /// Gets a list of values whose associated keys have the given prefix.
  List<T> getValuesWithPrefix(String prefix) {
    final values = <T>[];

    void visit(String key, T? value) {
      if (value != null) {
        values.add(value);
      }
    }

    visitRootPrefixed(visit, prefix);
    return values;
  }

  /// Visits the given node of this tree with the given prefix and visitor. Also,
  /// recursively visits the left/right subtrees of this node.
  @optionalTypeArgs
  void visit(RadixTreeNode<T> node, String prefixAllowed, String prefix,
      RadixTreeKVVisitor<T?> visitor) {
    if (node.hasValue && prefix.startsWith(prefixAllowed)) {
      visitor(prefix, node.value);
    }

    for (final child in node) {
      final prefixLength = prefix.length;
      final newPrefix = prefix + child.prefix;

      if (prefixAllowed.length <= prefixLength ||
          newPrefix.length <= prefixLength ||
          newPrefix[prefixLength] == prefixAllowed[prefixLength]) {
        visit(child, prefixAllowed, newPrefix, visitor);
      }
    }
  }

  /// Traverses this radix tree using the given visitor. Note that the tree
  /// will be traversed in lexicographical order.
  @optionalTypeArgs
  void visitRoot(RadixTreeKVVisitor<T?> visitor) {
    visit(root, '', '', visitor);
  }

  /// Traverses this radix tree using the given visitor. Only values with
  /// the given prefix will be visited. Note that the tree will be traversed
  /// in lexicographical order.
  @optionalTypeArgs
  void visitRootPrefixed(RadixTreeKVVisitor<T?> visitor, String prefix) {
    visit(root, prefix, '', visitor);
  }

  @override
  T? remove(Object? key) {
    if (key == null) {
      throw NullThrownError();
    }

    if (key is! String) {
      throw TypeError();
    }

    if (key.isEmpty) {
      final value = root.value;
      root.value = null;
      return value;
    }

    return removeValue(root, key);
  }
}
