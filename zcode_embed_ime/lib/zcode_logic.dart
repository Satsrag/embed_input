/*
 * Copyright 2014 The Flutter Authors.
 * Copyright 2021 Zmongol.
 * Copyright 2023 Satsrag.
 * All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 * This file is copied from [zmongol/zmongol2021](https://github.com/zmongol/zmongol2021/blob/main/lib/Utils/ZcodeLogic.dart) 
 * and modified to fit the needs of this project. This file copyright is belong 
 * to [Zmongol](https://github.com/zmongol).
 */

final dagbr = {
  "in": "ᡬᡬᡧ ",
  "yin": "ᡬᡬᡧ ",
  "on": "ᡭᡧ ",
  "o": "ᡳ ",
  "ban": "ᡳᡪᡧ ",
  "iyan": "ᡬᡬᡪᡧ ",
  "iyen": "ᡬᡬᡪᡧ ",
  "bar": "ᡳᡪᢝ ",
  "iyar": "ᡬᡬᡪᢝ ",
  "iyer": "ᡬᡬᡪᢝ ",
  "yi": "ᡬᡫ ",
  "ji": "ᡬᡫ ",
  "gi": "ᡬᡫ ",
  "i": "ᡫ ",
  "to": "ᢘᡳ ",
  "do": "ᢙᡳ ",
  "tor": "ᢘᡭᢝ ",
  "dor": "ᢙᡭᢝ ",
  "tahi": "ᢘᡪᢊᡬᡦ ",
  "dahi": "ᢙᡪᢊᡬᡦ ",
  "toni": "ᢘᡭᡱᡫ ",
  "doni": "ᢙᡭᡱᡫ ",
  "tai": "ᢘᡪᡫ ",
  "loga": "ᢏᡭᢉᡨ ",
  "luge": "ᢏᡭᢊᡪᡨ ",
  "aca": "ᡥᢚᡧ ",
  "dagan": "ᢙᡪᡱᡱᡪᡧ ",
  "degen": "ᢙᡪᢊᡪᡧ ",
  "tagan": "ᢘᡪᡱᡱᡪᡧ ",
  "tegen": "ᢘᡪᢊᡪᡧ ",
  "nogod": "ᡯᡭᡱᡱᡭᡭᡧ ",
  "nugud": "ᡯᡭᢋᡭᡭᡧ ",
  "od": "ᡭᡭᡧ ",
  "oo": "ᡭᡳ ",
  "uu": "ᡭᡳ ",
  "nar": "ᡯᡪᢝ ",
  "mini": "ᢌᡬᡱᡫ ",
  "cini": "ᢚᡬᡱᡫ ",
  "ni": "ᡯᡫ "
};

