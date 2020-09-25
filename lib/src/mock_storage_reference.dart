import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:mockito/mockito.dart';

class MockStorageReference extends Mock implements StorageReference {
  final MockFirebaseStorage _storage;
  final String _path;
  final Map<String, MockStorageReference> children = {};

  MockStorageReference(this._storage, [this._path = '']);

  @override
  StorageReference child(String path) {
    if (!children.containsKey(path)) {
      children[path] = MockStorageReference(_storage, '$_path/$path');
    }
    return children[path];
  }

  @override
  StorageUploadTask putFile(File file, [StorageMetadata metadata]) {
    _storage.storedFilesMap[_path] = file;
    return MockStorageUploadTask(this);
  }

  @override
  StorageUploadTask putData(Uint8List data, [StorageMetadata metadata]) {
    _storage.storedDataMap[_path] = data;
    return MockStorageUploadTask(this);
  }

  @override
  Future<void> delete() {
    if (_storage.storedFilesMap.containsKey(_path)) {
      _storage.storedFilesMap.remove(_path);
    }
    if (_storage.storedDataMap.containsKey(_path)) {
      _storage.storedDataMap.remove(_path);
    }
    return Future.value();
  }

  @override
  String get path => _path;

  @override
  Future<String> getBucket() => Future.value('some-bucket');

  @override
  Future<String> getPath() => Future.value(_path);

  @override
  Future<String> getName() => Future.value(_path.split('/').last);

  @override
  FirebaseStorage getStorage() => _storage;

  @override
  StorageReference getRoot() => MockStorageReference(_storage);
}