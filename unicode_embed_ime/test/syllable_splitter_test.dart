import 'package:flutter_test/flutter_test.dart';
import 'package:unicode_embed_ime/syllable_splitter.dart';

void main() {
  group('SyllableSplitter', () {
    test('isVowel should correctly identify vowels', () {
      expect(SyllableSplitter.isVowel('a'), true);
      expect(SyllableSplitter.isVowel('e'), true);
      expect(SyllableSplitter.isVowel('i'), true);
      expect(SyllableSplitter.isVowel('o'), true);
      expect(SyllableSplitter.isVowel('u'), true);
      expect(SyllableSplitter.isVowel('A'), true);
      expect(SyllableSplitter.isVowel('E'), true);
      expect(SyllableSplitter.isVowel('I'), true);
      expect(SyllableSplitter.isVowel('O'), true);
      expect(SyllableSplitter.isVowel('U'), true);
    });

    test('isVowel should correctly identify consonants', () {
      expect(SyllableSplitter.isVowel('b'), false);
      expect(SyllableSplitter.isVowel('c'), false);
      expect(SyllableSplitter.isVowel('d'), false);
      expect(SyllableSplitter.isVowel('m'), false);
      expect(SyllableSplitter.isVowel('n'), false);
      expect(SyllableSplitter.isVowel('q'), false);
    });

    test('split should handle empty string', () {
      expect(SyllableSplitter.split(''), isEmpty);
    });

    test('split should handle single vowel', () {
      expect(SyllableSplitter.split('a'), equals(['a']));
      expect(SyllableSplitter.split('i'), equals(['i']));
    });

    test('split should handle single consonant', () {
      expect(SyllableSplitter.split('b'), equals(['b']));
      expect(SyllableSplitter.split('m'), equals(['m']));
    });

    test('split should split hariyaqai correctly', () {
      // "hariyaqai" → "iaqayirah" → "iaq-ay-ir-ah" → "ha-ri-ya-qai"
      expect(
        SyllableSplitter.split('hariyaqai'),
        equals(['ha', 'ri', 'ya', 'qai']),
      );
      expect(SyllableSplitter.split('xiidburilehu'), equals(['xiid', 'bu', 'ri', 'le', 'hu']));
    });

    test('split should split humun correctly', () {
      // "humun" → "numuh" → "nu-muh" → "hu-mun"
      expect(SyllableSplitter.split('humun'), equals(['hu', 'mun']));
    });

    test('split should split mongol correctly', () {
      expect(SyllableSplitter.split('moNgol'), equals(['moN', 'gol']));
    });

    test('split should handle consecutive vowels', () {
      expect(SyllableSplitter.split('horoa'), equals(['ho', 'roa']));
    });

    test('split should handle consecutive vowels', () {
      expect(SyllableSplitter.split('gool'), equals(['gool']));
    });

    test('split should handle consecutive vowels', () {
      expect(SyllableSplitter.split('ail'), equals(['ail']));
    });

    test('split should handle unsupported characters', () {
      expect(SyllableSplitter.split('mago-uhin'), equals(['ma', 'go', 'u', 'hin']));
      expect(SyllableSplitter.split('magovuhin'), equals(['ma', 'go', 'u', 'hin']));
      expect(SyllableSplitter.split('mago uhin'), equals(['ma', 'go', 'u', 'hin']));
    });
  });
}
