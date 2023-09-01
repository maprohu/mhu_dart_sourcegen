import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dart_style/dart_style.dart';
import 'package:mhu_dart_sourcegen/src/strings.dart';

extension SrcgenStringX on String {
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

  Strings get suffixParts sync* {
    switch (this) {
      case NullabilitySuffix.question:
        yield "?";
      case NullabilitySuffix.star:
        yield "*";
      case NullabilitySuffix.none:
    }
  }
}

T run<T>(T Function() fn) => fn();