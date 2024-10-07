import 'dart:collection';

import 'package:meta/meta.dart';

import 'tree.dart';

/// A node in a radix tree.
@optionalTypeArgs
base class RadixTreeNode<T> implements Comparable<RadixTreeNode<T>> {
  /// Constructs a node from the given prefix and optional value.
  @internal
  RadixTreeNode(this.prefix, [this.value, Set<RadixTreeNode<T>>? children])
      : children = <RadixTreeNode<T>>{...?children};

  /// The prefix at this node.
  @internal
  String prefix;

  /// The value stored at this node.
  @internal
  T? value;

  /// The children for this node.
  ///
  /// Note, because we use [LinkedHashSet] here, traversal of [RadixTree]
  /// will be in lexicographical order.
  @internal
  Set<RadixTreeNode<T>> children;

  @override
  int get hashCode {
    return Object.hash(prefix, value, children);
  }

  /// Whether or not this node stores a value.
  ///
  /// This value is mainly used by [RadixTreeKVVisitor] to figure out whether
  /// or not this node should be visited.
  bool get hasValue {
    return value != null;
  }

  @override
  bool operator ==(Object other) {
    return other is RadixTreeNode<T> &&
        prefix == other.prefix &&
        value == other.value &&
        children == other.children;
  }

  @override
  int compareTo(RadixTreeNode<T?> other) {
    return prefix.compareTo(other.prefix);
  }
}
