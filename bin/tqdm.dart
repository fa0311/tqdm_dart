import 'dart:math';

import 'package:tqdm/tqdm.dart';

void main() async {
  for (final _ in Tqdm(List.generate(30, (index) => index), title: "Simple")) {
    await Future.delayed(Duration(milliseconds: 100));
  }

  for (final i in List.generate(3, (index) => index)) {
    Future.delayed(Duration(milliseconds: 1000 * i)).then((_) {
      Tqdm.lisner.log("This is a log message\n");
    });
  }

  for (final _ in Tqdm(
    List.generate(30, (index) => index),
    title: "Leave",
    leave: true,
  )) {
    await Future.delayed(Duration(milliseconds: 100));
  }

  for (final _ in Tqdm.custom(
    List.generate(30, (index) => index),
    () => PipStyleWrite(30, title: "Custom Theme"),
  )) {
    await Future.delayed(Duration(milliseconds: 100));
  }

  for (final i in Tqdm(List.generate(5, (index) => index))) {
    await Future.delayed(Duration(milliseconds: i == 0 ? 2000 : 500));
  }

  for (final i in Tqdm(List.generate(5, (index) => index))) {
    await Future.delayed(Duration(milliseconds: i == 0 ? 2000 : 500));
  }

  await Future.wait(Tqdm.future(
    List.generate(100, (i) => Future.delayed(Duration(milliseconds: i * 50))),
    title: "Future Example",
  ));

  await Future.wait(Tqdm.future(
    List.generate(5, (ii) {
      return Future.wait(Tqdm.future(
        List.generate(Random().nextInt(100), (i) {
          final j = Random().nextInt(100);
          return Future.delayed(
            Duration(milliseconds: i * 100 + j),
          );
        }),
        leave: true,
      ));
    }),
    title: "Nested Future Example",
    top: true,
  ));

  for (final _ in Tqdm(List.generate(5, (index) => index))) {
    for (final _ in Tqdm(List.generate(10, (index) => index), leave: true)) {
      await Future.delayed(Duration(milliseconds: 50));
    }
  }
}
