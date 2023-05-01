import 'package:climbing_diary/interfaces/grading_system.dart';

class Grade{
  static const List<List<String>> translationTable =
  [
    // USA-YDS, UK-Tech, UK-Adj, French, UIAA, Australien, Sachsen, Skandinavien, Brasilien, Fb
    ["5.1",   "3",  "VD",  "1",   "I",     "11", "I",     "1",   "Isup",   "1"],
    ["5.1",   "3",  "VD",  "2",   "II",    "11", "II",    "2",   "II",     "1"],
    ["5.1",   "3",  "VD",  "3",   "III",   "12", "III",   "3",   "IIsup",  "2"],
    ["5.1",   "3",  "VD",  "3",   "III+",  "12", "",      "3+",  "",       "2"],
    ["5.2",   "4a", "VD",  "4a",  "IV-",   "12", "IV",    "4-",  "III",    "3"],
    ["5.3",   "4a", "S",   "4b",  "IV",    "12", "IV",    "4",   "IIIsup", "3"],
    ["5.4",   "4a", "S",   "4c",  "IV+",   "12", "V",     "4+",  "III",    "3"],
    ["5.6",   "4a", "S",   "5a",  "V−",    "13", "V",     "5−",  "IIIsup", "3"],
    ["5.7",   "4b", "HS",  "5a",  "V",     "14", "VI",    "5",   "IV",     "4a"],
    ["5.7",   "4c", "HS",  "5b",  "V+",    "15", "VIIa",  "5",   "IV",     "4a"],
    ["5.8",   "4c", "VS",  "5b",  "VI-",   "16", "VIIa",  "5+",  "IVsup",  "4a"],
    ["5.9",   "5a", "HVS", "5c",  "VI",    "17", "VIIb",  "5+",  "V",      "4b"],
    ["5.10a", "5a", "E1",  "6a",  "VI+",   "18", "VIIc",  "6-",  "Vsup",   "4b"],
    ["5.10b", "5b", "E1",  "6a+", "VII-",  "19", "VIIIa", "6-",  "VI",     "4b"],
    ["5.10c", "5b", "E2",  "6b",  "VII",   "20", "VIIIb", "6",   "VI",     "4b"],
    ["5.10d", "5c", "E2",  "6b+", "VII+",  "21", "VIIIc", "6",   "VIsup",  "4c"],
    ["5.11a", "5c", "E3",  "6c",  "VII+",  "22", "VIIIc", "6+",  "VIIa",   "5a"],
    ["5.11b", "5c", "E3",  "6c+", "VIII-", "23", "IXa",   "6+",  "VIIa",   "5a"],
    ["5.11c", "6a", "E4",  "7a",  "VIII",  "24", "IXb",   "7-",  "VIIb",   "5b"],
    ["5.11d", "6a", "E4",  "7a+", "VIII+", "25", "IXc",   "7",   "VIIc",   "5c"],
    ["5.12a", "6a", "E5",  "7b",  "VIII+", "26", "IXc",   "7+",  "VIIIa",  "6a"],
    ["5.12b", "6b", "E5",  "7b+", "IX-",   "26", "Xa",    "8-",  "VIIIb",  "6b"],
    ["5.12c", "6b", "E6",  "7c",  "IX",    "27", "Xb",    "8",   "VIIIc",  "6c"],
    ["5.12d", "6c", "E6",  "7c+", "IX+",   "28", "Xc",    "8+",  "IXa",    "7a"],
    ["5.13a", "6c", "E7",  "8a",  "IX+",   "29", "Xc",    "9-",  "IXb",    "7a+"],
    ["5.13b", "6c", "E7",  "8a",  "X-",    "29", "Xc",    "9",   "IXc",    "7b"],
    ["5.13c", "7a", "E8",  "8a+", "X-",    "30", "XIa",   "9+",  "Xa",     "7b+"],
    ["5.13c", "7a", "E8",  "8a+", "X-",    "30", "XIa",   "9+",  "Xa",     "7c"],
    ["5.13d", "7a", "E9",  "8b",  "X",     "31", "XIb",   "10-", "Xb",     "7c+"],
    ["5.14a", "7a", "E9",  "8b+", "X+",    "32", "XIc",   "10",  "Xc",     "8a"],
    ["5.14b", "7b", "E10", "8c",  "XI-",   "33", "XIIa",  "10+", "XIa",    "8a+"],
    ["5.14c", "7b", "E11", "8c+", "XI-",   "34", "XIIa",  "11-", "XIa",    "8b"],
    ["5.14d", "7c", "E12", "9a",  "XI",    "35", "XIIb",  "11",  "XIa",    "8b+"],
    ["5.14d", "7c", "E12", "9a",  "XI",    "35", "XIIb",  "11",  "XIa",    "8c"],
    ["5.15a", "7c", "E12", "9a+", "XI+",   "35", "XIIb",  "11+", "XIa",    "8c+"],
    ["5.15a", "7c", "E12", "9a+", "XI+",   "35", "XIIb",  "11+", "XIa",    "8c+"],
    ["5.15b", "7c", "E12", "9b",  "XII-",  "35", "XIIb",  "11+", "XIa",    "8c+"],
    ["5.15c", "7c", "E12", "9b+", "XII-",  "35", "XIIb",  "11+", "XIa",    "9a"],
    ["5.15d", "7c", "E12", "9c",  "XII",   "35", "XIIb",  "11+", "XIa",    "9a"],
  ];

  static String translate(GradingSystem gs1, GradingSystem gs2, String grade){
    if (gs1 == gs2){
      return grade;
    }
    List<String> col1 = translationTable[gs1.index];
    int index = col1.indexOf(grade);
    return translationTable[gs2.index][index];
  }
}