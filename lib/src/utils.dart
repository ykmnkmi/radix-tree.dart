import 'dart:math' show min;

import '' as self;
import 'node.dart';

/// {@template largestPrefixLength}
/// Finds the length of the largest prefix for two character sequences.
/// {@endtemplate}
int largestPrefixLength(String first, String second) {
  var minLength = min(first.length, second.length);

  for (var i = 0; i < minLength; i += 1) {
    if (first[i] != second[i]) {
      return i;
    }
  }

  return minLength;
}

/// {@template putValue}
/// Put the value with the given key from the subtree rooted at the
/// given node.
/// {@endtemplate}
void putValue<T>(RadixTreeNode<T> node, String key, T? value) {
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
    for (var child in node.children) {
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

/// {@template removeValue}
/// Remove the value with the given key from the subtree rooted at the
/// given node.
/// {@endtemplate}
T? removeValue<T>(RadixTreeNode<T> node, String key) {
  T? result;

  var children = node.children.toList();
  var length = children.length;
  var i = 0;

  while (i < length) {
    var child = children[i];
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

/// Radix tree utility functions.
@Deprecated('Use global alternatives instead.')
abstract class RadixTreeUtils {
  /// {@macro largestPrefixLength}
  static int largestPrefixLength(String first, String second) {
    return self.largestPrefixLength(first, second);
  }

  /// {@macro putValue}
  static void putValue<T>(RadixTreeNode<T> node, String key, T? value) {
    putValue<T>(node, key, value);
  }

  /// {@macro removeValue}
  static T? removeValue<T>(RadixTreeNode<T> node, String key) {
    return removeValue<T>(node, key);
  }
}
