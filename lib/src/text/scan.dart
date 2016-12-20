import 'dart:async';
import 'package:charcode/charcode.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';
import 'token.dart';
import 'token_type.dart';

final RegExp _COMMENT = new RegExp(r'{{--[^\n]*--}}');

final Map<Pattern, TokenType> _PATTERNS = {
  '@': TokenType.ARROBA,
  ',': TokenType.COMMA,
  '=': TokenType.EQUALS,
  '[': TokenType.LBRACKET,
  ']': TokenType.RBRACKET,
  '(': TokenType.LPAREN,
  ')': TokenType.RPAREN,
  '<': TokenType.LT,
  '>': TokenType.GT,
  '/': TokenType.SLASH,
  new RegExp(r'<!--[^!\n]*-->'): TokenType.HTML_COMMENT,
  'in': TokenType.IN,
  new RegExp(r'@{{[^}\n]*}}'): TokenType.CURLY_ESCAPED,
  new RegExp(r'{{[^}\n]*}}'): TokenType.ECHO,
  new RegExp(r'[0-9]+(\.[0-9]+)?'): TokenType.NUMBER,
  new RegExp(r'{!![^!\n]*!!}'): TokenType.UNESCAPED,
  new RegExp(r'"((\\")|([^"\n]))*"'): TokenType.STRING,
  new RegExp(r"'((\\')|([^'\n]))*'"): TokenType.STRING,
  new RegExp(r'([A-Za-z_]|$)([A-Za-z0-9_]|$)*'): TokenType.ID,
};

/// Asynchronously scans an input stream into Blade tokens.
class Scanner implements StreamTransformer<String, Token> {
  final Uri sourceUrl;

  Scanner(this.sourceUrl);

  @override
  Stream<Token> bind(Stream<String> stream) {
    var tokens = new StreamController<Token>();

    stream.listen((str) {
      var scanner = new StringScanner(str);
      List<int> buf = [];
      int line = 1, column = 1, chunkLine = 1, chunkCol = 1;

      void flushBuffer() {
        if (buf.isNotEmpty) {
          var str = new String.fromCharCodes(buf);
          buf.clear();
          var token = new Token(TokenType.CHUNK, str);
          var start = new SourceLocation(scanner.position,
              sourceUrl: sourceUrl, line: chunkLine, column: chunkCol);
          var end = new SourceLocation(scanner.position + str.length,
              sourceUrl: sourceUrl, line: line, column: column);
          chunkLine = line;
          chunkCol = column;
          tokens.add(token..span = new SourceSpan(start, end, token.text));
        }
      }

      while (!scanner.isDone) {
        if (scanner.scan(_COMMENT)) {
          column += scanner.lastMatch[0].length;
          continue;
        }

        List<Token> potential = [];

        _PATTERNS.forEach((pattern, type) {
          if (scanner.matches(pattern))
            potential.add(new Token(type, scanner.lastMatch[0]));
        });

        if (!potential.isEmpty) {
          flushBuffer();

          potential.sort((a, b) => a.text.length.compareTo(b.text.length));
          var token = potential.first;
          var nLines = token.text.allMatches('\n').length;
          var start = new SourceLocation(scanner.position,
              sourceUrl: sourceUrl, line: line, column: column);
          var end = new SourceLocation(scanner.position + token.text.length,
              sourceUrl: sourceUrl,
              line: line + nLines,
              column: column + token.text.length);
          tokens.add(token..span = new SourceSpan(start, end, token.text));
          line += nLines;
          column += token.text.length;
          scanner.position += token.text.length;
        } else {
          var ch = scanner.readChar();
          buf.add(ch);
          column++;

          if (ch == $lf) {
            line++;
            column = 1;
          }
        }
      }

      flushBuffer();
    }, onDone: tokens.close);

    return tokens.stream;
  }
}