var aArr = ["ᡥᡧ", "", "", "ᡥᡪ", "ᡪᡪ", "", "ᡪ", "ᡪᡪ", "", "ᡧ", "ᡪᡨ", "ᡨ"];
var eArr = ["ᡥᡨ", "", "", "ᡥ", "ᡪᡪ", "", "ᡪ", "ᡪᡪ", "", "ᡪᡨ", "ᡧ", "ᡨ"];
var iArr = ["ᡫ", "", "", "ᡥᡬ", "", "", "ᡬ", "ᡬᡬ", "ᡪᡬ", "ᡫ", "ᡬᡦ", ""];
var oArr = ["ᡥᡭ", "ᡥᡭ", "", "ᡥᡭ", "", "", "ᡭ", "ᡪᡭ", "", "ᡳ", "ᡭ", ""];
var uArr = ["ᡥᡭᡦ", "", "", "ᡥᡭᡬ", "", "", "ᡭ", "ᡭᡬ", "ᡪᡭᡬ", "ᡳ", "ᡭ", "ᡭᡦ"];
var nArr = ["ᡯ", "", "", "ᡯ", "", "", "ᡪ", "ᡱ", "", "ᡧ", "ᡰ", ""];
var bArr = ["ᡳ", "", "", "ᡳ", "ᡴ", "", "ᡳ", "ᡴ", "", "ᡲ", "", ""];
var pArr = ["ᡶ", "", "", "ᡶ", "ᡷ", "", "ᡶ", "ᡷ", "", "ᡵ", "", ""];
var hArr = ["ᡸ", "", "", "ᡸ", "ᢊ", "ᢋ", "ᡪᡪ", "ᢊ", "ᢋ", "ᢇ", "ᢇ", ""];
var gArr = ["ᢈ", "", "ᡪᡪ", "ᢈ", "ᢊ", "ᢋ", "ᡱᡱ", "ᢊ", "ᢋ", "ᢇ", "ᢉ", "ᡬᡨ"];
var mArr = ["ᢌ", "", "", "ᢌ", "", "", "ᢎ", "", "", "ᢍ", "", ""];
var lArr = ["ᢏ", "", "", "ᢏ", "", "", "ᢑ", "", "", "ᢐ", "", ""];
var sArr = ["ᢔ", "", "", "ᢔ", "", "", "ᢔ", "", "", "ᢓ", "", ""];
var xArr = ["ᢗ", "", "", "ᢗ", "", "", "ᢗ", "", "", "ᢖ", "", ""];
var tArr = ["ᢘ", "", "", "ᢘ", "", "", "ᢙ", "ᢘ", "", "ᢘᡦ", "", ""];
var dArr = ["ᢙ", "", "", "ᢘ", "", "", "ᡭᡪ", "ᢙ", "", "ᡭᡧ", "ᢙᡦ", ""];
var cArr = ["ᢚ", "", "", "ᢚ", "", "", "ᢚ", "", "", "ᢚᡦ", "", ""];
var jArr = ["ᡬ", "", "", "ᡬ", "", "", "ᢛ", "", "", "ᢛᡦ", "", ""];
var yArr = ["ᢜ", "", "", "ᢜ", "", "", "ᢜ", "", "", "ᡫ", "", ""];
var rArr = ["ᢞ", "", "", "ᢞ", "", "", "ᢞ", "", "", "ᢝ", "", ""];
var wArr = ["ᢟ", "", "", "ᢟ", "", "", "ᢟ", "", "", "ᢟᡦ", "", ""];
var fArr = ["ᢡ", "", "", "ᢡ", "ᢢ", "", "ᢡ", "ᢢ", "", "ᢠ", "", ""];
var kArr = ["ᢤ", "", "", "ᢤ", "ᢥ", "", "ᢤ", "ᢥ", "", "ᢣ", "", ""];
var qArr = ["ᢚ", "", "", "ᢚ", "", "", "ᢚ", "", "", "ᢚᡦ", "", ""];
var zArr = ["ᢧ", "", "", "ᢧ", "", "", "ᢧ", "", "", "ᢧᡦ", "", ""];
var vArr = ["ᡥᡭ", "ᡥᡭ", "", "ᡥᡭ", "", "", "ᡭ", "ᡪᡭ", "", "ᡳ", "ᡭ", ""];
var AArr = ["ᡥᡧ", "", "", "ᡪᡪ", "", "", "ᡪᡪ", "", "", "ᡧ", "", ""];
var EArr = ["ᢟ", "", "", "ᢟ", "", "", "ᢟ", "", "", "ᢟᡦ", "", ""];
var IArr = ["ᡫ", "", "", "ᡥᡬ", "", "", "ᡬ", "ᡬᡬ", "ᡪᡬ", "ᡫ", "ᡬᡦ", ""];
var OArr = [
  "ᡥᡭ",
  "ᡥᡭ",
  "",
  "ᡥᡭ",
  "",
  "",
  "ᡭ",
  "ᡪᡭ",
  "",
  "ᡭ",
  "ᡭ",
  ""
]; //2021.3.13
var UArr = [
  "ᡥᡭᡦ",
  "",
  "",
  "ᡥᡭᡬ",
  "",
  "",
  "ᡭᡬ",
  "",
  "",
  "ᡭᡦ",
  "",
  ""
]; //2021.3.9
var NArr = ["ᡯ", "", "", "ᡯ", "", "", "ᡱ", "ᡪ", "", "ᡧ", "ᡰ", ""]; //2021.3.9
var BArr = ["ᡳ", "", "", "ᡳ", "ᡴ", "", "ᡳ", "ᡴ", "", "ᡲ", "", ""];
var PArr = ["ᡶ", "", "", "ᡶ", "ᡷ", "", "ᡶ", "ᡷ", "", "ᡵ", "", ""];
var HArr = ["ᡸ", "", "", "ᡸ", "ᢊ", "ᢋ", "ᡪᡪ", "ᢊ", "ᢋ", "ᢇ", "ᢇ", ""];
var GArr = ["ᢈ", "", "ᡪᡪ", "ᢈ", "ᢊ", "ᢋ", "ᡱᡱ", "ᢊ", "ᢋ", "ᢇ", "ᢉ", "ᡬᡨ"];
var MArr = ["ᢌ", "", "", "ᢌ", "", "", "ᢎ", "", "", "ᢍ", "", ""];
var LArr = ["ᢏᢨ", "", "", "ᢏᢨ", "", "", "ᢑᢨ", "", "", "ᢑᢨᡦ", "", ""];
var SArr = ["ᢔ", "", "", "ᢔ", "", "", "ᢔ", "", "", "ᢓ", "", ""];
var XArr = ["ᢗ", "", "", "ᢗ", "", "", "ᢗ", "", "", "ᢖ", "", ""];
var TArr = ["ᢙ", "", "", "ᢙ", "", "", "ᢙ", "ᢘ", "", "ᢙᡦ", "", ""]; //2021.3.9
var DArr = ["ᢘ", "", "", "ᢙ", "", "", "ᢘ", "", "", "ᢘᡦ", "", ""];
var CArr = ["ᢦ", "", "", "ᢦ", "", "", "ᢦ", "", "", "ᢦᡦ", "", ""];
var JArr = ["ᡬ", "", "", "ᡬ", "", "", "ᢛ", "", "", "ᢛᡦ", "", ""];
var YArr = ["ᢜ", "", "", "ᢜ", "", "", "ᢜ", "", "", "ᡫ", "", ""];
var RArr = ["ᢞ", "", "", "ᢞ", "", "", "ᢞ", "", "", "ᢝ", "", ""];
var WArr = ["ᢟ", "", "", "ᢟ", "", "", "ᢟ", "", "", "ᢟᡦ", "", ""];
var FArr = ["ᢡ", "", "", "ᢡ", "ᢢ", "", "ᢡ", "ᢢ", "", "ᢠ", "", ""];
var KArr = ["ᢤ", "", "", "ᢤ", "ᢥ", "", "ᢤ", "ᢥ", "", "ᢣ", "", ""];
var QArr = ["ᢦ", "", "", "ᢦ", "", "", "", "", "", "ᢦᡦ", "", ""];
var ZArr = ["ᢨ", "", "", "ᢨ", "", "", "ᢨ", "", "", "ᢨᡦ", "", ""];
var VArr = ["ᡭ", "ᡭ", "", "ᡭ", "", "", "ᡭ", "ᡪᡭ", "", "ᡳ", "ᡭ", ""];

