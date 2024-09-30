import 'dart:collection';
import 'dart:io';

tqdm() {}

class Tqdm<E> extends IterableBase<E> {
  final Iterable<E> values;
  Tqdm(this.values);

  @override
  Iterator<E> get iterator => TqdmIterator(values.iterator, values.length);
}

class TqdmIterator<E> implements Iterator<E> {
  final Iterator<E> iterator;
  final List<String> symbols = [' ', '▏', '▎', '▍', '▌', '▋', '▊', '▉', '█'];
  final int length;
  int count = 0;
  DateTime? startTime;
  DateTime? endTime;

  int get terminalWidth => stdout.hasTerminal ? stdout.terminalColumns : 80;

  TqdmIterator(this.iterator, this.length);

  String writer({required String prefix, required String suffix}) {
    final empty = terminalWidth - prefix.length - suffix.length;
    final max = empty * symbols.length;
    final filled = (count / length) * max;
    final List<String> chars = [
      symbols.last * (filled ~/ symbols.length),
      if (filled % symbols.length > 0)
        symbols[(filled % symbols.length).round()],
      symbols.first * ((max - filled) ~/ symbols.length)
    ];
    return '$prefix${chars.join()}$suffix';
  }

  String pad(int text, int length) {
    return text.toString().padLeft(length, '0');
  }

  String durationWriter(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${pad(duration.inMinutes, 2)}:${pad(duration.inSeconds.remainder(60), 2)}';
    } else if (duration.inHours < 24) {
      return '${pad(duration.inHours, 2)}:${pad(duration.inMinutes.remainder(60), 2)}';
    } else {
      return '${pad(duration.inDays, 2)}:${pad(duration.inHours.remainder(24), 2)}';
    }
  }

  String speedWriter(Duration duration) {
    if (duration.inSeconds < 1) {
      return '${(1000 / duration.inMilliseconds).toStringAsFixed(2)} item/s';
    } else if (duration.inMinutes < 1) {
      return '${duration.inSeconds}.${pad(duration.inMilliseconds.remainder(1000), 2)} item/s';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes}.${pad(duration.inSeconds.remainder(60), 2)} item/m';
    } else {
      return '${duration.inHours}.${pad(duration.inMinutes.remainder(60), 2)} item/h';
    }
  }

  String richWriter({required String title}) {
    if (count == 0) {
      return writer(
        prefix: "$title 0.00%|",
        suffix: '|0/$length [00:00<00:00, 0.00 item/s]',
      );
    }

    final percent = (count / length) * 100;
    final elapsed = (endTime ?? DateTime.now()).difference(startTime!);

    final eta = Duration(
      milliseconds:
          ((length - count) * (elapsed.inMilliseconds / count)).round(),
    );
    final rate = Duration(
      milliseconds: elapsed.inMilliseconds ~/ count,
    );

    return writer(
      prefix: "$title ${percent.toStringAsFixed(2)}%|",
      suffix:
          '|$count/$length [${durationWriter(elapsed)}<${durationWriter(eta)}, ${speedWriter(rate)}]',
    );
  }

  @override
  bool moveNext() {
    final hasNext = iterator.moveNext();
    if (hasNext) {
      stdout.write('\r');
      stdout.write(richWriter(title: 'Progress'));
      startTime ??= DateTime.now();
      count++;
    } else {
      stdout.write('\r');
      stdout.write(richWriter(title: 'Progress'));
      endTime ??= DateTime.now();
    }
    return hasNext;
  }

  @override
  E get current => iterator.current;
}

void main() async {
  for (final i in Tqdm([1, 2, 3, 4, 5])) {
    await Future.delayed(Duration(seconds: 1));
  }
}
