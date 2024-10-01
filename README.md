# tqdm

A Dart port of the Python tqdm library.

## Usage

```dart
import 'package:tqdm/tqdm.dart';

void main() async {
  final list = List.generate(100, (i) => i);
  for (final _ in Tqdm(list, title: 'Example')) {
    await Future.delayed(Duration(milliseconds: 100));
  }
}
```

```log
$ dart a.dart
Example  59%|███████████████▍          | 59/100 [00:06<00:04, 9.09it/s]
```
