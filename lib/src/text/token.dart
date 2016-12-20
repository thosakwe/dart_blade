import 'package:source_span/source_span.dart';
import 'token_type.dart';

class Token {
  final TokenType type;
  final String text;
  SourceSpan span;

  Token(this.type, this.text, {this.span});

  @override
  String toString() =>
      '${span.start.line}:${span.start.column} "$text" -> $type';
}