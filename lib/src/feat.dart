import 'package:tqdm/src/lisner.dart';
import 'package:tqdm/src/write.dart';

class TqdmIterator<E> implements Iterator<E> {
  final Iterator<E> iterator;
  final StyleWriteBase Function() getWriter;
  final TqdmLisner lisner;
  final bool top;

  StyleWriteBase? writer;

  TqdmIterator(this.iterator, this.lisner, this.getWriter, {this.top = false});
  @override
  bool moveNext() {
    final hasNext = iterator.moveNext();

    switch ((hasNext, writer)) {
      case (true, null):
        writer = getWriter();
        lisner.addListener(writer!.writer, top: top);
      case (true, StyleWriteBase writer):
        writer.next();
      case (false, null):
        break;
      case (false, StyleWriteBase writer):
        writer.next();
        lisner.removeListener(writer.writer);
        lisner.log(writer.finish());
    }

    return hasNext;
  }

  @override
  E get current => iterator.current;
}

class TqdmFuture<T> {
  final Iterable<Future<T>> futures;
  final StyleWriteBase Function() getWriter;
  final TqdmLisner lisner;
  final bool top;

  TqdmFuture(this.futures, this.lisner, this.getWriter, {this.top = false});

  Iterable<Future<T>> wait() {
    final writer = getWriter();
    lisner.addListener(writer.writer, top: top);

    Future.wait(futures).then((_) {
      writer.next();
      lisner.removeListener(writer.writer);
      lisner.log(writer.finish());
    });

    return futures.map((future) async {
      final res = await future;
      writer.next();
      return res;
    });
  }
}
