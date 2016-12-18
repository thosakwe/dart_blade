import '../directive.dart';

class BreakDirective extends BladeDirective {
  @override
  void call(builder, List<String> args) => builder.writeln('break;');
}

class ContinueDirective extends BladeDirective {
  @override
  void call(builder, List<String> args) => builder.writeln('continue;');
}

class EndDirective extends BladeDirective {
  @override
  void call(builder, List<String> args) {
    builder
      ..writeln('}')
      ..outdent();
  }
}

class ForeachDirective extends BladeDirective {
  @override
  void call(builder, List<String> args) {
    builder
      ..writeln('for (var ${args.first}) {')
      ..indent();
  }
}

class IfDirective extends BladeDirective {
  @override
  void call(builder, List<String> args) {
    builder
      ..writeln('if (${args.first}) {')
      ..indent();
  }
}
