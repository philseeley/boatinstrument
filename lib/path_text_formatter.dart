import 'package:boatinstrument/boatinstrument_controller.dart';

abstract class _Formatter {
  String _render(PathTextFormatter parent);
}

class _LiteralFormatter implements _Formatter {
  final String _text;

  _LiteralFormatter(this._text);

  @override
  String _render(PathTextFormatter parent) {
    return _text;
  }
}

class _PathFormatter implements _Formatter {
  final String _path;

  _PathFormatter(this._path);

  @override
  String _render(PathTextFormatter parent) {
    return parent._data[_path]??'-';
  }
}

class PathTextFormatter {
  final BoatInstrumentController _controller;
  final String _format;
  final List<_Formatter> _formatters = [];
  final Set<String> _paths = {};
  Map<String, String> _data = {};

  PathTextFormatter(this._controller, this._format) {
    _parseFormat();
  }

  static final List<RegExp> _pats = [
    RegExp(r'^[^{]+'), // 0
    RegExp(r'^\{.[^\}]*\}'), // 1
  ];

  _parseFormat() {
    String todo = _format;

    while (todo.isNotEmpty) {
      bool matched = false;
      for (int i = 0; i < _pats.length; ++i) {
        RegExpMatch? match = _pats[i].firstMatch(todo);
        if (match != null) {
          int len = match[0]!.length - 1;
          switch (i) {
            case 0:
              _formatters.add(_LiteralFormatter(match[0]!));
              break;
            case 1:
              String p = match[0]!.substring(1, len);
              _paths.add(p);
              _formatters.add(_PathFormatter(p));
              break;
          }
          matched = true;
          todo = todo.substring(match[0]!.length);
          break;
        }
      }
      if (!matched) {
        _controller.l.e('Formatting Custom Text, bad format at "$todo"');
        return;
      }
    }
  }

  Set<String> get paths => _paths;

  String format(Map<String, String> data) {
    _data = data;

    StringBuffer result = StringBuffer();
    for (final f in _formatters) {
      result.write(f._render(this));
    }
    return result.toString();
  }
}
