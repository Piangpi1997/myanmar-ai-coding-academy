import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/generated/app_localizations.dart';
import 'python_controller.dart';

class PythonEditor extends StatelessWidget {
  const PythonEditor({
    super.key,
    required this.controller,
    required this.onChanged,
    this.fontSize = 15,
    this.enabled = true,
  });
  final PythonController controller;
  final ValueChanged<String> onChanged;
  final double fontSize;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final lines = controller.text.split('\n');
        return LayoutBuilder(
          builder: (context, constraints) {
            final longest = lines.fold<int>(
              0,
              (n, line) => math.max(n, line.length),
            );
            final width = math.max(
              constraints.maxWidth - 52,
              longest * fontSize * 0.65 + 40,
            );
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 16,
                      ),
                      child: Text(
                        List.generate(
                          lines.length,
                          (i) => '${i + 1}',
                        ).join('\n'),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: fontSize,
                          height: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: TextField(
                        controller: controller,
                        onChanged: onChanged,
                        enabled: enabled,
                        minLines: 10,
                        maxLines: null,
                        maxLength: 16000,
                        autocorrect: false,
                        enableSuggestions: false,
                        enableIMEPersonalizedLearning: false,
                        inputFormatters: [
                          PythonIndentFormatter(),
                          LengthLimitingTextInputFormatter(16000),
                        ],
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: fontSize,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          semanticCounterText: l.code,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