class ZCode {
  var qArray = [];
  var vArray = [];
  var teinIlgal = new Map();
  var databases = new Map();
  var wordMap = new Map();

  var m_tein1 = [];
  var m_tein2 = [];
  var m_tein3 = [];
  var m_tein4 = [];
  var m_tein5 = [];
  var m_tein6 = [];

  ZCode() {
    qArray.add("ᡳᡪᢝ");
    qArray.add("ᡳᡪᢝ");
    qArray.add("ᡬᡬᡪᢝ");
    qArray.add("ᢘᡪᡫ");
    qArray.add("ᡳᡪᡧ");
    qArray.add("ᡬᡬᡪᡧ");
    qArray.add("ᡭᡭᡧ");
    qArray.add("ᢘᡪᡱᡱᡪᡧ");
    qArray.add("ᢘᡪᢊᡪᡧ");
    qArray.add("ᢙᡪᡱᡱᡪᡧ");
    qArray.add("ᢙᡪᢊᡪᡧ");

    vArray.add("ᡬᡬᡧ");
    vArray.add("ᡭᡧ");
    vArray.add("ᡳ");
    vArray.add("ᢘᡳ");
    vArray.add("ᢙᡳ");
    vArray.add("ᡬᡫ");
    vArray.add("ᡫ");
    vArray.add("ᡥᢚᡧ");

    teinIlgal["q"] = qArray;
    teinIlgal["v"] = vArray;

    databases["aav"] = "ᡥᡪᡴᡭ";
    databases["america"] = "ᡥᡪᢎᢟᢞᡬᢤᡪᡨ";
    databases["ch"] = "ᡭᡭ";
    databases["chi"] = "ᡭᡭᡫ";
    databases["cihola"] = "ᢚᡬᡪᡪᡭᢑᡧ";
    databases["cino"] = "ᢚᡬᡱᡳᡨ";
    databases["do"] = "ᢙᡳ";
    databases["du"] = "ᢙᡳ";
    databases["eej"] = "ᡥᢛᡫ";
    databases["eyer"] = "ᡬᡬᡪᢝ";
    databases["europe"] = "ᡥᢟᡭᡬᢞᡭᡶᡪᡨ";
    databases["eyen"] = "ᡬᡬᡪᡧ";
    databases["gowa"] = "ᢈᡭᡳᡨ";
    databases["hebei"] = "ᡥᢨᢟᡳᢟᡫ";
    databases["in"] = "ᡬᡬᡧ";
    databases["kino"] = "ᢤᡬᡱᡭ";
    databases["kod"] = "ᢥᡭᢙᡦ";
    databases["mongo"] = "ᢌᡭᡪᢊᡱᡱᡭᢐ";
    databases["no"] = "ᡳ";
    databases["on"] = "ᡭᡧ";
    databases["oo"] = "ᡭᡳ";
    databases["radio"] = "ᢞᡪᢙᡬᡭ";
    databases["sh"] = "ᢗ";
    databases["shi"] = "ᢗᡫ";
    databases["su"] = "ᢔᡭᡦ";
    databases["tatar"] = "ᢘᡪᢘᡪᢝ";
    databases["yunikod"] = "ᢜᡭᡬᡱᡬᢥᡭᢙᡦ";
    databases["zh"] = "ᢨ";
    databases["zhi"] = "ᢨᡫ";
    databases["english"] = "ᡥᡪᡪᢊᢊᢑᡫ";
    databases["england"] = "ᡥᡪᡪᢊᢊᢑᡫ";
    databases["degen"] = "ᢙᡪᢊᡪᡧ";
    databases["deng"] = "ᢙᢟᡪᡬᡨ";
    databases["dan"] = "ᢙᡪᡧ";
    databases["den"] = "ᢙᡪᡧ";
    databases["din"] = "ᢙᡬᡧ";
    databases["o"] = "ᡥᡭ";
    databases["u"] = "ᡥᡭᡬ";
    databases["i"] = "ᡥᡫ";
    databases["naima"] = "ᡯᡪᡬᢎᡧ";
    databases["dung"] = "ᢙᡭᡬᡪᡬᡨ";
    databases["don"] = "ᢙᡭᡧ";
    databases["dungsigor"] = "ᢙᡭᡬᡪᢊᢔᡬᡱᡱᡭᢝ";
    databases["agola"] = "ᡥᡪᡱᡱᡭᢑᡧ";
    databases["sig"] = "ᢔᡬᢇ";
    databases["tig"] = "ᢘᡬᢇ";
    databases["tere"] = "ᢘᡪᢞᡧ";

    wordMap["a"] = aArr;
    wordMap["e"] = eArr;
    wordMap["i"] = iArr;
    wordMap["o"] = oArr;
    wordMap["u"] = uArr;
    wordMap["n"] = nArr;
    wordMap["b"] = bArr;
    wordMap["p"] = pArr;
    wordMap["h"] = hArr;
    wordMap["g"] = gArr;
    wordMap["m"] = mArr;
    wordMap["l"] = lArr;
    wordMap["s"] = sArr;
    wordMap["x"] = xArr;
    wordMap["t"] = tArr;
    wordMap["d"] = dArr;
    wordMap["c"] = cArr;
    wordMap["j"] = jArr;
    wordMap["y"] = yArr;
    wordMap["r"] = rArr;
    wordMap["w"] = wArr;
    wordMap["f"] = fArr;
    wordMap["k"] = kArr;
    wordMap["q"] = qArr;
    wordMap["z"] = zArr;
    wordMap["v"] = vArr;

    wordMap["A"] = AArr;
    wordMap["E"] = eArr;
    wordMap["I"] = iArr;
    wordMap["O"] = OArr; //2021.3.13
    wordMap["U"] = UArr;
    wordMap["N"] = nArr;
    wordMap["B"] = bArr;
    wordMap["P"] = pArr;
    wordMap["H"] = hArr;
    wordMap["G"] = gArr;
    wordMap["M"] = mArr;
    wordMap["L"] = LArr;
    wordMap["S"] = sArr;
    wordMap["X"] = xArr;
    wordMap["T"] = TArr;
    wordMap["D"] = DArr;
    wordMap["C"] = CArr;
    wordMap["J"] = jArr;
    wordMap["Y"] = yArr;
    wordMap["R"] = rArr;
    wordMap["W"] = wArr;
    wordMap["F"] = fArr;
    wordMap["K"] = kArr;
    wordMap["Q"] = qArr;
    wordMap["Z"] = ZArr;
    wordMap["V"] = vArr;

    m_tein1.add(dagbr['yin']);
    m_tein1.add(dagbr['yi']);
    m_tein1.add(dagbr['bar']);
    m_tein1.add(dagbr['ban']);
    m_tein1.add(dagbr['do']);
    m_tein1.add(dagbr['dor']);
    m_tein1.add(dagbr['aca']);
    m_tein1.add(dagbr['tai']);
    m_tein1.add(dagbr['dagan']);
    m_tein1.add(dagbr['loga']);

    m_tein2.add(dagbr['yin']);
    m_tein2.add(dagbr['yi']);
    m_tein2.add(dagbr['bar']);
    m_tein2.add(dagbr['iyan']);
    m_tein2.add(dagbr['do']);
    m_tein2.add(dagbr['dor']);
    m_tein2.add(dagbr['aca']);
    m_tein2.add(dagbr['tai']);
    m_tein2.add(dagbr['dagan']);
    m_tein2.add(dagbr['luge']);

    m_tein3.add(dagbr['on']);
    m_tein3.add(dagbr['i']);
    m_tein3.add(dagbr['iyar']);
    m_tein3.add(dagbr['aca']);
    m_tein3.add(dagbr['tai']);

    m_tein4.add(dagbr['o']);
    m_tein4.add(dagbr['do']);
    m_tein4.add(dagbr['dor']);
    m_tein4.add(dagbr['aca']);
    m_tein4.add(dagbr['tai']);

    m_tein5.add(dagbr['on']);
    m_tein5.add(dagbr['i']);
    m_tein5.add(dagbr['iyar']);
    m_tein5.add(dagbr['do']);
    m_tein5.add(dagbr['dor']);
    m_tein5.add(dagbr['aca']);
    m_tein5.add(dagbr['tai']);

    m_tein6.add(dagbr['o']);
    m_tein6.add(dagbr['i']);
    m_tein6.add(dagbr['iyar']);
    m_tein6.add(dagbr['to']);
    m_tein6.add(dagbr['tor']);
    m_tein6.add(dagbr['aca']);
    m_tein6.add(dagbr['tai']);
  }

