import 'dart:math' show min;

import 'node.dart';

/// Radix tree utility functions.
abstract class RadixTreeUtils {
  /// Finds the length of the largest prefix for two character sequences.
  static int largestPrefixLength(String first, String second) {
    final commonLength = min(first.length, second.length);

    for (var i = 0; i < commonLength; ++i) {
      if (first[i] != second[i]) return i;
    }

    return commonLength;
  }

  /// Put the value with the given key from the subtree rooted at the
  /// given node.
  static void putValue<T>(RadixTreeNode<T> node, String key, T? value) {
    final largestPrefix = largestPrefixLength(key, node.prefix);

    if (largestPrefix == node.prefix.length && largestPrefix == key.length) {
      // Exact match, update the value here.
      node.value = value;
    } else if (largestPrefix == 0 ||
        (largestPrefix < key.length && largestPrefix == node.prefix.length)) {
      // Key we're looking for shares no common prefix (e.g. at the root), OR
      // Key we're looking for subsumes this node's string.
      final leftOverKey = key.substring(largestPrefix);
      var found = false;

      // Try to find a child node that continues matching the remainder.
      for (final child in node) {
        if (child.prefix[0] == leftOverKey[0]) {
          found = true;
          putValue<T>(child, leftOverKey, value);
          break;
        }
      }
      // Otherwise add the remainder as a child of this node.
      if (!found) {
        final newNode = RadixTreeNode<T>(leftOverKey, value);
        node.childrend.add(newNode);
      }
    } else {
      // case largestPrefix < node.prefix.length:
      // Key we're looking for shares a non-empty subset of this node's string.
      final leftOverPrefix = node.prefix.substring(largestPrefix);
      final newNode = RadixTreeNode<T>(leftOverPrefix, node.value);
      newNode.childrend.addAll(node.childrend);

      node.prefix = node.prefix.substring(0, largestPrefix);
      node.childrend.clear();
      node.childrend.add(newNode);

      if (largestPrefix == key.length) {
        node.value = value;
      } else {
        final leftOverKey = key.substring(largestPrefix);
        final keyNode = RadixTreeNode<T>(leftOverKey, value);
        node.childrend.add(keyNode);
        node.value = null;
      }
    }
  }

  /// Remove the value with the given key from the subtree rooted at the
  /// given node.
  static T? removeValue<T>(RadixTreeNode<T> node, String key) {
    T? result;

    final childrend = node.childrend.toList();
    var i = 0;

    while (i < childrend.length) {
      final child = childrend[i];
      final largestPrefix = largestPrefixLength(key, child.prefix);

      if (largestPrefix == child.prefix.length && largestPrefix == key.length) {
        if (child.childrend.isEmpty) {
          result = child.value;
          node.childrend.remove(child);
        } else if (child.hasValue) {
          result = child.value;
          child.value = null;

          if (child.childrend.length == 1) {
            final subchild = child.childrend.first;
            child.prefix = child.prefix + subchild.prefix;
            child.value = subchild.value;
            child.childrend.clear();
          }

          break;
        }
      } else if (largestPrefix > 0 && largestPrefix < key.length) {
        final leftoverKey = key.substring(largestPrefix);
        result = removeValue<T>(child, leftoverKey);
        break;
      }

      i += 1;
    }

    return result;
  }
}
