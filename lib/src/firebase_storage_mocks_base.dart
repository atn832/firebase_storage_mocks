import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/src/mock_storage_reference.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {
  final Map<String, File> storedFilesMap = {};
  final Map<String, Uint8List> storedDataMap = {};

  @override
  Reference ref([String path]) {
    return MockStorageReference(this);
  }
}

class MockStorageUploadTask extends Mock implements UploadTask {
  final Reference reference;

  MockStorageUploadTask(this.reference);

  @override
  Future<TaskSnapshot> get onComplete =>
      Future.value(MockStorageTaskSnapshot(reference));
}

class MockStorageTaskSnapshot extends Mock implements TaskSnapshot {
  final Reference reference;

  MockStorageTaskSnapshot(this.reference);

  @override
  Reference get ref => reference;
}
