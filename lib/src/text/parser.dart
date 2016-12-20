import 'dart:async';
import 'ast/ast.dart';
import 'base_parser.dart';
import 'syntax_error.dart';
import 'token.dart';
import 'token_type.dart';

/// A streaming parser.
class Parser extends BaseParser {
  StreamController<CompilationUnitContext> _onCompilationUnit =
      new StreamController<CompilationUnitContext>();

  Stream<CompilationUnitContext> get onCompilationUnit =>
      _onCompilationUnit.stream;

  Parser(Stream<Token> stream) : super([]) {
    stream.listen((token) {
      tokens.add(token);

      var ast = compilationUnit();

      if (ast != null) _onCompilationUnit.add(ast);
    });
  }

  CompilationUnitContext compilationUnit() {
    return null;
  }
}
