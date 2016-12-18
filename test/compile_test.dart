import 'package:blade/blade.dart';
import 'package:test/test.dart';
final BladeCompiler compiler = new BladeCompiler.standard();

main() {
  test('hello', () {
    print(compiler.compile('''
    <h1>Hello!</h1>
    '''));
  });
}