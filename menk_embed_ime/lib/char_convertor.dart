/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2020 Suragch.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

import 'dart:collection';
import 'package:mongol_code/mongol_code.dart';

import 'shape_util.dart';

final Map<String, String> memoryWords = {
  'yin': '',
  'in': '',
  'un': '',
  'on': '',
  'n': '',
  'o': '',
  'u': '',
  'gi': '',
  'yi': '',
  'iyer': '',
  'ier': '',
  'ien': '',
  'iyen': '',
  'dagan': '',
  'degen': ''
};

(String, List<String>) suggestion(String latin) {
  final (correctedLatin, suggestions) = algorithmSuggestion(latin);
  final memoryWord = memoryWords[latin];
  if (memoryWord != null) {
    suggestions.insert(0, memoryWord);
  }
  if (suggestions.length == 1 && suggestions.first.isEmpty) suggestions.clear();
  final LinkedHashMap<String, String> removeDuplicate =
      LinkedHashMap<String, String>();
  for (var suggestion in suggestions) {
    removeDuplicate[ShapeUtil.getShape(suggestion)] = suggestion;
  }
  return (correctedLatin, removeDuplicate.values.toList());
}

// todo delete
List<String> nextSuggestion(String latin, String menkString) {
  // return db.nextSuggestion(menkString);
  return List.empty();
}

(String, List<String>) algorithmSuggestion(String latin) {
  var correctedLatin = latin.replaceAll('ng', 'N');
  final List<String> menkStrings = [''];
  for (;;) {
    menkStrings.clear();
    menkStrings.add('');
    var shouldContine = false;
    for (int i = 0; i < correctedLatin.length; i++) {
      final currentLetter = correctedLatin[i];
      final length = menkStrings.length;
      var shouldBreak = false;
      for (var j = 0; j < length; j++) {
        final menkString = menkStrings[j];
        final converterContext = Context(
          index: i,
          latin: correctedLatin,
          previousCode: menkString.isNotEmpty
              ? menkString.codeUnitAt(menkString.length - 1)
              : null,
        );
        final codes = converters[currentLetter]?.call(converterContext);
        if (codes == null) {
          // current letter is not supported, delete the current letter
          if (i == 0) {
            correctedLatin = correctedLatin.substring(1);
          } else if (i >= correctedLatin.length) {
            correctedLatin = correctedLatin.substring(0, i - 1);
          } else {
            correctedLatin = correctedLatin.substring(0, i) +
                correctedLatin.substring(i + 1);
          }
          shouldContine = true;
          shouldBreak = true;
          break;
        }
        menkStrings[j] = menkString + String.fromCharCode(codes[0]);
        if (codes.length > 1) {
          for (var k = 1; k < codes.length; k++) {
            menkStrings.add(menkString + String.fromCharCode(codes[k]));
          }
        }
      }
      if (shouldBreak) break;
    }
    if (shouldContine) continue;
    break;
  }
  return (correctedLatin, menkStrings);
}

typedef Converter = List<int> Function(Context context);

class Context {
  Context({
    required this.latin,
    required this.index,
    required this.previousCode,
  })  : previousLetter = (index > 0 ? latin[index - 1] : ''),
        nextLetter = (index < latin.length - 1 ? latin[index + 1] : '');

  final String previousLetter;
  final String nextLetter;
  final String latin;
  final int index;
  final int? previousCode;

  bool get isIsolate => previousLetter.isEmpty && nextLetter.isEmpty;

  bool get isInitial => previousLetter.isEmpty && nextLetter.isNotEmpty;

  bool get isMedial => previousLetter.isNotEmpty && nextLetter.isNotEmpty;

  bool get isFinal => previousLetter.isNotEmpty && nextLetter.isEmpty;

  Location get location {
    if (isIsolate) return Location.ISOLATE;
    if (isInitial) return Location.INITIAL;
    if (isMedial) return Location.MEDIAL;
    return Location.FINAL;
  }

  bool get isPreviousRoundAnytime {
    return 'b' == previousLetter ||
        'p' == previousLetter ||
        'f' == previousLetter ||
        'k' == previousLetter ||
        'K' == previousLetter;
  }

  bool get isPreviousHG {
    return 'h' == previousLetter || 'g' == previousLetter;
  }

