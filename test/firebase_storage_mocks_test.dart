import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:test/test.dart';

final filename = 'someimage.png';

void main() {
  group('MockFirebaseStorage Tests', () {
    MockFirebaseStorage storage;

    setUpAll(() {
      storage = MockFirebaseStorage();
    });

    test('Puts File', () async {
      final storageRef = storage.ref().child(filename);
      final image = File(filename);
      final task = storageRef.putFile(image);
      final snap = await task.whenComplete(null);

      expect(await getGsLink(snap.ref),
          equals('gs://some-bucket/someimage.png'));
      expect(storage.storedFilesMap.containsKey('/$filename'), isTrue);
    });

    test('Puts Data', () async {
      final storage = MockFirebaseStorage();
      final storageRef = storage.ref().child(filename);
      final imageData = Uint8List(256);
      final task = storageRef.putData(imageData);
      final snap = await task.whenComplete(null);

      expect(await getGsLink(snap.ref),
          equals('gs://some-bucket/someimage.png'));
      expect(storage.storedDataMap.containsKey('/$filename'), isTrue);
    });
  });
}

Future<String> getGsLink(Reference storageRef) async {
  return Uri(
    scheme: 'gs',
    host: storageRef.bucket,
    path: storageRef.fullPath,
  ).toString();
}
