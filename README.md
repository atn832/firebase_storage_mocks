Mocks for [Firebase Storage](https://pub.dev/packages/firebase_storage). Use this package to write unit tests involving Firebase Storage.

## Usage

A simple usage example:

```dart
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

main() {
  final storage = MockFirebaseStorage();
  final StorageReference storageRef = storage.ref().child(filename);
  final image = File(filename);
  final task = storageRef.putFile(image);
  await task.onComplete;
  // Prints 'gs://some-bucket//someimage.png'.
  print(await getGsLink(storageRef));
}

Future<String> getGsLink(StorageReference storageRef) async {
  return 'gs://' + await storageRef.getBucket() + '/' + storageRef.path;
}
```

## Features and bugs

Please file feature requests and bugs at the issue tracker.