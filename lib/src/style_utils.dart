class StyleUtils {
  static green(String text) => '\x1B[32m$text\x1B[0m';
  static red(String text) => '\x1B[91m$text\x1B[0m';
  static blue(String text) => '\x1B[34m$text\x1B[0m';
  static gray(String text) => '\x1B[2m$text\x1B[0m';

  static String clear(String text) {
    return text
        .replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '')
        .replaceAll('\n', '')
        .replaceAll('\r', '');
  }

  static String pad(int text, int length, [String pad = '0']) {
    return text.toString().padLeft(length, pad).substring(0, length);
  }

  static String duration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${pad(duration.inMinutes, 2)}:${pad(duration.inSeconds.remainder(60), 2)}';
    } else if (duration.inHours < 24) {
      return '${pad(duration.inHours, 2)}:${pad(duration.inMinutes.remainder(60), 2)}';
    } else {
      return '${pad(duration.inDays, 2)}:${pad(duration.inHours.remainder(24), 2)}';
    }
  }

  static String durationFull(Duration duration) {
    return '${pad(duration.inHours, 2)}:${pad(duration.inMinutes.remainder(60), 2)}:${pad(duration.inSeconds.remainder(60), 2)}';
  }

  static String speed(Duration duration) {
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
}
