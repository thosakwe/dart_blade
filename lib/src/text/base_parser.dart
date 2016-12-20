import 'package:source_span/source_span.dart';
import 'syntax_error.dart';
import 'token.dart';
import 'token_type.dart';

/// A base parser that traverses a list of tokens.
class BaseParser {
  int _index = -1;
  SourceLocation _location;

  /// The tokens, scanned from source code, that are being parsed.
  final List<Token> tokens;

  BaseParser(this.tokens);

  /// Returns the [Token] at the current position.
  Token get current => eof() || _index == -1 ? null : tokens[_index];

  /// Returns the current location of the parser within source code.
  SourceLocation get location => _location;

  /// Returns `true` if the parser has reached the end of the token stream.
  bool eof() => _index >= tokens.length;

  /// Advances a negative [n] number of steps, and returns the token at the new position.
  Token backtrack([int n]) => read((n ?? 1) * -1);

  /// Returns a [SyntaxError] with the given message, and [current] as the offending token.
  SyntaxError error(String msg) {
    return new SyntaxError(msg, offendingToken: current);
  }

  /// Throws a [SyntaxError] indicating that an expected token type was not found.
  SyntaxError expectedType(TokenType type) {
    return error('Expected $type, ${current?.type ?? "nothing"} found.');
  }

  /// Checks if the next token is of the given [type]. If `true`, it will be consumed.
  bool next(TokenType type) {
    if (_index >= tokens.length - 1) {
      return false;
    }

    if (peek()?.type == type) {
      read();
      return true;
    }

    return false;
  }

  /// Looks ahead an [n] number of steps without advancing the position.
  Token peek([int n]) => eof() ? null : tokens[_index + (n ?? 1)];

  /// Looks behind an [n] number of steps without advancing the position.
  Token peekBehind([int n]) => peek((n ?? -1) * -1);

  /// Advances the stream an [n] number of steps, and returns the token at the new position.
  Token read([int n]) {
    if (eof()) return null;

    final tok = tokens[_index += (n ?? 1)];
    _location = tok.span.start;
    return tok;
  }
}
