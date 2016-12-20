import 'node.dart';

class Visitor<T> {
  T visitNode(Node ctx) {
    T result = null;

    for (Node child in ctx.childNodes) result = visitNode(child);

    return result;
  }
}
