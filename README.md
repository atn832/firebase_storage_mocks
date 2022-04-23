Mocks for [Firebase Storage](https://pub.dev/packages/firebase_storage). Use this package to write unit tests involving Firebase Storage.

## Usage

A simple usage example: (assumes `assets/someimage.png` exists in project and is included in assets section of pubspec.yaml)
```dart
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/services.dart' show rootBundle;

main() async {
  final storage = MockFirebaseStorage();
  const filename = 'someimage.png';
  final storageRef = storage.ref().child(filename);
  final localImage = await rootBundle.load("assets/$filename");
  final task = await storageRef.putData(localImage.buffer.asUint8List());
  // Prints 'gs://some-bucket//someimage.png'.
  print(task.ref.fullPath);
}
```

## Features and bugs

Please file feature requests and bugs at the issue tracker.
