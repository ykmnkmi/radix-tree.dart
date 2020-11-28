import 'dart:math' show Random;

import 'package:radix_tree/radix_tree.dart';
import 'package:test/test.dart';

void main() {
  group('Test RadixTree', () {
    setUp(() {});

    test('Largest Prefix', () {
      expect(RadixTreeUtils.largestPrefixLength('abcdefg', 'abcdexyz'), equals(5));
      expect(RadixTreeUtils.largestPrefixLength('abcdefg', 'abcxyz'), equals(3));
      expect(RadixTreeUtils.largestPrefixLength('abcdefg', 'abctuvxyz'), equals(3));
      expect(RadixTreeUtils.largestPrefixLength('abcdefg', ''), equals(0));
      expect(RadixTreeUtils.largestPrefixLength('', 'abcdexyz'), equals(0));
      expect(RadixTreeUtils.largestPrefixLength('xyz', 'abcxyz'), equals(0));
    });

    test('Empty Tree', () {
      expect(RadixTree<int>(), isEmpty);
    });

    test('Single Insertion', () {
      final tree = RadixTree<int>();
      tree['test'] = 1;
      expect(tree, isNotEmpty);
      expect(tree, hasLength(equals(1)));
      expect(tree, contains('test'));
    });

    test('Multiple Insertions', () {
      final tree = RadixTree<int>();
      tree['test'] = 1;
      tree['tent'] = 2;
      tree['tank'] = 3;
      tree['rest'] = 4;
      expect(tree, hasLength(equals(4)));
      expect(tree, containsPair('test', equals(1)));
      expect(tree, containsPair('tent', equals(2)));
      expect(tree, containsPair('tank', equals(3)));
      expect(tree, containsPair('rest', equals(4)));
    });

    test('Multiple Insertions Of The Same Key', () {
      final tree = RadixTree<int>();
      tree['test'] = 1;
      tree['tent'] = 2;
      tree['tank'] = 3;
      tree['rest'] = 4;
      expect(tree, hasLength(4));
      expect(tree, containsPair('test', equals(1)));
      expect(tree, containsPair('tent', equals(2)));
      expect(tree, containsPair('tank', equals(3)));
      expect(tree, containsPair('rest', equals(4)));

      tree['test'] = 9;
      expect(tree, hasLength(equals(4)));
      expect(tree, containsPair('test', 9));
      expect(tree, containsPair('tent', 2));
      expect(tree, containsPair('tank', 3));
      expect(tree, containsPair('rest', 4));
    });

    test('Prefix Fetch', () {
      final tree = RadixTree<int>();
      tree['test'] = 1;
      tree['tent'] = 2;
      tree['rest'] = 3;
      tree['tank'] = 4;
      expect(tree, hasLength(equals(4)));
      expect(tree.getValuesWithPrefix(''), containsAll(tree.values));
      expect(tree.getValuesWithPrefix('t'), containsAll(const <int>[1, 2, 4]));
      expect(tree.getValuesWithPrefix('te'), containsAll(const <int>[1, 2]));
      expect(tree.getValuesWithPrefix('asd'), containsAll(const <int>[]));
    });

    test('Spook', () {
      final tree = RadixTree<int>();
      tree['pook'] = 1;
      tree['spook'] = 2;
      expect(tree, hasLength(equals(2)));
      expect(tree.keys, containsAll(<String>['pook', 'spook']));
    });

    test('Removal', () {
      final tree = RadixTree<int>();
      tree['test'] = 1;
      tree['tent'] = 2;
      tree['tank'] = 3;
      expect(tree, hasLength(equals(3)));
      expect(tree, contains('tent'));

      tree.remove('key');
      expect(tree, hasLength(equals(3)));
      expect(tree, contains('tent'));

      tree.remove('tent');
      expect(tree, hasLength(equals(2)));
      expect(tree, containsPair('test', equals(1)));
      expect(tree, isNot(contains('tent')));
      expect(tree, containsPair('tank', equals(3)));
    });

    test('Many Insertions', () {
      final tree = RadixTree<BigInt>();

      const hex = '0123456789ABCDEF';
      final random = Random();
      final bigInts = <BigInt>[];
      var i = 100 + random.nextInt(400);

      while (i > 0) {
        final bigInt = BigInt.parse(List<String>.generate(20, (index) => hex[random.nextInt(0xF)]).join(), radix: 0xF);

        if (!bigInts.contains(bigInt)) {
          bigInts.add(bigInt);
          tree[bigInt.toRadixString(0xF)] = bigInt;
        }

        i -= 1;
      }

      expect(tree, hasLength(equals(bigInts.length)));

      for (final bigInt in bigInts) {
        expect(tree, containsPair(bigInt.toRadixString(0xF), equals(bigInt)));
      }

      expect(tree.values, containsAll(bigInts));
    });
  });
}
