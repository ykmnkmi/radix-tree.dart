import 'dart:math' show min;

import 'node.dart';

/// Radix tree utility functions.
abstract class RadixTreeUtils {
  /// Finds the length of the largest prefix for two character sequences.
  static int largestPrefixLength(String first, String second) {
    var commonLength = min(first.length, second.length);

    for (var i = 0; i < commonLength; i += 1) {
      if (first[i] != second[i]) {
        return i;
      }
    }

    return commonLength;
  }

  /// Put the value with the given key from the subtree rooted at the
  /// given node.
  static void putValue<T>(RadixTreeNode<T> node, String key, T? value) {
    var largestPrefix = largestPrefixLength(key, node.prefix);

    if (largestPrefix == node.prefix.length && largestPrefix == key.length) {
      // Exact match, update the value here.
      node.value = value;
    } else if (largestPrefix == 0 ||
        (largestPrefix < key.length && largestPrefix == node.prefix.length)) {
      // Key we're looking for shares no common prefix (e.g. at the root), OR
      // Key we're looking for subsumes this node's string.
      var leftOverKey = key.substring(largestPrefix);
      var found = false;

      // Try to find a child node that continues matching the remainder.
      for (var child in node) {
        if (child.prefix[0] == leftOverKey[0]) {
          found = true;
          putValue<T>(child, leftOverKey, value);
          break;
        }
      }
      // Otherwise add the remainder as a child of this node.
      if (!found) {
        var newNode = RadixTreeNode<T>(leftOverKey, value);
        node.children.add(newNode);
      }
    } else {
      // case largestPrefix < node.prefix.length:
      // Key we're looking for shares a non-empty subset of this node's string.
      var leftOverPrefix = node.prefix.substring(largestPrefix);
      var newNode = RadixTreeNode<T>(leftOverPrefix, node.value, node.children);

      node
        ..prefix = node.prefix.substring(0, largestPrefix)
        ..children.clear()
        ..children.add(newNode);

      if (largestPrefix == key.length) {
        node.value = value;
      } else {
        var leftOverKey = key.substring(largestPrefix);
        var keyNode = RadixTreeNode<T>(leftOverKey, value);

        node
          ..children.add(keyNode)
          ..value = null;
      }
    }
  }

  /// Remove the value with the given key from the subtree rooted at the
  /// given node.
  static T? removeValue<T>(RadixTreeNode<T> node, String key) {
    T? result;

    var childrend = node.children.toList();
    var i = 0;

    while (i < childrend.length) {
      var child = childrend[i];
      var largestPrefix = largestPrefixLength(key, child.prefix);

      if (largestPrefix == child.prefix.length && largestPrefix == key.length) {
        if (child.children.isEmpty) {
          result = child.value;
          node.children.remove(child);
        } else if (child.hasValue) {
          result = child.value;
          child.value = null;

          if (child.children.length == 1) {
            var subchild = child.children.first;

            child
              ..prefix = child.prefix + subchild.prefix
              ..value = subchild.value
              ..children.clear();
          }

          break;
        }
      } else if (largestPrefix > 0 && largestPrefix < key.length) {
        var leftoverKey = key.substring(largestPrefix);
        result = removeValue<T>(child, leftoverKey);
        break;
      }

      i += 1;
    }

    return result;
  }
}
