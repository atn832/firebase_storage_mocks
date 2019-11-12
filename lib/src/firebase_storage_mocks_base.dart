import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {
  final _ref = MockStorageReference();

  @override
  StorageReference ref() {
    return _ref;
  }
}

class MockStorageReference extends Mock implements StorageReference {
  final String _path;
  final Map<String, MockStorageReference> children = Map();
  File storedFile;

  MockStorageReference([this._path = '']);

  @override
  StorageReference child(String path) {
    if (!children.containsKey(path)) {
      children[path] = MockStorageReference('$_path/$path');
    }
    return children[path];
  }

  @override
  StorageUploadTask putFile(File file, [StorageMetadata metadata]) {
    storedFile = file;
    return MockStorageUploadTask();
  }

  @override
  String get path => _path;

  @override
  Future<String> getBucket() {
    return Future.value('some-bucket');
  }
}

class MockStorageUploadTask extends Mock implements StorageUploadTask {
  @override
  Future<StorageTaskSnapshot> get onComplete =>
      Future.value(MockStorageTaskSnapshot());
}

class MockStorageTaskSnapshot extends Mock implements StorageTaskSnapshot {}
