import 'dart:collection';

import 'package:meta/meta.dart';

/// A node in a radix tree.
@optionalTypeArgs
class RadixTreeNode<T> extends IterableBase<RadixTreeNode<T>>
    implements Comparable<RadixTreeNode<T>> {
  /// Constructs a node from the given prefix and optional value.
  RadixTreeNode(this.prefix, [this.value]) : childrend = <RadixTreeNode<T>>{};

  /// The prefix at this node.
  String prefix;

  /// The value stored at this node.
  T? value;

  /// The children for this node. Note, because we use [LinkedHashSet] here,
  /// traversal of [RadixTree] will be in lexicographical order.
  Set<RadixTreeNode<T>> childrend;

  @override
  int get hashCode => prefix.hashCode ^ value.hashCode ^ childrend.hashCode;

  /// Whether or not this node stores a value. This value is mainly used by
  /// [RadixTreeKVVisitor] to figure out whether or not this node should
  /// be visited.
  bool get hasValue => value != null;

  @override
  Iterator<RadixTreeNode<T>> get iterator {
    return childrend.iterator;
  }

  @override
  bool operator ==(Object other) {
    return other is RadixTreeNode<T> &&
        prefix == other.prefix &&
        value == other.value &&
        childrend == other.childrend;
  }

  @override
  int compareTo(RadixTreeNode<T?> other) {
    return prefix.compareTo(other.prefix);
  }
}
