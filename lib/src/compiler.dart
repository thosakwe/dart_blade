import 'directives/directives.dart';
import 'text/text.dart';
import 'code_builder.dart';
import 'directive.dart';
import 'exception.dart';

class BladeCompiler {
  final Map<String, BladeDirective> directives = {};

  BladeCompiler();

  factory BladeCompiler.standard() {
    var compiler = new BladeCompiler();
    compiler.directives['break'] = new BreakDirective();
    compiler.directives['continue'] = new ContinueDirective();
    compiler.directives['foreach'] = new ForeachDirective();
    compiler.directives['if'] = new IfDirective();
    compiler.directives['endif'] = new EndDirective();
    compiler.directives['endforeach'] = new EndDirective();
    return compiler;
  }

  String compile(String text, [Map<String, dynamic> data]) {
    var reader = new Reader();
    var chunks = reader.read(text);
    print(chunks);
    return compileChunks(chunks, data ?? {});
  }

  String compileChunks(List<Chunk> chunks, Map<String, dynamic> data) {
    var buf = new CodeBuilder();

    buf
      ..writeln("import 'dart:convert' show HTML_ESCAPE;")
      ..write('main(buf');

    for (int i = 0; i < data.keys.length; i++) {
      if (i > 0) buf.put(', ');
      buf.put(data.keys.elementAt(i));
    }

    buf
      ..putln(') {')
      ..indent();

    for (var chunk in chunks) {
      if (chunk is ArbitraryChunk)
        buf.writeln("buf.write(r'''${chunk.text}''');");
      else if (chunk is EchoChunk) {
        if (chunk.raw)
          buf.writeln('buf.write(${chunk.text});');
        else
          buf.writeln('buf.write(HTML_ESCAPE.convert(${chunk.text}));');
      } else if (chunk is DirectiveChunk) {
        if (directives.containsKey(chunk.name)) {
          directives[chunk.name](buf, chunk.arguments);
        } else {
          throw new BladeException.noSuchDirective(chunk.name);
        }
      }
    }

    buf
      ..writeln('return buf.toString();')
      ..outdent()
      ..writeln('}');

    return buf.toString();
  }
}