  bool get isPreviousMvs {
    return Menksoft.MEDI_NA_FVS2 == previousCode ||
        // QA
        Menksoft.MEDI_QA_FVS2 == previousCode ||
        Menksoft.MEDI_QA_FVS3 == previousCode ||
        // GA
        Menksoft.MEDI_GA_FVS2 == previousCode ||
        // MA
        Menksoft.FINA_MA == previousCode ||
        // LA
        Menksoft.FINA_LA == previousCode ||
        // SA
        Menksoft.FINA_SA == previousCode ||
        // SHA
        Menksoft.FINA_SHA == previousCode ||
        // JA
        Menksoft.MEDI_JA_FVS1 == previousCode ||
        // YA
        Menksoft.MEDI_YA_FVS2 == previousCode ||
        // RA
        Menksoft.FINA_RA == previousCode ||
        // WA
        Menksoft.FINA_WA_FVS1 == previousCode;
  }

  bool needToothU(int index) {
    if (index < 0) return false;

    if (latin[index] != 'u') return false;

    if (index == 0) return true;

    if (index == 1) {
      return isConsonant(latin[0]);
    }

    return false;
  }

  bool isConsonant(String letter) {
    return 'a' != letter &&
        'e' != letter &&
        'i' != letter &&
        'o' != letter &&
        'u' != letter &&
        'A' != letter &&
        'E' != letter &&
        'O' != letter &&
        'U' != letter;
  }

  bool findMaleLetterFromPrevious(int index) {
    if (index < 0) return false;
    for (int i = index; i >= 0; i--) {
      final letter = latin[i];
      if ('a' == letter || 'o' == letter) return true;
    }
    return false;
  }

  bool isMaleWord() {
    return (latin.contains('a') ||
            latin.contains('o') ||
            latin.contains('A') ||
            latin.contains('O')) &&
        !latin.contains('e') &&
        !latin.contains('u') &&
        !latin.contains('E') &&
        !latin.contains('U');
  }

  bool findForeignLetterPrevious(int index) {
    if (index < 0) return false;
    final foreign = ['w', 'f', 'k', 'K', 'c', 'z', 'H', 'R', 'L', 'Z', 'C'];
    for (int i = index; i >= 0; i--) {
      final letter = latin[i];
      if (foreign.contains(letter)) return true;
    }
    return false;
  }

  bool get isNextOU {
    return 'o' == nextLetter ||
        'u' == nextLetter ||
        'O' == nextLetter ||
        'U' == nextLetter;
  }

  bool get isNextMale {
    return 'a' == nextLetter ||
        'o' == nextLetter ||
        'A' == nextLetter ||
        'O' == nextLetter;
  }

  bool get canUseMvs {
    return (latin.endsWith('a') || latin.endsWith('e')) &&
        index == latin.length - 2;
  }

  bool get isNaima {
    final naimaIndex = latin.indexOf('naima');
    return naimaIndex >= 0 && latin[index] == 'i' && naimaIndex + 2 == index;
  }

  bool get isJixiye {
    final jixiyeIndex = latin.indexOf('jixiye');
    return jixiyeIndex >= 0 && latin[index] == 'x' && jixiyeIndex + 2 == index;
  }
}

