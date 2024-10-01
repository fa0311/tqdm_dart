import 'dart:io';

import 'package:tqdm/src/style_utils.dart';

int terminalWidth() {
  return stdout.hasTerminal ? stdout.terminalColumns : 80;
}

class TerminalUpdate {
  int lastLength;
  TerminalUpdate() : lastLength = 0;

  void update({String prefix = "", required String body}) {
    final width = terminalWidth();
    final len = ((lastLength / width).ceil() - 1);
    if (len > 0) {
      stdout.write('\r\x1B[${len}A\x1B[0J$prefix$body');
    } else {
      stdout.write('\r\x1B[0J$prefix$body');
    }
    lastLength = StyleUtils.clear(body).length;
  }
}
