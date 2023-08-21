import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dart_style/dart_style.dart';

extension SrcgenIterableOfStringX on Iterable<String> {
  String get joinLines => join('\n');

  String joinEnclosedOrEmpty(
    String begin,
    String end, [
    String separator = '',
  ]) =>
      isEmpty ? '' : join(separator).enclosed(begin, end);

  String joinInCurlyOrEmpty([String separator = '']) =>
      joinEnclosedOrEmpty('{', '}', separator);

  String joinInParenOrEmpty([String separator = ',']) =>
      joinEnclosedOrEmpty('(', ')', separator);

  String joinInChevronOrEmpty([String separator = ',']) =>
      joinEnclosedOrEmpty('<', '>', separator);

  String get joinLinesInCurlyOrEmpty => joinInCurlyOrEmpty('\n');

  Iterable<String> get plusCommas => map((e) => e.plusComma);

  Iterable<String> enclosedIn(String begin, String end) sync* {
    yield begin;
    yield* this;
    yield end;
  }

  Iterable<String> get enclosedInParen => enclosedIn("(", ")");

  Iterable<String> get enclosedInCurly => enclosedIn("{", "}");

  Iterable<String> get enclosedInBracket => enclosedIn("[", "]");
}

extension SrcgenStringX on String {
  String plus(String str) => "$this$str";

  String enclosed(String begin, String end) => "$begin$this$end";

  String get unenclosed => substring(1, length - 1);

  String get inCurly => "{$this}";

  String get inChevron => "<$this>";

  String get inParen => "($this)";

  String plusCurly([String content = '']) => plus(content.inCurly);

  String plusCurlyLines(Iterable<String> lines) => plusCurly(lines.joinLines);

  String plusParen([String content = '']) => plus(content.inParen);

  String plusParenLines(Iterable<String> lines) => plusParen(lines.joinLines);

  String get plusDollar => plus(r'$');

  String get plusComma => plus(r',');

  String get plusSpace => plus(r' ');

  String get plusSemi => plus(r';');

  String get plusDot => plus(r'.');

  String spacePlus(String? value) => sepPlus(' ', value);

  String spacePlusIf(bool when, String? value) =>
      when ? sepPlus(' ', value) : this;

  String sepPlus(String sep, String? value) =>
      value == null ? this : plus(sep).plus(value);

  String assign(String? value) => sepPlus('=', value).plusSemi;

  String get dartRawSingleQuoteStringLiteral => "r'${replaceAll("'", "''")}'";

  static final _formatter = DartFormatter();

  String formattedDartCode([File? errorOutput]) {
    try {
      return _formatter.format(this);
    } catch (_) {
      if (errorOutput != null) {
        errorOutput.parent.createSync(recursive: true);
        errorOutput.writeAsStringSync(this);
        stderr.writeln("error formatting: ${errorOutput.uri}");
      }
      rethrow;
    }
  }

  String removePrefixes(List<String> prefixes) {
    for (final prefix in prefixes) {
      if (startsWith(prefix)) {
        return substring(prefix.length);
      }
    }
    return this;
  }
}

extension SourceGenAnyX<T> on T {
  void addTo(List<T> target) => target.add(this);
}

extension TypeParameterizedElementX on TypeParameterizedElement {
  String get parametersDart => typeParameters.parametersDart;

  String get argumentsDart => typeParameters.argumentsDart;

  String get nameWithArguments => "$displayName$argumentsDart";
}

extension ListOfTypeParameterElementX on List<TypeParameterElement> {
  String get parametersDart =>
      map((e) => e.parameterDart).joinInChevronOrEmpty();

  String get argumentsDart => map((e) => e.name).joinInChevronOrEmpty();
}

extension TypeParameterElementX on TypeParameterElement {
  String get parameterDart => toString().removePrefixes(
        [
          "in ",
          "out ",
          "inout ",
        ],
      );
}

extension DartTypeX on DartType {
  String substituteTypeArgs(Map<String, String> map) {
    final self = this;

    switch (self) {
      case InterfaceType():
        return element!.name!
            .plus(
              self.typeArguments
                  .map((e) => e.substituteTypeArgs(map))
                  .joinInChevronOrEmpty(),
            )
            .plus(
              self.nullabilitySuffix.dartSuffix,
            );
      case TypeParameterType():
        final name = self.element.name;
        return map[name] ?? getDisplayString(withNullability: true);
    }

    return getDisplayString(withNullability: true);
  }

  Iterable<TypeParameterType> get findTypeParameters sync* {
    final self = this;
    switch (self) {
      case TypeParameterType():
        yield self;
      case ParameterizedType():
        for (final param in self.typeArguments) {
          yield* param.findTypeParameters;
        }
      case FunctionType():
        yield* self.returnType.findTypeParameters;
        for (final parameter in self.parameters) {
          yield* parameter.type.findTypeParameters;
        }
    }
  }
}

extension SrcgenListOfStringX on List<String> {
  String joinEnclosedIfMultiple([
    String begin = "(",
    String end = ")",
    String separator = ",",
  ]) {
    if (length == 1) return first;
    return joinEnclosedOrEmpty(begin, end, separator);
  }
}

extension NullabilitySuffixX on NullabilitySuffix {
  String get dartSuffix => switch (this) {
        NullabilitySuffix.question => "?",
        NullabilitySuffix.none => "",
        NullabilitySuffix.star => "*",
      };
}