  void PrintHello() {
    print("Hello ZCode");
  }

  Map FirstAndLast(String latin) {
    var ret = new Map();
    String firstStr = latin.substring(0, 1);
    String secondStr = latin.substring(1, 2);
    String lastStr = latin.substring(latin.length - 1, latin.length);
    String prelastStr = latin.substring(latin.length - 2, latin.length - 1);
    String resultFirst = "";
    var resultLast = [];
    if (wordMap.containsKey(firstStr)) {
      resultFirst = wordMap[firstStr][3];
      String x = firstStr;

      //2020.3.13
      // solving b,p,k,f  before o,u
      if (x == "b" || x == "p" || x == "k" || x == "f") {
        String y = secondStr;
        if (y == "o" || y == "u" || y == "v" || y == "U") {
          resultFirst = wordMap[x][4];
        }
      }
      // solving h,g before e,i,w
      if (x == "h" || x == "g") {
        String y = secondStr;
        if (y == "e" || y == "i" || y == "w") {
          resultFirst = wordMap[x][4];
        }
      }
      //2021.3.13
      // solving h,g before u
      if (x == "h" || x == "g") {
        String y = secondStr;
        if (y == "u" || y == "U") {
          resultFirst = wordMap[x][5];
        }
      }

      //solving last letter;
      if (wordMap.containsKey(lastStr)) {
        String pTemp = wordMap[lastStr][9];
        if (pTemp.length > 0) {
          //resultLast = pTemp;
          resultLast.add(pTemp);
        }
      }
      x = prelastStr;
      // solving a after b,p,k,f    test haha  baba
      if (x == "b" || x == "p" || x == "k" || x == "f") {
        String y = lastStr;
        if (y == "a") {
          //resultLast = wordMap[y][10];

          if (resultLast.length > 0) {
            resultLast.clear();
          }
          resultLast.add(wordMap[y][10]);
        }
      }
      // solving e after h,g
      if (x == "h" || x == "g") {
        String y = lastStr;
        if (y == "e") {
          //resultLast = wordMap[y][9];
          if (resultLast.length > 0) {
            resultLast.clear();
          }
          resultLast.add(wordMap[y][9]);
        }
      }
      // solving i after b,p,k,f,h,g
      if (x == "b" ||
          x == "p" ||
          x == "k" ||
          x == "f" ||
          x == "h" ||
          x == "g") {
        String y = lastStr;
        if (y == "i") {
          //resultLast = wordMap[y][10];
          if (resultLast.length > 0) {
            resultLast.clear();
          }
          resultLast.add(wordMap[y][10]);
        }
      }
      // solving o after b,p,k,f
      if (x == "b" || x == "p" || x == "k" || x == "f") {
        String y = lastStr;
        if (y == "o" || y == "v") {
          //resultLast = wordMap[y][10];
          if (resultLast.length > 0) {
            resultLast.clear();
          }
          resultLast.add(wordMap[y][10]);
        }
      }
      // solving u after b,p,k,f,h,g
      if (x == "b" ||
          x == "p" ||
          x == "k" ||
          x == "f" ||
          x == "h" ||
          x == "g") {
        String y = lastStr;
        if (y == "u") {
          //resultLast = wordMap[y][10];
          if (resultLast.length > 0) {
            resultLast.clear();
          }
          resultLast.add(wordMap[y][10]);
        }
      }
      // solving g after i,e,u, U
      if (x == "i" || x == "e" || x == "u" || x == "U") {
        String y = lastStr;
        if (y == "g") {
          if (x == "i") {
            String temp;
            for (int j = 1; j < latin.length - 2; j++) {
              String z =
                  latin.substring(latin.length - 2 - j, latin.length - 1 - j);
              if (z == "a" || z == "o" || z == "v") {
                //resultLast = wordMap[y][9];
                temp = wordMap[y][9];
              }
            }
            if (resultLast.length > 0) {
              resultLast.clear();
            }
            resultLast.add(wordMap[y][9]);
          } else {
            //resultLast = wordMap[y][11];
            if (resultLast.length > 0) {
              resultLast.clear();
            }
            resultLast.add(wordMap[y][11]);
          }
        }
      }

      // solving g after n
      if (x == "n") {
        String y = lastStr;
        if (y == "g") {
          //resultLast = wordMap[y][11];
          if (resultLast.length > 0) {
            resultLast.clear();
          }
          resultLast.add(wordMap[y][11]);
        }
      }
      // solving a, e after n, m, l, y, r
      if (x == "n" || x == "m" || x == "l" || x == "y" || x == "r") {
        String y = lastStr;
        if (y == "a" || y == "e") {
          //resultLast = wordMap[y][11];
          if (resultLast.length > 0) {
            resultLast.clear();
          }
          resultLast.add(wordMap[y][11]);
        }
      }
      // solving e after c, v, z, q, d
      if (x == "c" || x == "v" || x == "z" || x == "q" || x == "d") {
        String y = lastStr;
        if (y == "e") {
          //resultLast = wordMap[y][10];
          if (resultLast.length > 0) {
            resultLast.clear();
          }
          resultLast.add(wordMap[y][10]);
        }
      }
      // solving a, after h, g
      if (x == "h" || x == "g") {
        String y = lastStr;
        if (y == "a") {
          //resultLast = wordMap[y][11];
          if (resultLast.length > 0) {
            resultLast.clear();
          }
          resultLast.add(wordMap[y][11]);
        }
      }
      // solving a, after n, m, h, g, for isolated na, ma, ha, ga
      if (x == "n" || x == "m" || x == "h" || x == "g") {
        String y = lastStr;
        if (y == "a") {
          if (2 == latin.length) {
            //resultLast = wordMap[y][9];
            if (resultLast.length > 0) {
              resultLast.clear();
            }
            resultLast.add(wordMap[y][9]);
          }
        }
      }
    }

    ret['first'] = resultFirst;
    ret['last'] = resultLast;

    return ret;
  }

