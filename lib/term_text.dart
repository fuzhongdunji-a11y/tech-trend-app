import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'models.dart';

/// 本文中の専門用語を検出して点線下線＋タップ可能にし、
/// タップで説明ダイアログを出すテキスト。
class TermText extends StatelessWidget {
  final String text;
  final List<TermItem> terms;
  final TextStyle? style;

  const TermText({super.key, required this.text, required this.terms, this.style});

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final valid = terms
        .where((t) => t.term.isNotEmpty && text.contains(t.term))
        .toList()
      ..sort((a, b) => b.term.length.compareTo(a.term.length));
    if (valid.isEmpty) {
      return Text(text, style: base);
    }
    final spans = <InlineSpan>[];
    var rest = text;
    while (rest.isNotEmpty) {
      var bestIdx = -1;
      TermItem? best;
      for (final t in valid) {
        final i = rest.indexOf(t.term);
        if (i >= 0 &&
            (bestIdx < 0 ||
                i < bestIdx ||
                (i == bestIdx && t.term.length > best!.term.length))) {
          bestIdx = i;
          best = t;
        }
      }
      if (best == null) {
        spans.add(TextSpan(text: rest));
        break;
      }
      if (bestIdx > 0) {
        spans.add(TextSpan(text: rest.substring(0, bestIdx)));
      }
      final term = best;
      spans.add(TextSpan(
        text: term.term,
        style: base.copyWith(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _showExplanation(context, term),
      ));
      rest = rest.substring(bestIdx + term.term.length);
    }
    return Text.rich(TextSpan(style: base, children: spans));
  }

  void _showExplanation(BuildContext context, TermItem term) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(term.term),
        content: Text(term.explanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
