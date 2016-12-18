import 'code_builder.dart';

abstract class BladeDirective {
  void call(CodeBuilder builder, List<String> args);
}