import 'package:analyzer/dart/element/element.dart';
import 'package:mhu_dart_sourcegen/mhu_dart_sourcegen.dart';

extension ParameterElementX on ParameterElement {
  Strings get dartTypeCodeParts sync* {
    yield* [
      if (isRequiredNamed) "required ",
      ...type.codeParts,
      " ",
      name,
      ",",
    ];
  }

  String get declareDart => declareDartParts.join();

  Iterable<String> get declareDartParts sync* {
    final defaultValueCode = this.defaultValueCode;
    yield* [
      if (isRequiredNamed) "required ",
      ...type.codeParts,
      " ",
      name,
      if (defaultValueCode != null) ...[
        "=",
        defaultValueCode,
      ],
      ",",
    ];
  }
  Iterable<String> get declareDartPartsUnnamed sync* {
    final defaultValueCode = this.defaultValueCode;
    yield* [
      ...type.codeParts,
      " ",
      name,
      if (defaultValueCode != null) ...[
        "=",
        defaultValueCode,
      ],
      ",",
    ];
  }
}

extension IterableOfParameterElementX on Iterable<ParameterElement> {
  Strings get parameterListDartTypeCodeParts sync* {
    final methodParams = toList();

    final plainParamCount =
        methodParams.takeWhile((e) => e.isRequiredPositional).length;
    final plainParams = methodParams.sublist(0, plainParamCount);
    final specialParams = methodParams.sublist(plainParamCount);


    Iterable<String> paramListOf(Iterable<ParameterElement> params) sync* {
      for (final param in params) {
        yield* param.dartTypeCodeParts;
      }
    }

    yield* paramListOf(plainParams);
    final firstSpecialParam = specialParams.firstOrNull;
    if (firstSpecialParam != null) {
      final specials = paramListOf(specialParams);

      if (firstSpecialParam.isNamed) {
        yield* specials.enclosedInCurly;
      } else {
        yield* specials.enclosedInSquareBracket;
      }
    }
  }
}