  String Middle(String str) {
    String resultMid = "";
    String m = "";
    for (int i = 1; i < str.length - 1; i++) {
      String x = str.substring(i, i + 1);
      if (wordMap.containsKey(x)) {
        m = wordMap[x][6];

        //solving g after a or o
        String yy = str.substring(i - 1, i);
        if (yy == "a" || yy == "o" || yy == "v") {
          if (x == "g") {
            m = wordMap[x][2];
          }
        }
        //solving g not after a or o
        if (yy != "a" && yy != "o" && yy != "v") {
          if (x == "g") {
            m = wordMap[x][7];
          }
        }

        //solving g before a or o
        if (x == "g") {
          String y = str.substring(i + 1, i + 2);
          if (y == "a" || y == "o" || y == "v") {
            m = wordMap[x][6];
          }
        }

        //2021.3.9
        //solving n,d before egshig    a,e,i,o,u, U, A, E,
        if (x == "n" || x == "d") {
          String y = str.substring(i + 1, i + 2);
          if (y == "a" ||
              y == "e" ||
              y == "i" ||
              y == "o" ||
              y == "v" ||
              y == "u" ||
              y == "A" ||
              y == "E" ||
              y == "U") {
            m = wordMap[x][7];
          }
        }

        //2021.3.9
        //solving N,T before egshig    a,e,i,o,u, U, A, E,
        if (x == "N" || x == "T" || x == "D") {
          m = wordMap[x][7];
        }

        //2021.3.13
        // solving b,p,k,f  before o,u
        if (x == "b" || x == "p" || x == "k" || x == "f") {
          String y = str.substring(i + 1, i + 2);
          if (y == "o" || y == "u" || y == "v" || y == "U") {
            m = wordMap[x][7];
          }
        }

        //solving h, g before e, i, w
        if (x == "h" || x == "g") {
          String y = str.substring(i + 1, i + 2);
          if (y == "e" || y == "i" || y == "w") {
            m = wordMap[x][7];
          }
        }

        //solving h, g before u
        if (x == "h" || x == "g") {
          String y = str.substring(i + 1, i + 2);
          if (y == "u") {
            m = wordMap[x][8];
          }
        }

        //solving u for second position,    test bumbur  bum
        if (x == "u" && i == 1) {
          m = wordMap[x][7];
        }

        //solving i after a, e, o
        if (x == "i") {
          String y = str.substring(i - 1, i);
          if (y == "a" || y == "e" || y == "o" || y == "v") {
            m = wordMap[x][7];
          }
        }

        //solving g after Positive or Negative i traceback and  not before a,e,i, o, u      test yabogsan uggugsen jarlig jerlig baigal
        if (x == "g") {
          String y = str.substring(i - 1, i);
          String w = str.substring(i + 1, i + 2);
          if (y == "i") {
            if (w != "a" &&
                w != "e" &&
                w != "i" &&
                w != "o" &&
                y != "v" &&
                w != "u") {
              for (int j = 1; j <= (i); j++) {
                String z = str.substring(i + 1 - j, i + 2 - j);
                if (z == "a" || z == "o" || z == "v" || z == "A") {
                  m = wordMap[x][2];
                }
              }
            }
          }
        }

        //h, g before a , for second last letter
        if (x == "h" || x == "g") {
          String y = str.substring(i + 1, i + 2);
          if (y == "a") {
            if (i == str.length - 2) {
              m = wordMap[x][10];
            }
          }
        }

        //n before a, e, for second last letter      test yabona
        if (x == "n") {
          String y = str.substring(i + 1, i + 2);
          if (y == "a" || y == "e") {
            if (i == str.length - 2) {
              m = wordMap[x][10];
            }
          }
        }

        //m, L, y, r before a, e
        if (x == "m" || x == "l" || x == "y" || x == "r") {
          String y = str.substring(i + 1, i + 2);
          if (y == "a" || y == "e") {
            if (i == str.length - 2) {
              m = wordMap[x][9];
            }
          }
        }

        resultMid = resultMid + m;
      }
    }
    return resultMid;
  }

