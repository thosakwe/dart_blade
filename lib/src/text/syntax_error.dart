import 'token.dart';

/// Represents a syntax error.
class SyntaxError implements Exception {
  /// The cause of this error.
  final String cause;

  /// The [Token] that caused this syntax error.
  final Token offendingToken;

  SyntaxError(this.cause, {this.offendingToken});

  @override
  String toString() {
    if (offendingToken == null)
      return 'Syntax error: $cause';
    else if (offendingToken.span.sourceUrl != null) {
      return '(${offendingToken.span.sourceUrl}:${offendingToken.span.start.line}:${offendingToken.span.start.column}) Syntax Error: $cause';
    } else {
      return '(${offendingToken.span.start.line}:${offendingToken.span.start.column}) Syntax Error: $cause';
    }
  }
}