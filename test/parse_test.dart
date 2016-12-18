import 'package:blade/src/text/text.dart';
import 'package:test/test.dart';
final Reader reader = new Reader();

main() {
  test('curly', () {
    var chunks = reader.read('<a>{{ foo }}</a>');
    print(chunks);
  });

  group('directive', () {
    test('empty', () {
    var chunks = reader.read('<a>@verbatim</a>');
    print(chunks);
    });
  });

  test('escaped curly', () {
    var chunks = reader.read('<a>@{{ foo }}</a>');
    print(chunks);
  });

  test('loop', () {
    var chunks = reader.read('''
    @foreach (user in users)
        @if (user.type == 1)
            @continue
        @endif

        <li>{{ user.name }}</li>

        @if (user.number == 5)
            @break
        @endif
    @endforeach
    ''');
    print(chunks);
  });

  test('unescaped', () {
    var chunks = reader.read('<html><title>{!! dangerous !!}</title></html>');
    print(chunks);
  });
}