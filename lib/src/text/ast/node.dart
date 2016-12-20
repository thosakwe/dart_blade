import '../token.dart';

class Node {
  final List<Node> childNodes = [];
  final List<Token> tokens = [];
  
  String toSource() => tokens.map((token) => token.text).join();

  visit(visitor) => visitor.visitNode(this);
}
