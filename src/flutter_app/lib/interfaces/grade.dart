import 'package:climbing_diary/interfaces/grading_system.dart';

class Grade{
  final String grade;
  final GradingSystem system;

  const Grade({
    required this.grade,
    required this.system,
  });

  static const List<List<String>> translationTable =
  [
    ['5.1', '5.1', '5.1', '5.1', '5.2', '5.3', '5.4', '5.6', '5.7', '5.7', '5.8', '5.9', '5.10a', '5.10b', '5.10c', '5.10d', '5.11a', '5.11b', '5.11c', '5.11d', '5.12a', '5.12b', '5.12c', '5.12d', '5.13a', '5.13b', '5.13c', '5.13c', '5.13d', '5.14a', '5.14b', '5.14c', '5.14d', '5.14d', '5.15a', '5.15a', '5.15b', '5.15c', '5.15d'], // USA-YDS
    ['3', '3', '3', '3', '4a', '4a', '4a', '4a', '4b', '4c', '4c', '5a', '5a', '5b', '5b', '5c', '5c', '5c', '6a', '6a', '6a', '6b', '6b', '6c', '6c', '6c', '7a', '7a', '7a', '7a', '7b', '7b', '7c', '7c', '7c', '7c', '7c', '7c', '7c'], // UK-Tech
    ['VD', 'VD', 'VD', 'VD', 'VD', 'S', 'S', 'S', 'HS', 'HS', 'VS', 'HVS', 'E1', 'E1', 'E2', 'E2', 'E3', 'E3', 'E4', 'E4', 'E5', 'E5', 'E6', 'E6', 'E7', 'E7', 'E8', 'E8', 'E9', 'E9', 'E10', 'E11', 'E12', 'E12', 'E12', 'E12', 'E12', 'E12', 'E12'], // UK-Adj
    ['1', '2', '3', '3', '4a', '4b', '4c', '5a', '5a', '5b', '5b', '5c', '6a', '6a+', '6b''6b+', '6c', '6c+', '7a', '7a+', '7b', '7b+', '7c', '7c+', '8a', '8a', '8a+', '8a+''8b', '8b+', '8c', '8c+', '9a', '9a', '9a+', '9a+', '9b', '9b+', '9c'], // French
    ['I', 'II', 'III', 'III+', 'IV-', 'IV', 'IV+', 'V−', 'V', 'V+', 'VI-', 'VI', 'VI+''VII-', 'VII', 'VII+', 'VII+', 'VIII-', 'VIII', 'VIII+', 'VIII+', 'IX-', 'IX''IX+', 'IX+', 'X-', 'X-', 'X-', 'X', 'X+', 'XI-', 'XI-', 'XI', 'XI', 'XI+', 'XI+''XII-', 'XII-', 'XII'], // UIAA
    ['11', '11', '12', '12', '12', '12', '12', '13', '14', '15', '16', '17', '18', '19''20', '21', '22', '23', '24', '25', '26', '26', '27', '28', '29', '29', '30', '30''31', '32', '33', '34', '35', '35', '35', '35', '35', '35', '35'], // Australien
    ['I', 'II', 'III', '', 'IV', 'IV', 'V', 'V', 'VI', 'VIIa', 'VIIa', 'VIIb', 'VIIc''VIIIa', 'VIIIb', 'VIIIc', 'VIIIc', 'IXa', 'IXb', 'IXc', 'IXc', 'Xa', 'Xb', 'Xc''Xc', 'Xc', 'XIa', 'XIa', 'XIb', 'XIc', 'XIIa', 'XIIa', 'XIIb', 'XIIb', 'XIIb''XIIb', 'XIIb', 'XIIb', 'XIIb'], // Sachsen
    ['1', '2', '3', '3+', '4-', '4', '4+', '5−', '5', '5', '5+', '5+', '6-', '6-', '6', '6''6+', '6+', '7-', '7', '7+', '8-', '8', '8+', '9-', '9', '9+', '9+', '10-', '10''10+', '11-', '11', '11', '11+', '11+', '11+', '11+', '11+'], // Skandinavien
    ['Isup', 'II', 'IIsup', '', 'III', 'IIIsup', 'III', 'IIIsup', 'IV', 'IV', 'IVsup''V', 'Vsup', 'VI', 'VI', 'VIsup', 'VIIa', 'VIIa', 'VIIb', 'VIIc', 'VIIIa''VIIIb', 'VIIIc', 'IXa', 'IXb', 'IXc', 'Xa', 'Xa', 'Xb', 'Xc', 'XIa', 'XIa', 'XIa''XIa', 'XIa', 'XIa', 'XIa', 'XIa', 'XIa'], // Brasilien
    ['1', '1', '2', '2', '3', '3', '3', '3', '4a', '4a', '4a', '4b', '4b', '4b', '4b', '4c''5a', '5a', '5b', '5c', '6a', '6b', '6c', '7a', '7a+', '7b', '7b+', '7c', '7c+''8a', '8a+', '8b', '8b+', '8c', '8c+', '8c+', '8c+', '9a', '9a'], //Fb
  ];

  Grade translate(GradingSystem gs){
    if (system == gs){
      return this;
    }
    List<String> col1 = translationTable[system.index];
    int index = col1.indexOf(grade);
    if (index == -1){
      return Grade(grade: col1[0], system: gs);
    }
    return Grade(grade: translationTable[gs.index][index], system: gs);
  }

  Grade operator +(Grade other){
    List<String> col1 = translationTable[system.index];
    int index = col1.indexOf(grade);
    List<String> col2 = translationTable[other.system.index];
    int otherIndex = col2.indexOf(other.grade);
    Grade result = index > otherIndex ? this : other;
    return result.translate(GradingSystem.french);
  }

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      grade: json['grade'],
      system: GradingSystem.values[json['system']]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grade': grade,
      'system': system.index,
    };
  }
}