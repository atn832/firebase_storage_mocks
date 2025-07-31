# Firebase Storage Mocks

Mocks for [Firebase Storage](https://pub.dev/packages/firebase_storage). Use this package to write unit tests involving Firebase Storage.

[![pub package](https://img.shields.io/pub/v/firebase_storage_mocks.svg)](https://pub.dartlang.org/packages/firebase_storage_mocks)

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

## Compatibility table

| firebase_storage | firebase_storage_mocks |
|------------------|------------------------|
| 13.0.0           | 0.8.0                  |
| 12.0.0           | 0.7.0                  |
| 11.0.0           | 0.6.0                  |
| 10.0.0           | 0.5.1                  |

## Features and bugs

Please file feature requests and bugs at the issue tracker.
