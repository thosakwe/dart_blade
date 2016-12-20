class Chunk {}

class ArbitraryChunk extends Chunk {
  final String text;

  ArbitraryChunk(this.text);

  @override
  String toString() => "Arbitrary: '$text'";
}

class DirectiveChunk extends Chunk {
  final String name;
  final List<String> arguments = [];

  DirectiveChunk(this.name, {List<String> arguments: const []}) {
    if (arguments != null) this.arguments.addAll(arguments);
  }

  @override
  String toString() {
    var buf = new StringBuffer('Directive: $name(');

    for (int i = 0; i < arguments.length; i++) {
      if (i > 0) buf.write(', ');
      buf.write(arguments[i].trim());
    }

    buf.write(')');
    return buf.toString();
  }
}

class EchoChunk extends Chunk {
  final String text;
  final bool raw;

  EchoChunk(this.text, {this.raw: false});

  factory EchoChunk.unescaped(String text) => new EchoChunk(text, raw: true);

  @override
  String toString() => raw ? "Unescaped: '$text'" : "Echo: '$text'";
}
