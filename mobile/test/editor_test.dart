import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_ai_coding_academy/features/code/python_controller.dart';

void main() {
  test('Python newline inserts indentation after a colon', () {
    final before = TextEditingValue(
      text: 'if True:',
      selection: const TextSelection.collapsed(offset: 8),
    );
    final after = TextEditingValue(
      text: 'if True:\n',
      selection: const TextSelection.collapsed(offset: 9),
    );
    final result = PythonIndentFormatter().formatEditUpdate(before, after);
    expect(result.text, 'if True:\n    ');
    expect(result.selection.baseOffset, 13);
  });
}
