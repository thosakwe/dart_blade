import 'dart:io';
import 'package:args/args.dart';
import 'package:blade/blade.dart';
import 'package:eval/eval.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

final ArgParser parser = new ArgParser(allowTrailingOptions: true)
  ..addFlag('dart', help: 'Generate Dart instead of HTML', negatable: false)
  ..addFlag('help',
      abbr: 'h', help: 'Print this help information.', negatable: false)
  ..addOption('out', abbr: 'o', help: 'The output file or directory.');

main(List<String> args) async {
  try {
    var results = parser.parse(args);

    if (results.rest.isEmpty) {
      return exit(printUsage());
    }

    Directory dir =
        results['out'] != null ? new Directory(results['out']) : null;
    var isDir = dir != null && await dir.exists();

    for (String path in results.rest) {
      var glob = new Glob(path, recursive: true);

      await for (FileSystemEntity file in glob.list()) {
        if (file is File) {
          var contents = await file.readAsString();
          var dart = new BladeCompiler.standard().compile(contents, {});
          var generated = results['dart']
              ? dart
              : await eval(dart, args: [new StringBuffer()]);

          if (isDir) {
            var base = p.basenameWithoutExtension(file.path);
            var out = new File.fromUri(
                dir.uri.resolve(results['dart'] ? '$base.dart' : '$base.html'));
            await out.writeAsString(generated);
          } else if (results['out'] != null) {
            var out = new File(results['out']);
            await out.writeAsString(generated);
          } else
            stdout.writeln(generated);
        }
      }
    }
  } catch (e) {
    if (e is ArgParserException) {
      exitCode = printUsage();
    } else {
      stderr..writeln(e);
    }
  }
}

int printUsage() {
  stderr
    ..writeln('usage: blade [options...] [<filenames>]')
    ..writeln()
    ..writeln('options: ')
    ..writeln(parser.usage);
  return 1;
}
