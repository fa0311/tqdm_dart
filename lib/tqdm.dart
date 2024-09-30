import 'dart:async';
import 'dart:collection';
import 'dart:io';

class TqdmLisner {
  final List<Function> listeners = [];
  final Duration duration;
  int get terminalWidth => stdout.hasTerminal ? stdout.terminalColumns : 80;
  Timer? timer;
  int lastLength;
  int lastTerminalWidth;
  TqdmLisner(fps)
      : duration = Duration(milliseconds: (1000 / fps).round()),
        lastLength = 0,
        lastTerminalWidth = stdout.hasTerminal ? stdout.terminalColumns : 80;

  void update(String text) {
    final width = terminalWidth;
    final len = ((lastLength / width).ceil() - 1);
    if (len > 0) {
      stdout.write('\r\x1B[${len}A\x1B[0J$text');
    } else {
      stdout.write('\r\x1B[0J$text');
    }
    lastLength = text.length;
  }

  void addListener(Function listener) {
    listeners.add(listener);
    timer ??= Timer.periodic(duration, (timer) {
      final text = listeners.map((e) => e()).join();
      update(text);
    });
  }

  void removeListener(Function listener) {
    listeners.remove(listener);
    if (listeners.isEmpty) {
      timer?.cancel();
      timer = null;
      update('');
    }
  }
}

class Tqdm<E> extends IterableBase<E> {
  final Iterable<E> values;
  static TqdmLisner lisner = TqdmLisner(10);

  Tqdm(this.values);

  @override
  Iterator<E> get iterator => TqdmIterator(
        values.iterator,
        values.length,
        lisner,
      );

  static Iterable<Future<T>> future<T>(Iterable<Future<T>> futures) {
    final length = futures.length;
    final writer = TqdmWrite(length);
    write() => writer.richWriter(title: 'Progress');
    lisner.addListener(write);

    Future.wait(futures).then((_) {
      writer.finish();
      lisner.removeListener(write);
    });

    return futures.map((future) async {
      final res = await future;
      writer.next();
      return res;
    });
  }
}

class TqdmIterator<E> implements Iterator<E> {
  final Iterator<E> iterator;
  final int length;
  final TqdmLisner lisner;
  TqdmWrite? writer;

  TqdmIterator(this.iterator, this.length, this.lisner);

  String write() {
    return writer!.richWriter(title: 'Progress');
  }

  @override
  bool moveNext() {
    final hasNext = iterator.moveNext();

    switch ((hasNext, writer)) {
      case (true, null):
        writer = TqdmWrite(length);
        lisner.addListener(write);
      case (true, TqdmWrite writer):
        writer.next();
      case (false, null):
        break;
      case (false, TqdmWrite writer):
        writer.next();
        writer.finish();
        lisner.removeListener(write);
    }

    return hasNext;
  }

  @override
  E get current => iterator.current;
}

class TqdmWrite {
  final int length;
  static const List<String> symbols = [
    ' ',
    '▏',
    '▎',
    '▍',
    '▌',
    '▋',
    '▊',
    '▉',
    '█'
  ];

  final DateTime startTime;
  DateTime? endTime;
  int count;
  int get terminalWidth => stdout.hasTerminal ? stdout.terminalColumns : 80;
  DateTime get lastTime => endTime ?? DateTime.now();

  TqdmWrite(this.length)
      : count = 0,
        startTime = DateTime.now();

  void next() {
    count++;
  }

  void finish() {
    endTime = DateTime.now();
  }

  String writer({required String prefix, required String suffix}) {
    final empty = terminalWidth - prefix.length - suffix.length;
    final max = empty * symbols.length;
    final filled = (count / length) * max;
    final List<String> chars = [
      symbols.last * (filled ~/ symbols.length),
      if (filled % symbols.length > 0)
        symbols[(filled % symbols.length).floor()],
      symbols.first * ((max - filled) ~/ symbols.length)
    ];
    return '$prefix${chars.join()}$suffix';
  }

  String pad(int text, int length) {
    return text.toString().padLeft(length, '0').substring(0, length);
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
    if (duration == Duration.zero) {
      return '0.00it/s';
    } else if (duration.inSeconds < 1) {
      return '${(1000 / duration.inMilliseconds).toStringAsFixed(2)}it/s';
    } else if (duration.inMinutes < 1) {
      return '${duration.inSeconds}.${pad(duration.inMilliseconds.remainder(1000), 2)}it/s';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes}.${pad(duration.inSeconds.remainder(60), 2)}it/m';
    } else {
      return '${duration.inHours}.${pad(duration.inMinutes.remainder(60), 2)}it/h';
    }
  }

  String richWriter({required String title}) {
    final percent = (count / length) * 100;
    final elapsed = lastTime.difference(startTime);

    final eta = (() {
      if (count == 0) {
        return Duration.zero;
      } else {
        final ms =
            ((length - count) * (elapsed.inMilliseconds / count)).round();
        return Duration(milliseconds: ms);
      }
    }());

    final rate = (() {
      if (count == 0) {
        return Duration.zero;
      } else {
        final ms = (elapsed.inMilliseconds / count).round();
        return Duration(milliseconds: ms);
      }
    }());

    return writer(
      prefix: "$title ${percent.toStringAsFixed(2)}%|",
      suffix:
          '|$count/$length [${durationWriter(elapsed)}<${durationWriter(eta)}, ${speedWriter(rate)}]',
    );
  }
}

void main() async {
  await Future.wait(Tqdm.future(
    List.generate(100, (i) => Future.delayed(Duration(milliseconds: i * 100))),
  ));

  await Future.wait(Tqdm.future(List.generate(10, (ii) {
    return Future.wait(Tqdm.future(
      List.generate(100, (i) {
        return Future.delayed(Duration(milliseconds: i * 100 + ii * 1000));
      }),
    ));
  })));

  for (final i in Tqdm(List.generate(5, (index) => index))) {
    await Future.delayed(Duration(milliseconds: i == 0 ? 2000 : 500));
  }

  for (final i in Tqdm(List.generate(5, (index) => index))) {
    await Future.delayed(Duration(milliseconds: i == 4 ? 2000 : 500));
  }

  for (final _ in Tqdm(List.generate(30, (index) => index))) {
    await Future.delayed(Duration(milliseconds: 100));
  }
  for (final _ in Tqdm(List.generate(100, (index) => index))) {
    for (final _ in Tqdm(List.generate(100, (index) => index))) {
      await Future.delayed(Duration(milliseconds: 10));
    }
  }
}