  int GetTeinClass(String latin) {
    int iRet = 0;

    String word = latin;

    while (true && word.length > 1) {
      int cLast = word.codeUnitAt(word.length - 1);
      int cPreLast = word.codeUnitAt(word.length - 2);

      if ((cPreLast >= 'a'.codeUnits.first &&
              cPreLast <= 'z'.codeUnits.first) ||
          (cPreLast >= 'A'.codeUnits.first &&
              cPreLast <= 'Z'.codeUnits.first)) {
        if (cLast == 'a'.codeUnits.first ||
            cLast == 'o'.codeUnits.first ||
            cLast == 'v'.codeUnits.first) {
          iRet = 1;
          break;
        } else if (cLast == 'e'.codeUnits.first ||
            cLast == 'i'.codeUnits.first ||
            cLast == 'u'.codeUnits.first) {
          iRet = 2;
          break;
        } else if (cLast == 'p'.codeUnits.first ||
            cLast == 'h'.codeUnits.first ||
            cLast == 'x'.codeUnits.first ||
            cLast == 't'.codeUnits.first ||
            cLast == 'c'.codeUnits.first ||
            cLast == 'j'.codeUnits.first ||
            cLast == 'y'.codeUnits.first ||
            cLast == 'w'.codeUnits.first ||
            cLast == 'f'.codeUnits.first ||
            cLast == 'k'.codeUnits.first ||
            cLast == 'q'.codeUnits.first ||
            cLast == 'z'.codeUnits.first) {
          iRet = 3;
          break;
        } else if (cLast == 'n'.codeUnits.first) {
          iRet = 4;
          break;
        } else if (cLast == 'n'.codeUnits.first &&
            cPreLast == 'g'.codeUnits.first) {
          iRet = 5;
          break;
        } else if (cLast == 'b'.codeUnits.first ||
            cLast == 'g'.codeUnits.first ||
            cLast == 'r'.codeUnits.first ||
            cLast == 'r'.codeUnits.first ||
            cLast == 's'.codeUnits.first ||
            cLast == 'd'.codeUnits.first) {
          iRet = 6;
          break;
        } else {
          break;
        }
      }

      break;
    }

    return iRet;
  }

