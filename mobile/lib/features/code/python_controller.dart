import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PythonController extends TextEditingController {
  static final tokens = RegExp(
    r'''#[^\n]*|"[^"\n]*"|'[^'\n]*'|\b(?:def|return|if|else|elif|for|while|in|import|from|class|try|except|with|as|True|False|None|print|input)\b|\b\d+(?:\.\d+)?\b''',
  );
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (withComposing &&
        value.composing.isValid &&
        !value.composing.isCollapsed) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final spans = <TextSpan>[];
    var end = 0;
    for (final match in tokens.allMatches(text)) {
      spans.add(TextSpan(text: text.substring(end, match.start)));
      final token = match.group(0)!;
      final color = token.startsWith('#')
          ? Colors.grey
          : token.startsWith('"') || token.startsWith("'")
          ? const Color(0xFF27D9A0)
          : const Color(0xFFAB97FF);
      spans.add(
        TextSpan(
          text: token,
          style: TextStyle(color: color),
        ),
      );
      end = match.end;
    }
    spans.add(TextSpan(text: text.substring(end)));
    return TextSpan(style: style, children: spans);
  }
}

class PythonIndentFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursor = newValue.selection.baseOffset;
    if (!oldValue.selection.isCollapsed ||
        cursor < 1 ||
        newValue.text.length != oldValue.text.length + 1 ||
        newValue.text[cursor - 1] != '\n') {
      return newValue;
    }
    final previous = newValue.text.substring(0, cursor - 1).split('\n').last;
    final indent =
        RegExp(r'^ *').firstMatch(previous)!.group(0)! +
        (previous.trimRight().endsWith(':') ? '    ' : '');
    return newValue.copyWith(
      text: newValue.text.replaceRange(cursor, cursor, indent),
      selection: TextSelection.collapsed(offset: cursor + indent.length),
      composing: TextRange.empty,
    );
  }
}
