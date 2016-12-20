import 'package:string_scanner/string_scanner.dart';
import 'chunk.dart';

final RegExp _directive = new RegExp(r'@([A-Za-z_][A-Za-z0-9_]*)');
final RegExp _echo = new RegExp(r'(@?){{([^}]+)}}');
final RegExp _params =
    new RegExp(r'@([A-Za-z_][A-Za-z0-9_]*)\s*\(((([^)]+,)*([^)]+))?)\)');
final RegExp _raw = new RegExp(r'{!!([^!]+)!!}');

class Reader {
  List<Chunk> read(String text) {
    List<Chunk> chunks = [];
    var scanner = new StringScanner(text);
    List<int> codeunits = [];

    void flushCurrentChunk() {
      if (codeunits.isNotEmpty) {
        var str = new String.fromCharCodes(codeunits);
        chunks.add(new ArbitraryChunk(str));
        codeunits.clear();
      }
    }

    while (!scanner.isDone) {
      if (scanner.scan(_echo)) {
        flushCurrentChunk();

        if (scanner.lastMatch[1].isNotEmpty) {
          // Escaped braces
          codeunits.addAll('{{ ${scanner.lastMatch[2].trim()} }}'.codeUnits);
          flushCurrentChunk();
        } else {
          chunks.add(new EchoChunk(scanner.lastMatch[2].trim()));
        }
      } else if (scanner.scan(_params)) {
        flushCurrentChunk();
        var chunk = new DirectiveChunk(scanner.lastMatch[1].trim());
        var split = scanner.lastMatch[2].trim().split(',');
        chunk.arguments.addAll(
            split.map((str) => str.trim()).where((str) => str.isNotEmpty));
        chunks.add(chunk);
      } else if (scanner.scan(_directive)) {
        flushCurrentChunk();
        chunks.add(new DirectiveChunk(scanner.lastMatch[1].trim()));
      } else if (scanner.scan(_raw)) {
        flushCurrentChunk();
        chunks.add(new EchoChunk.unescaped(scanner.lastMatch[1].trim()));
      } else {
        int ch = scanner.readChar();
        codeunits.add(ch);
      }
    }

    flushCurrentChunk();

    return chunks;
  }
}