  List ExeutePhrase(String preWordLatin) {
    var ret = [];
    int iTeinClass = GetTeinClass(preWordLatin);
    switch (iTeinClass) {
      case 1:
        ret = m_tein1;
        break;
      case 2:
        ret = m_tein2;
        break;
      case 3:
        ret = m_tein3;
        break;
      case 4:
        ret = m_tein4;
        break;
      case 5:
        ret = m_tein5;
        break;
      case 6:
        ret = m_tein6;
        break;
      default:
        break;
    }

    return ret;
  }

  List<String> GetEndsClass(String word) {
    List<String> newWords = [];
    //0:Unknown   1:ne 2:me 3:le 4:ye 5:re 6:wa  7:o-3,u-3
    int iRet = 0;

    if (word == oArr[0]) {
      //o
      newWords.add(eArr[3] + uArr[9]);
      newWords.add(oArr[9]);
      newWords.add(oArr[6]);
    } else if (word == eArr[3] + uArr[11]) {
      //u
      newWords.add(eArr[3] + uArr[9]);
      newWords.add(uArr[3]);
    } else if (word.length > 2) {
      //wchar_t cLast = word.c_str()[word.length - 1];
      //	wchar_t cPreLast = word.c_str()[word.length - 2];

      String scLast = word.substring(word.length - 1, word.length);
      String sPreLast = word.substring(word.length - 2, word.length - 1);
      String subWordPre = word.substring(0, word.length - 2);
      if (scLast == aArr[11]) {
        if (sPreLast == nArr[10]) {
          //na
          subWordPre += nArr[7] + aArr[9];
          iRet = 1;
        } else if (sPreLast == mArr[9]) {
          //ma
          subWordPre += mArr[6] + aArr[9];
          iRet = 2;
        } else if (sPreLast == lArr[9]) {
          //la
          subWordPre += lArr[6] + aArr[9];
          iRet = 3;
        } else if (sPreLast == yArr[9]) {
          //ya
          subWordPre += yArr[6] + aArr[9];
          iRet = 4;
        } else if (sPreLast == rArr[9]) {
          //ra
          subWordPre += rArr[6] + aArr[9];
          iRet = 5;
        }
      } else if (sPreLast == wArr[6] && scLast == aArr[9]) {
        //wa
        subWordPre += oArr[9] + aArr[11];
        iRet = 6;
      }

      if (iRet != 0) {
        newWords.add(subWordPre);
      }
    }

    return newWords;
  }

