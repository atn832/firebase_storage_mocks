import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/src/mock_storage_reference.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {
  final Map<String, File> storedFilesMap = {};
  final Map<String, Uint8List> storedDataMap = {};

  @override
  StorageReference ref() {
    return MockStorageReference(this);
  }
}

class MockStorageUploadTask extends Mock implements StorageUploadTask {
  final StorageReference reference;

  MockStorageUploadTask(this.reference);

  @override
  Future<StorageTaskSnapshot> get onComplete =>
      Future.value(MockStorageTaskSnapshot(reference));
}

class MockStorageTaskSnapshot extends Mock implements StorageTaskSnapshot {
  final StorageReference reference;

  MockStorageTaskSnapshot(this.reference);

  @override
  StorageReference get ref => reference;
}
