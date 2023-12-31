import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:mhu_dart_sourcegen/mhu_dart_sourcegen.dart';

extension DartTypeX on DartType {
  Iterable<String> get codeParts sync* {
    final alias = this.alias;

    if (alias == null) {
      final self = this;

      switch (self) {
        case FunctionType():
          yield* self.returnType.codeParts;
          yield ' Function';
          yield self.typeFormals.parametersDart;

          yield* self.parameters.parameterListDartTypeCodeParts.enclosedInParen;

          yield* nullabilitySuffix.suffixParts;
        case _:
          yield getDisplayString(withNullability: true);
      }

      // TODO keep aliases recursively
    } else {
      yield alias.element.displayName;

      yield* alias.typeArguments.typeArgumentsCodeParts;

      yield* nullabilitySuffix.suffixParts;
    }
  }

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
        yield* self.bound.findTypeParameters;
      case ParameterizedType():
        for (final param in self.typeArguments) {
          yield* param.findTypeParameters;
        }
      case FunctionType():
        yield* self.returnType.findTypeParameters;
        for (final parameter in self.parameters) {
          yield* parameter.type.findTypeParameters;
        }
        for (final TypeParameterElement(:bound) in self.typeFormals) {
          if (bound != null) {
            yield* bound.findTypeParameters;
          }
        }
    }
  }
}

extension TypeArgumentsX on List<DartType> {
  Iterable<String> get typeArgumentsCodeParts sync* {
    if (isEmpty) {
      return;
    }

    yield* map((e) => e.codeParts)
        .separatedBy(const [","])
        .flattened
        .enclosedInChevron;
  }
}
