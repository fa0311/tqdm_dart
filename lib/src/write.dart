import 'package:tqdm/src/style_utils.dart';

abstract class StyleWriteBase {
  final int length;
  final DateTime startTime;
  final bool leave;
  int count;
  DateTime? endTime;
  DateTime get lastTime => endTime ?? DateTime.now();

  StyleWriteBase(this.length, {this.leave = false})
      : count = 0,
        startTime = DateTime.now();

  void next() {
    count++;
  }

  String? finish() {
    endTime = DateTime.now();
    return leave ? null : writer();
  }

  String writer();
}

mixin CenterProgress {
  List<String> get symbols;
  int get count;
  int get length;

  String center({
    required String prefix,
    required String suffix,
    required int width,
  }) {
    final empty = width - prefix.length - suffix.length;
    final max = empty * symbols.length;
    final filled = (count * max) / length;
    final chars = <String>[
      symbols.last * (filled ~/ symbols.length),
      if (filled % symbols.length > 0)
        symbols[(filled % symbols.length).floor()],
      symbols.first * ((max - filled) ~/ symbols.length)
    ];
    return '$prefix${chars.join()}$suffix';
  }

  String lite({
    required String prefix,
    required String suffix,
    required int width,
  }) {
    final center = symbols[1];
    final empty = width -
        StyleUtils.clear(prefix).length -
        StyleUtils.clear(suffix).length;
    final filled = (count * empty) ~/ length;

    final chars = <String>[
      symbols.last * filled,
      center,
      symbols.first * (empty - filled - 1),
    ];
    return '$prefix${chars.join()}$suffix';
  }
}
