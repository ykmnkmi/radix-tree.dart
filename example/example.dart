// ignore_for_file: avoid_print

import 'package:radix_tree/radix_tree.dart';

void main() {
  var tree = RadixTree<int>();

  // Adding elements to the tree
  tree['home'] = 1;
  tree['home/about'] = 2;
  tree['home/contact'] = 3;
  tree['products'] = 4;
  tree['products/electronics'] = 5;
  tree['products/clothing'] = 6;

  // Printing all keys
  print('All keys: ${tree.keys}'); // [home, home/about, home/contact, products, products/electronics, products/clothing]

  // Getting values with a specific prefix
  print('Values with prefix "home": ${tree.getValuesWithPrefix('home')}'); // [1, 2, 3]
  print('Values with prefix "products": ${tree.getValuesWithPrefix('products')}'); // [4, 5, 6]

  // Checking if a key exists
  print('Contains "home/about": ${tree.containsKey('home/about')}'); // true
  print('Contains "home/blog": ${tree.containsKey('home/blog')}'); // false

  // Removing a key
  tree.remove('home/contact');
  print('All keys after removing "home/contact": ${tree.keys}'); // [home, home/about, products, products/electronics, products/clothing]

  // Getting a value by key
  print('Value for "products/electronics": ${tree['products/electronics']}'); // 5

  // Checking if the tree is empty
  print('Is tree empty: ${tree.isEmpty}'); // false

  // Clearing the tree
  tree.clear();
  print('All keys after clearing: ${tree.keys}'); // []
  print('Is tree empty after clearing: ${tree.isEmpty}'); // true
}
