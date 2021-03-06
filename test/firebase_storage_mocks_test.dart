import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:test/test.dart';

final filename = 'someimage.png';

void main() {
  group('MockFirebaseStorage Tests', () {

    test('Puts File', () async {
      final storage = MockFirebaseStorage();
      final storageRef = storage.ref().child(filename);
      final image = File(filename);
      final task = storageRef.putFile(image);
      await task;

      expect(
          task.snapshot.ref.fullPath, equals('gs://some-bucket/someimage.png'));
      expect(storage.storedFilesMap.containsKey('/$filename'), isTrue);
    });

    test('Puts Data', () async {
      final storage = MockFirebaseStorage();
      final storageRef = storage.ref().child(filename);
      final imageData = Uint8List(256);
      final task = storageRef.putData(imageData);
      await task;

      expect(
          task.snapshot.ref.fullPath, equals('gs://some-bucket/someimage.png'));
      expect(storage.storedDataMap.containsKey('/$filename'), isTrue);
    });
  });
}
