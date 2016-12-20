import 'dart:async';
import 'package:blade/src/text/text.dart';
import 'package:test/test.dart';

Stream<String> str(String s) {
  var c = new StreamController<String>()
    ..add(s)
    ..close();
  return c.stream;
}

main() {
  test('curly', () async {
    var scanner = new Scanner(Uri.parse('foo.bar'));
    var chunks = await str('<a>{{ foo }}</a>').transform(scanner).toList();
    print(chunks);
  });

  group('directive', () {
    test('empty', () async {
      var scanner = new Scanner(Uri.parse('foo.bar'));
      var chunks = await str('<a>@verbatim</a>').transform(scanner).toList();
      print(chunks);
    });

    test('escaped curly', () async {
      var scanner = new Scanner(Uri.parse('foo.bar'));
      var chunks = await str('<a>@{{ foo }}</a>').transform(scanner).toList();
      print(chunks);
    });

    test('loop', () async {
      var scanner = new Scanner(Uri.parse('foo.bar'));
      var chunks = await str('''
    @foreach (user in users)
        @if (user.type == 1)
            @continue
        @endif

        <li>{{ user.name }}</li>

        @if (user.number == 5)
            @break
        @endif
    @endforeach
    ''').transform(scanner).toList();
      print(chunks);
    });

    test('unescaped', () async {
      var scanner = new Scanner(Uri.parse('foo.bar'));
      var chunks = await str('<html><title>{!! dangerous !!}</title></html>')
          .transform(scanner)
          .toList();
      print(chunks);
    });
  });
}
