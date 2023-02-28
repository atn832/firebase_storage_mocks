import 'dart:io';
import 'dart:typed_data';

import 'package:file/memory.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:test/test.dart';

final filename = 'someimage.png';

void main() {
  group('MockFirebaseStorage Tests', () {
    test('Puts File', () async {
      final storage = MockFirebaseStorage();
      final storageRef = storage.ref().child(filename);
      final task = storageRef.putFile(getFakeImageFile());
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
    // test for putString
    test('Puts String', () async {
      final storage = MockFirebaseStorage();
      final storageRef = storage.ref().child(filename);
      final task = storageRef.putString('some string');
      await task;

      expect(
          task.snapshot.ref.fullPath, equals('gs://some-bucket/someimage.png'));
      expect(storage.storedStringMap.containsKey('/$filename'), isTrue);
      expect(storage.storedStringMap['/$filename'], equals('some string'));
    });
    group('Gets Data', () {
      late MockFirebaseStorage storage;
      late Reference reference;
      final imageData = Uint8List(256);
      setUp(() async {
        storage = MockFirebaseStorage();
        reference = storage.ref().child(filename);
        final task = reference.putData(imageData);
        await task;
      });
      test('for valid reference', () async {
        final data = await reference.getData();
        expect(data, imageData);
      });
      test('for invalid reference', () async {
        final invalidReference = reference.child("invalid");
        final data = await invalidReference.getData();
        expect(data, isNull);
      });
    });

    test('Get download url', () async {
      final storage = MockFirebaseStorage();
      final downloadUrl = await storage.ref('/some/path').getDownloadURL();
      expect(downloadUrl.startsWith('http'), isTrue);
      expect(downloadUrl.contains('/some/path'), isTrue);
    });

    test('Ref from url', () async {
      final storage = MockFirebaseStorage();
      final downloadUrl = await storage.ref('/some/path').getDownloadURL();
      final ref = storage.refFromURL(downloadUrl);
      expect(ref, isA<Reference>());
    });
    test('Set, get and update metadata', () async {
      final storage = MockFirebaseStorage();
      final storageRef = storage.ref().child(filename);
      final task = storageRef.putFile(getFakeImageFile());
      await task;
      await storageRef.updateMetadata(SettableMetadata(
        cacheControl: 'public,max-age=300',
        contentType: 'image/jpeg',
        customMetadata: <String, String>{
          'userId': 'ABC123',
        },
      ));

      final metadata = await storageRef.getMetadata();
      expect(metadata.cacheControl, equals('public,max-age=300'));
      expect(metadata.contentType, equals('image/jpeg'));
      expect(metadata.customMetadata!['userId'], equals('ABC123'));
      expect(metadata.name, equals(storageRef.name));
      expect(metadata.fullPath, equals(storageRef.fullPath));
      expect(metadata.timeCreated, isNotNull);

      await storageRef.updateMetadata(SettableMetadata(
        cacheControl: 'max-age=60',
        customMetadata: <String, String>{
          'userId': 'ABC123',
        },
      ));
      final metadata2 = await storageRef.getMetadata();
      expect(metadata2.cacheControl, equals('max-age=60'));

      ///Old informations persist over updates
      expect(metadata2.contentType, equals('image/jpeg'));
    });

    test('Stream upload with snapshotEvents', () async {
      final storage = MockFirebaseStorage();
      final storageRef = storage.ref().child(filename);
      final task = storageRef.putFile(getFakeImageFile());

      task.snapshotEvents.listen((event) async {
        expect(event.state, equals(TaskState.success));

        final downloadUrl = await event.ref.getDownloadURL();

        expect(downloadUrl.startsWith('http'), isTrue);
        expect(downloadUrl.contains('some-bucket/o/someimage.png'), isTrue);
      });
    });
  });
}

File getFakeImageFile() {
  var fs = MemoryFileSystem();
  final image = fs.file(filename);
  image.writeAsStringSync('contents');
  return image;
}
