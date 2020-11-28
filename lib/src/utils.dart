import 'dart:math' show min;

import 'node.dart';

/// Radix tree utility functions.
abstract class RadixTreeUtils {
  /// Finds the length of the largest prefix for two character sequences.
  static int largestPrefixLength(String first, String second) {
    var length = 0;

    for (var i = 0; i < min(first.length, second.length); ++i) {
      if (first[i] != second[i]) {
        break;
      }

      ++length;
    }

    return length;
  }

  /// Put the value with the given key from the subtree rooted at the
  /// given node.
  static void putValue<T>(RadixTreeNode<T> node, String key, T value) {
    final largestPrefix = largestPrefixLength(key, node.prefix);

    if (largestPrefix == node.prefix.length && largestPrefix == key.length) {
      node.value = value;
    } else if (largestPrefix == 0 || (largestPrefix < key.length && largestPrefix >= node.prefix.length)) {
      final leftOverKey = key.substring(largestPrefix);
      var found = false;

      for (final child in node) {
        if (child.prefix[0] == leftOverKey[0]) {
          found = true;
          putValue<T>(child, leftOverKey, value);
          break;
        }
      }

      if (!found) {
        final newNode = RadixTreeNode<T>(leftOverKey, value);
        node.childrend.add(newNode);
      }
    } else if (largestPrefix < node.prefix.length) {
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
    } else {
      final leftoverKey = key.substring(largestPrefix);
      final newNode = RadixTreeNode<T>(leftoverKey, value);
      node.childrend.add(newNode);
    }
  }

  /// Remove the value with the given key from the subtree rooted at the
  /// given node.
  static T removeValue<T>(RadixTreeNode<T> node, String key) {
    T result;

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
