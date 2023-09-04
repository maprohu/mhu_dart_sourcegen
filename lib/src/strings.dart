import 'package:dart_style/dart_style.dart';

typedef Strings = Iterable<String>;

extension IterableX<T> on Iterable<T> {
  Iterable<T> separatedBy(T separator) sync* {
    final it = iterator;

    if (!it.moveNext()) {
      return;
    }

    yield it.current;

    while (it.moveNext()) {
      yield separator;
      yield it.current;
    }
  }
}

extension StringX on String {
  String enclosed(String begin, String end) => "$begin$this$end";

  String plus(String str) => "$this$str";

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

  String removePrefixes(List<String> prefixes) {
    for (final prefix in prefixes) {
      if (startsWith(prefix)) {
        return substring(prefix.length);
      }
    }
    return this;
  }
}

extension StringsX on Strings {
  Strings get separatedByCommas => separatedBy(",");

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
  Iterable<String> get enclosedInCurlyOrEmpty {
    final list = toList();
    return list.isEmpty ? list : list.enclosedIn("{", "}");
  }

  Iterable<String> get enclosedInSquareBracket => enclosedIn("[", "]");
  Iterable<String> get enclosedInChevron => enclosedIn("<", ">");
  Iterable<String> get enclosedInSingleQuote => enclosedIn("'", "'");
}
