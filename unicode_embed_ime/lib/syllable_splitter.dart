/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2025 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

/// Mongolian syllable splitter utility for Unicode IME
/// 
/// This implementation loosely follows Mongolian syllable splitting rules but is
/// primarily designed for candidate generation rather than strict linguistic accuracy.
/// The algorithm uses reverse traversal to identify syllable boundaries, which works
/// well for most common Mongolian words but may not strictly adhere to traditional
/// syllable splitting rules in all cases.
/// 
/// The main concept is to produce meaningful syllable-based candidates for text input,
/// prioritizing practical IME functionality over perfect linguistic compliance.
/// 
/// Algorithm overview:
/// 1. Split input at unsupported characters (like 'v', '-', spaces)
/// 2. For each supported segment, traverse from right to left
/// 3. Group vowels with preceding consonants to form syllables
/// 4. Handle consecutive vowels by keeping them in the same syllable
/// 
/// Examples:
/// - "moNgol" → ["moN", "gol"]
/// - "hariyaqai" → ["ha", "ri", "ya", "qai"] 
/// - "humun" → ["hu", "mun"]
class SyllableSplitter {
  /// Vowels in Mongolian script
  static const Set<String> _vowels = {'a', 'e', 'i', 'o', 'u'};
  
  /// Supported Mongolian consonants
  static const Set<String> _consonants = {
    'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'w', 'x', 'y', 'z'
  };
  
  /// Check if a character is a vowel
  static bool isVowel(String char) {
    return _vowels.contains(char.toLowerCase());
  }
  
  /// Check if a character is a supported Mongolian character
  static bool isSupportedChar(String char) {
    String lower = char.toLowerCase();
    return _vowels.contains(lower) || _consonants.contains(lower);
  }
  
  /// Split a Mongolian word into syllables using reverse traversal algorithm
  static List<String> split(String word) {
    if (word.isEmpty) return [];
    
    // First split by unsupported characters
    List<String> parts = [];
    String currentPart = "";
    
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      if (isSupportedChar(char)) {
        currentPart += char;
      } else {
        // Unsupported character - split here
        if (currentPart.isNotEmpty) {
          parts.add(currentPart);
          currentPart = "";
        }
      }
    }
    
    // Add remaining part
    if (currentPart.isNotEmpty) {
      parts.add(currentPart);
    }
    
    // Now process each supported part
    List<String> allSyllables = [];
    for (String part in parts) {
      allSyllables.addAll(_splitSupportedWord(part));
    }
    
    return allSyllables;
  }
  
  /// Split a word containing only supported characters into syllables
  static List<String> _splitSupportedWord(String word) {
    if (word.isEmpty) return [];
    if (word.length == 1) return [word];
    
    List<String> syllables = [];
    String currentSyllable = "";
    
    // Process from right to left (reverse)
    for (int i = word.length - 1; i >= 0; i--) {
      String char = word[i];
      currentSyllable = char + currentSyllable;
      
      // If current character is a vowel
      if (isVowel(char)) {
        // Collect all consecutive vowels to the left
        while (i > 0 && isVowel(word[i - 1])) {
          i--;
          currentSyllable = word[i] + currentSyllable;
        }
        
        // Look ahead (to the left) for consonant
        if (i > 0) {
          String nextChar = word[i - 1];
          
          // If next char is consonant, include it in current syllable
          if (!isVowel(nextChar)) {
            currentSyllable = nextChar + currentSyllable;
            i--; // Skip the consonant in next iteration
          }
        }
        
        // End current syllable
        syllables.insert(0, currentSyllable);
        currentSyllable = "";
      }
    }
    
    // Handle any remaining consonants at the beginning
    if (currentSyllable.isNotEmpty) {
      if (syllables.isNotEmpty) {
        // Prepend to first syllable
        syllables[0] = currentSyllable + syllables[0];
      } else {
        syllables.add(currentSyllable);
      }
    }
    
    return syllables;
  }
}