final Map<String, Converter> converters = {
  'a': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_A];
      case Location.INITIAL:
        return [
          Menksoft.INIT_A,
        ];
      case Location.MEDIAL:
        return [
          context.isPreviousRoundAnytime ? Menksoft.MEDI_A_BP : Menksoft.MEDI_A,
        ];
      case Location.FINAL:
        return [
          if (context.isPreviousMvs)
            Menksoft.FINA_A_MVS
          else if (context.isPreviousRoundAnytime)
            Menksoft.FINA_A_BP
          else
            Menksoft.FINA_A,
        ];
    }
  },
  'A': (context) {
    switch (context.location) {
      case Location.MEDIAL:
        return [Menksoft.MEDI_A_FVS1];
      default:
        return converters['a']!.call(context);
    }
  },
  'e': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_E];
      case Location.INITIAL:
        return [
          Menksoft.INIT_E,
        ];
      case Location.MEDIAL:
        return [
          if (context.isPreviousRoundAnytime || context.isPreviousHG)
            Menksoft.MEDI_E_BP
          else
            Menksoft.MEDI_E,
        ];
      case Location.FINAL:
        return [
          if (context.isPreviousMvs)
            Menksoft.FINA_E_MVS
          else if (context.isPreviousRoundAnytime || context.isPreviousHG)
            Menksoft.FINA_E_BP
          else
            Menksoft.FINA_E,
        ];
    }
  },
  'E': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_EE];
      case Location.INITIAL:
        return [Menksoft.INIT_EE];
      case Location.MEDIAL:
        return [Menksoft.MEDI_EE];
      case Location.FINAL:
        return [Menksoft.FINA_EE];
    }
  },
  'i': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [
          Menksoft.ISOL_I,
          Menksoft.ISOL_I_SUFFIX,
        ];
      case Location.INITIAL:
        return [
          Menksoft.INIT_I,
          Menksoft.MEDI_I_SUFFIX,
        ];
      case Location.MEDIAL:
        return [
          if (context.isNaima) Menksoft.MEDI_I,
          if ('a' == context.previousLetter ||
              'e' == context.previousLetter ||
              'o' == context.previousLetter ||
              ('u' == context.previousLetter &&
                  !context.needToothU(context.index - 1)))
            Menksoft.MEDI_I_DOUBLE_TOOTH
          else if (context.isPreviousRoundAnytime)
            Menksoft.MEDI_I_BP
          else
            Menksoft.MEDI_I
        ];
      case Location.FINAL:
        return [
          if (context.isPreviousRoundAnytime || context.isPreviousHG)
            Menksoft.FINA_I_BP
          else
            Menksoft.FINA_I,
        ];
    }
  },
  'o': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_O];
      case Location.INITIAL:
        return [Menksoft.INIT_O];
      case Location.MEDIAL:
        return [
          context.isPreviousRoundAnytime ? Menksoft.MEDI_O_BP : Menksoft.MEDI_O,
        ];
      case Location.FINAL:
        return [
          if (context.isPreviousRoundAnytime)
            Menksoft.FINA_O_BP
          else
            Menksoft.FINA_O,
          if (!context.isPreviousRoundAnytime) Menksoft.FINA_O_FVS1
        ];
    }
  },
  'O': (context) {
    switch (context.location) {
      case Location.INITIAL:
        return [Menksoft.MEDI_O];
      case Location.MEDIAL:
        return [Menksoft.MEDI_O_FVS1];
      default:
        return converters['o']!.call(context);
    }
  },
  'u': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_UE];
      case Location.INITIAL:
        return [Menksoft.INIT_UE];
      case Location.MEDIAL:
        return [
          if ((context.isPreviousRoundAnytime || context.isPreviousHG) &&
              context.needToothU(context.index))
            Menksoft.MEDI_UE_FVS1_BP
          else if (context.needToothU(context.index))
            Menksoft.MEDI_UE_FVS1
          else if (context.isPreviousRoundAnytime || context.isPreviousHG)
            Menksoft.MEDI_U_BP
          else
            Menksoft.MEDI_U,
        ];
      case Location.FINAL:
        return [
          if (context.isPreviousRoundAnytime || context.isPreviousHG)
            Menksoft.FINA_UE_BP
          else
            Menksoft.FINA_UE,
          if (context.isPreviousRoundAnytime || context.isPreviousHG)
            Menksoft.FINA_UE_FVS1_BP
          else
            Menksoft.FINA_UE_FVS1,
        ];
    }
  },
  'U': (context) {
    switch (context.location) {
      case Location.MEDIAL:
        return [
          if ((context.isPreviousRoundAnytime || context.isPreviousHG))
            Menksoft.MEDI_UE_FVS1_BP
          else
            Menksoft.MEDI_UE_FVS1,
          if (!context.isPreviousRoundAnytime && !context.isPreviousHG)
            Menksoft.MEDI_UE_FVS2,
        ];
      default:
        return converters['u']!.call(context);
    }
  },
  'n': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_NA];
      case Location.INITIAL:
        return [Menksoft.INIT_NA_TOOTH];
      case Location.MEDIAL:
        return [
          if (context.canUseMvs)
            Menksoft.MEDI_NA_FVS2
          else if (context.isConsonant(context.nextLetter) ||
              context.nextLetter == 'A' ||
              context.nextLetter == 'O' ||
              context.nextLetter == 'U')
            Menksoft.MEDI_NA_TOOTH
          else
            Menksoft.MEDI_NA_FVS1_TOOTH,
          // todo MEDI_NA_TOOTH in foreign word 
          // if (context.findForeignLetterPrevious(context.index))
          //   Menksoft.MEDI_NA_TOOTH
        ];
      case Location.FINAL:
        return [Menksoft.FINA_NA];
    }
  },
  'N': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_ANG];
      case Location.INITIAL:
        return [Menksoft.INIT_ANG_TOOTH];
      case Location.MEDIAL:
        return [Menksoft.MEDI_ANG_TOOTH];
      case Location.FINAL:
        return [Menksoft.FINA_ANG];
    }
  },
  'b': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_BA];
      case Location.INITIAL:
        return [
          if (context.isNextOU) Menksoft.INIT_BA_OU else Menksoft.INIT_BA,
        ];
      case Location.MEDIAL:
        return [
          if (context.isNextOU) Menksoft.MEDI_BA_OU else Menksoft.MEDI_BA_TOOTH,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_BA];
    }
  },
  'p': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_PA];
      case Location.INITIAL:
        return [
          if (context.isNextOU) Menksoft.INIT_PA_OU else Menksoft.INIT_PA,
        ];
      case Location.MEDIAL:
        return [
          if (context.isNextOU) Menksoft.MEDI_PA_OU else Menksoft.MEDI_PA_TOOTH,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_PA];
    }
  },
  'h': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_QA];
      case Location.INITIAL:
        return [
          if (context.isNextMale)
            Menksoft.INIT_QA_TOOTH
          else if (context.isNextOU)
            Menksoft.INIT_QA_FEM_OU
          else
            Menksoft.INIT_QA_FEM,
        ];
      case Location.MEDIAL:
        return [
          if (context.isNextMale && context.canUseMvs)
            Menksoft.MEDI_QA_FVS3
          else if (context.isNextMale)
            Menksoft.MEDI_QA_TOOTH
          else if (context.isNextOU)
            Menksoft.MEDI_QA_FEM_OU
          else
            Menksoft.MEDI_QA_FEM,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_QA];
    }
  },
  'H': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_HAA];
      case Location.INITIAL:
        return [Menksoft.INIT_HAA];
      case Location.MEDIAL:
        return [Menksoft.MEDI_HAA];
      case Location.FINAL:
        return [Menksoft.FINA_HAA];
    }
  },
  'g': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_GA];
      case Location.INITIAL:
        return [
          if (context.isNextMale)
            Menksoft.INIT_GA_TOOTH
          else if (context.isNextOU)
            Menksoft.INIT_GA_FEM_OU
          else
            Menksoft.INIT_GA_FEM,
        ];
      case Location.MEDIAL:
        return [
          if (context.isConsonant(context.nextLetter) &&
              (context.findMaleLetterFromPrevious(context.index - 1) ||
                  context.isMaleWord()) &&
              !context.findForeignLetterPrevious(context.index - 1))
            Menksoft.MEDI_GA
          else if (context.isConsonant(context.nextLetter))
            Menksoft.MEDI_GA_FVS3_TOOTH
          else if (context.isNextMale && context.canUseMvs)
            Menksoft.MEDI_GA_FVS2
          else if (context.isNextMale)
            Menksoft.MEDI_GA_FVS1_TOOTH
          else if (context.isNextOU)
            Menksoft.MEDI_GA_FEM_OU
          else
            Menksoft.MEDI_GA_FEM,
        ];
      case Location.FINAL:
        return [
          if (context.findMaleLetterFromPrevious(context.index - 1) &&
              !context.findForeignLetterPrevious(context.index - 1))
            Menksoft.FINA_GA
          else
            Menksoft.FINA_GA_FVS2
        ];
    }
  },
  'm': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_MA];
      case Location.INITIAL:
        return [Menksoft.INIT_MA_TOOTH];
      case Location.MEDIAL:
        return [
          if (context.isPreviousRoundAnytime ||
              context.previousLetter == 'N' ||
              context.previousCode == Menksoft.MEDI_GA_FVS3_TOOTH)
            Menksoft.MEDI_MA_BP
          else
            Menksoft.MEDI_MA_TOOTH,
          if (context.canUseMvs) Menksoft.FINA_MA,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_MA];
    }
  },
  'l': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_LA];
      case Location.INITIAL:
        return [Menksoft.INIT_LA_TOOTH];
      case Location.MEDIAL:
        return [
          if (context.canUseMvs) Menksoft.FINA_LA,
          if (context.isPreviousRoundAnytime ||
              context.previousLetter == 'N' ||
              context.previousCode == Menksoft.MEDI_GA_FVS3_TOOTH)
            Menksoft.MEDI_LA_BP
          else
            Menksoft.MEDI_LA_TOOTH,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_LA];
    }
  },
  'L': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_LHA];
      case Location.INITIAL:
        return [Menksoft.INIT_LHA];
      case Location.MEDIAL:
        return [
          if (context.isPreviousRoundAnytime ||
              context.previousLetter == 'N' ||
              context.previousCode == Menksoft.MEDI_GA_FVS3_TOOTH)
            Menksoft.MEDI_LHA_BP
          else
            Menksoft.MEDI_LHA
        ];
      case Location.FINAL:
        return [
          if (context.isPreviousRoundAnytime ||
              context.previousLetter == 'N' ||
              context.previousCode == Menksoft.MEDI_GA_FVS3_TOOTH)
            Menksoft.FINA_LHA_BP
          else
            Menksoft.FINA_LHA
        ];
    }
  },
  's': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_SA];
      case Location.INITIAL:
        return [Menksoft.INIT_SA_TOOTH];
      case Location.MEDIAL:
        return [Menksoft.MEDI_SA_TOOTH];
      case Location.FINAL:
        return [Menksoft.FINA_SA];
    }
  },
  'x': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_SHA];
      case Location.INITIAL:
        return [
          if (context.nextLetter == 'i')
            Menksoft.INIT_SA_TOOTH
          else
            Menksoft.INIT_SHA_TOOTH
        ];
      case Location.MEDIAL:
        return [
          if (context.isJixiye) ...[
            Menksoft.MEDI_SHA_TOOTH,
            Menksoft.MEDI_SA_TOOTH
          ] else if (context.nextLetter == 'i')
            Menksoft.MEDI_SA_TOOTH
          else
            Menksoft.MEDI_SHA_TOOTH
        ];
      case Location.FINAL:
        return [Menksoft.FINA_SHA];
    }
  },
  'X': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_SHA];
      case Location.INITIAL:
        return [Menksoft.INIT_SHA_TOOTH];
      case Location.MEDIAL:
        return [Menksoft.MEDI_SHA_TOOTH];
      case Location.FINAL:
        return [Menksoft.FINA_SHA];
    }
  },
  't': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_TA];
      case Location.INITIAL:
        return [Menksoft.INIT_TA_TOOTH];
      case Location.MEDIAL:
        return [
          Menksoft.MEDI_TA,
          Menksoft.MEDI_TA_FVS1_TOOTH,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_TA];
    }
  },
  'd': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_DA];
      case Location.INITIAL:
        return [
          if (context.latin.length == 2)
            Menksoft.INIT_DA_FVS1
          else
            Menksoft.INIT_DA_TOOTH
        ];
      case Location.MEDIAL:
        return [
          if (context.isConsonant(context.nextLetter))
            Menksoft.MEDI_DA
          else
            Menksoft.MEDI_DA_FVS1,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_DA, Menksoft.FINA_DA_FVS1];
    }
  },
  'D': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_DA];
      case Location.INITIAL:
        return [Menksoft.INIT_DA_FVS1];
      default:
        return [];
    }
  },
  'q': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_CHA];
      case Location.INITIAL:
        return [Menksoft.INIT_CHA];
      case Location.MEDIAL:
        return [Menksoft.MEDI_CHA];
      case Location.FINAL:
        return [Menksoft.FINA_CHA];
    }
  },
  'j': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_JA];
      case Location.INITIAL:
        return [Menksoft.INIT_JA_TOOTH];
      case Location.MEDIAL:
        return [Menksoft.MEDI_JA];
      case Location.FINAL:
        return [Menksoft.FINA_JA];
    }
  },
  'y': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_YA];
      case Location.INITIAL:
        return [Menksoft.INIT_YA];
      case Location.MEDIAL:
        return [
          if (context.canUseMvs) Menksoft.MEDI_YA_FVS2,
          Menksoft.MEDI_YA_FVS1,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_JA];
    }
  },
  'r': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_RA];
      case Location.INITIAL:
        return [Menksoft.INIT_RA_TOOTH];
      case Location.MEDIAL:
        return [
          Menksoft.MEDI_RA_TOOTH,
          if (context.canUseMvs) Menksoft.FINA_RA,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_RA];
    }
  },
  'w': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_WA];
      case Location.INITIAL:
        return [Menksoft.INIT_WA];
      case Location.MEDIAL:
        return [
          Menksoft.MEDI_WA,
          if (context.canUseMvs) Menksoft.FINA_WA_FVS1,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_WA];
    }
  },
  'f': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_FA];
      case Location.INITIAL:
        return [
          if (context.isNextOU) Menksoft.INIT_FA_OU else Menksoft.INIT_FA
        ];
      case Location.MEDIAL:
        return [
          if (context.isNextOU) Menksoft.MEDI_FA_OU else Menksoft.MEDI_FA_TOOTH
        ];
      case Location.FINAL:
        return [Menksoft.FINA_FA];
    }
  },
  'k': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_KA];
      case Location.INITIAL:
        return [
          if (context.isNextOU) Menksoft.INIT_KA_OU else Menksoft.INIT_KA
        ];
      case Location.MEDIAL:
        return [
          if (context.isNextOU) Menksoft.MEDI_KA_OU else Menksoft.MEDI_KA_TOOTH,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_KA];
    }
  },
  'K': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_KHA];
      case Location.INITIAL:
        return [
          if (context.isNextOU) Menksoft.INIT_KHA_OU else Menksoft.INIT_KHA
        ];
      case Location.MEDIAL:
        return [
          if (context.isNextOU)
            Menksoft.MEDI_KHA_OU
          else
            Menksoft.MEDI_KHA_TOOTH,
        ];
      case Location.FINAL:
        return [Menksoft.FINA_KHA];
    }
  },
  'c': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_TSA];
      case Location.INITIAL:
        return [Menksoft.INIT_TSA];
      case Location.MEDIAL:
        return [Menksoft.MEDI_TSA];
      case Location.FINAL:
        return [Menksoft.FINA_TSA];
    }
  },
  'z': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_ZA];
      case Location.INITIAL:
        return [Menksoft.INIT_ZA];
      case Location.MEDIAL:
        return [Menksoft.MEDI_ZA];
      case Location.FINAL:
        return [Menksoft.FINA_ZA];
    }
  },
  'R': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_ZRA];
      case Location.INITIAL:
        return [Menksoft.INIT_ZRA];
      case Location.MEDIAL:
        return [Menksoft.MEDI_ZRA];
      case Location.FINAL:
        return [Menksoft.FINA_ZRA];
    }
  },
  'Z': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_ZHI];
      case Location.INITIAL:
        return [Menksoft.INIT_ZHI];
      case Location.MEDIAL:
        return [Menksoft.MEDI_ZHI];
      case Location.FINAL:
        return [Menksoft.FINA_ZHI];
    }
  },
  'C': (context) {
    switch (context.location) {
      case Location.ISOLATE:
        return [Menksoft.ISOL_CHI];
      case Location.INITIAL:
        return [Menksoft.INIT_CHI];
      case Location.MEDIAL:
        return [Menksoft.MEDI_CHI];
      case Location.FINAL:
        return [Menksoft.FINA_CHI];
    }
  },
};

