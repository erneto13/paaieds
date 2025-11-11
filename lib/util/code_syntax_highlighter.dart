import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart' show highlight, Node;
import 'package:flutter_markdown/flutter_markdown.dart';

class CodeSyntaxHighlighter extends SyntaxHighlighter {
  @override
  TextSpan format(String source) {
    final result = highlight.parse(source, language: 'javascript');
    return TextSpan(
      style: const TextStyle(fontFamily: 'monospace', color: Colors.black87),
      children: result.nodes?.map((node) {
        if (node.value != null) {
          return TextSpan(text: node.value, style: _colorFor(node.className));
        } else if (node.children != null) {
          return TextSpan(children: node.children!.map(formatNode).toList());
        }
        return const TextSpan();
      }).toList(),
    );
  }

  TextStyle? _colorFor(String? className) {
    switch (className) {
      case 'keyword':
        return const TextStyle(color: Colors.purple);
      case 'string':
        return const TextStyle(color: Colors.green);
      case 'number':
        return const TextStyle(color: Colors.blue);
      default:
        return const TextStyle(color: Colors.black87);
    }
  }

  TextSpan formatNode(Node node) => format(node.value ?? '');
}
