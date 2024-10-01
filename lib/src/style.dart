import 'package:tqdm/src/style_utils.dart';
import 'package:tqdm/src/terminal.dart';
import 'package:tqdm/src/write.dart';

class TqdmStyleWrite extends StyleWriteBase with CenterProgress {
  final String? title;
  @override
  final List<String> symbols = [' ', '▏', '▎', '▍', '▌', '▋', '▊', '▉', '█'];
  TqdmStyleWrite(super.length, {super.leave, this.title});

  @override
  String writer() {
    final percent = (count / length) * 100;
    final elapsed = lastTime.difference(startTime);

    final eta = (() {
      if (count == 0) {
        return Duration.zero;
      } else {
        final ms = (length - count) * (elapsed.inMilliseconds / count);
        return Duration(milliseconds: ms.round());
      }
    }());

    final rate = (() {
      if (count == 0) {
        return Duration.zero;
      } else {
        final ms = elapsed.inMilliseconds / count;
        return Duration(milliseconds: ms.round());
      }
    }());
    final prefix = [
      if (title != null) title,
      "${StyleUtils.pad(percent.round(), 3, ' ')}%|"
    ];

    final text = [
      '|',
      '$count/$length',
      '[${StyleUtils.duration(elapsed)}<${StyleUtils.duration(eta)},',
      '${StyleUtils.speed(rate)}]'
    ];

    return center(
      prefix: prefix.join(' '),
      suffix: text.join(' '),
      width: terminalWidth(),
    );
  }
}

class PipStyleWrite extends StyleWriteBase with CenterProgress {
  final String? title;

  @override
  final List<String> symbols = [
    StyleUtils.gray('━'),
    StyleUtils.red('╸'),
    StyleUtils.red('━'),
  ];

  PipStyleWrite(super.length, {super.leave, this.title});

  @override
  String? finish() {
    symbols.replaceRange(1, 3, [StyleUtils.green('╸'), StyleUtils.green('━')]);
    return super.finish();
  }

  @override
  String writer() {
    final elapsed = lastTime.difference(startTime);
    final eta = (() {
      if (count == 0) {
        return Duration.zero;
      } else {
        final ms = (length - count) * (elapsed.inMilliseconds / count);
        return Duration(milliseconds: ms.round());
      }
    }());

    final text = [
      StyleUtils.green('${StyleUtils.pad(count, 3, ' ')}/$length'),
      'eta',
      StyleUtils.blue(StyleUtils.duration(eta)),
    ];

    final progress = lite(
      prefix: title == null ? '   ' : '$title ',
      suffix: text.join(' '),
      width: 80,
    );
    return progress + (' ' * (terminalWidth() - 81));
  }
}