String latinForCode(int code) {
  if (code <= 57967) {
    return "a";
  } else if (code <= 57976) {
    return "e";
  } else if (code <= 57986) {
    return "i";
  } else if (code <= 0xE28A) {
    return "ʊ";
  } else if (code <= 0xE292) {
    return "ʊ";
  } else if (code <= 0xE29F) {
    return "u";
  } else if (code <= 0xE2AC) {
    return "u";
  } else if (code <= 0xE2B0) {
    return "e";
  } else if (code <= 0xE2BA) {
    return "n";
  } else if (code <= 0xE2BE) {
    return "n";
  } else if (code <= 0xE2C0) {
    return "n";
  } else if (code <= 0xE2C7) {
    return "b";
  } else if (code <= 0xE2CD) {
    return "p";
  } else if (code <= 0xE2E0) {
    return "h";
  } else if (code <= 0xE2F0) {
    return "g";
  } else if (code <= 0xE2F6) {
    return "m";
  } else if (code <= 0xE2FC) {
    return "l";
  } else if (code <= 0xE302) {
    return "s";
  } else if (code <= 0xE307) {
    return "x";
  } else if (code <= 0xE30D) {
    return "t";
  } else if (code <= 0xE314) {
    return "d";
  } else if (code <= 0xE317) {
    return "q";
  } else if (code <= 0xE31D) {
    return "j";
  } else if (code <= 0xE321) {
    return "y";
  } else if (code <= 0xE328) {
    return "r";
  } else if (code <= 0xE32C) {
    return "w";
  } else if (code <= 0xE332) {
    return "f";
  } else if (code <= 0xE338) {
    return "k";
  } else if (code <= 0xE33E) {
    return "k";
  } else if (code <= 0xE341) {
    return "c";
  } else if (code <= 0xE344) {
    return "z";
  } else if (code <= 0xE347) {
    return "h";
  } else if (code <= 0xE34A) {
    return "z";
  } else if (code <= 0xE34D) {
    return "l";
  } else if (code <= 0xE34E) {
    return "z";
  } else {
    return "c";
  }
}
