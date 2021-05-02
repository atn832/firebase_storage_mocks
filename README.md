Mocks for [Firebase Storage](https://pub.dev/packages/firebase_storage). Use this package to write unit tests involving Firebase Storage.

## Usage

A simple usage example:

```dart
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

main() {
  final storage = MockFirebaseStorage('someimage.png');
  final storageRef = storage.ref().child(filename);
  final image = File(filename);
  await storageRef.putFile(image);
  // Prints 'gs://some-bucket//someimage.png'.
  print(task.snapshot.ref.fullPath);
}
```

## Features and bugs

Please file feature requests and bugs at the issue tracker.