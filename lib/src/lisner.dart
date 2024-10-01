import 'dart:async';

import 'package:tqdm/src/terminal.dart';

class TqdmLisner {
  final List<Function> listeners = [];
  final List<String> prefix = [];
  final Duration duration;
  final TerminalUpdate terminal;

  Timer? timer;
  TqdmLisner(frameRate)
      : duration = Duration(milliseconds: (1000 / frameRate).round()),
        terminal = TerminalUpdate();

  void addListener(Function listener, {bool top = false}) {
    listeners.insert(top ? 0 : listeners.length, listener);
    timer ??= Timer.periodic(duration, (timer) {
      final body = listeners.map((e) => e()).join();
      terminal.update(prefix: prefix.join(), body: body);
      prefix.clear();
    });
  }

  void removeListener(Function listener) {
    listeners.remove(listener);
    if (listeners.isEmpty) {
      timer?.cancel();
      timer = null;
      terminal.update(prefix: prefix.join(), body: '');
      prefix.clear();
    }
  }

  void log(String? text) {
    if (text != null) {
      if (timer == null) {
        terminal.update(body: text);
        prefix.clear();
      } else {
        prefix.add(text);
      }
    }
  }
}
