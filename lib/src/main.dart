import 'dart:async';
import 'dart:collection';

import 'package:tqdm/src/feat.dart';
import 'package:tqdm/src/lisner.dart';
import 'package:tqdm/src/style.dart';
import 'package:tqdm/src/write.dart';

class Tqdm<E> extends IterableBase<E> {
  static TqdmLisner lisner = TqdmLisner(10);
  final Iterable<E> values;
  final StyleWriteBase Function() getWriter;
  final bool top;

  Tqdm(
    this.values, {
    bool leave = false,
    this.top = false,
    String? title,
  }) : getWriter = (() => TqdmStyleWrite(
              values.length,
              leave: leave,
              title: title,
            ));

  @override
  Iterator<E> get iterator {
    return TqdmIterator(
      values.iterator,
      lisner,
      getWriter,
      top: top,
    );
  }

  Tqdm.custom(this.values, this.getWriter, {this.top = false});

  static Iterable<Future<T>> future<T>(
    Iterable<Future<T>> futures, {
    bool leave = false,
    bool top = false,
    String? title,
  }) {
    final writer = TqdmStyleWrite(futures.length, leave: leave, title: title);
    return TqdmFuture(futures, lisner, () => writer, top: top).wait();
  }
}
