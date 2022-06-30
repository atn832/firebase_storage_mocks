import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
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

    test('Set, get and update metadata', () async {
      final storage = MockFirebaseStorage();
      final storageRef = storage.ref().child(filename);
      final image = File(filename);
      final task = storageRef.putFile(image);
      await task;
      await storageRef.updateMetadata(SettableMetadata(
        cacheControl: 'public,max-age=300',
        contentType: 'image/jpeg',
        customMetadata: <String, String>{
          'userId': 'ABC123',
        },
      ));

      final metadata = await storageRef.getMetadata();
      expect(metadata.cacheControl == 'public,max-age=300', true);
      expect(metadata.contentType == 'image/jpeg', true);
      expect(metadata.customMetadata!['userId'] == 'ABC123', true);
      expect(metadata.name == storageRef.name, true);
      expect(metadata.fullPath == storageRef.fullPath, true);
      expect(metadata.timeCreated != null, true);

      await storageRef.updateMetadata(SettableMetadata(
        cacheControl: 'max-age=60',
        customMetadata: <String, String>{
          'userId': 'ABC123',
        },
      ));
      final metadata2 = await storageRef.getMetadata();
      expect(metadata2.cacheControl == 'max-age=60', true);
      ///Old informations persist over updates
      expect(metadata2.contentType == 'image/jpeg', true);
    });
  });
}