  List Excute(String latin) {
    var result = [];
    int wordLength = latin.length;
    String resultFirst = "";
    String resultMid = "";
    var resultLast = [];
    if (wordLength == 1 && wordMap.containsKey(latin)) {
      resultFirst = wordMap[latin][0];
    } else if (wordLength == 2) {
      var firstlast = FirstAndLast(latin);
      resultFirst = firstlast['first'];
      resultLast = firstlast['last'];
    } else {
      var firstlast = FirstAndLast(latin);
      resultFirst = firstlast['first'];
      resultLast = firstlast['last'];
      resultMid = Middle(latin);
    }

    if (resultLast.length > 0) {
      for (int i = 0; i < resultLast.length; i++) {
        result.add(resultFirst + resultMid + resultLast[i]);
      }
    } else {
      result.add(resultFirst);
    }

    return result;
  }

  //2021.3.9
  List<String> excuteEx(String latin) {
    List<String> result = [];
    var resWords = Excute(latin);
    for (int i = 0; i < resWords.length; i++) {
      if (resWords[i].length > 0) {
        result.add(resWords[i]);

        //ne me le ye re wa
        var newWord = GetEndsClass(resWords[i]);
        if (newWord.isNotEmpty) {
          result.addAll(newWord);
        }
      }
    }
    final teinYigal = dagbr[latin];
    if (teinYigal != null) {
      final trim = teinYigal.trim();
      result.remove(trim);
      result.insert(0, trim);
    }
    return result;
  }
}
