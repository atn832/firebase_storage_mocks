import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

class MockReference implements Reference {
  final MockFirebaseStorage _storage;
  final String _path;
  final Map<String, MockReference> children = {};

  MockReference(this._storage, [this._path = '']);

  @override
  Reference child(String path) {
    if (!children.containsKey(path)) {
      children[path] = MockReference(_storage, '$_path$path');
    }
    return children[path]!;
  }

  @override
  UploadTask putFile(File file, [SettableMetadata? metadata]) {
    _storage.storedFilesMap[_path] = file;
    _storage.storedSettableMetadataMap[_path] = metadata?.asMap() ?? {};
    return MockUploadTask(this);
  }

  @override
  UploadTask putData(Uint8List data, [SettableMetadata? metadata]) {
    _storage.storedDataMap[_path] = data;
    _storage.storedSettableMetadataMap[_path] = metadata?.asMap() ?? {};
    return MockUploadTask(this);
  }

  @override
  Future<void> delete() {
    if (_storage.storedFilesMap.containsKey(_path)) {
      _storage.storedFilesMap.remove(_path);
    }
    if (_storage.storedDataMap.containsKey(_path)) {
      _storage.storedDataMap.remove(_path);
    }
    if (_storage.storedSettableMetadataMap.containsKey(_path)) {
      _storage.storedSettableMetadataMap.remove(_path);
    }
    return Future.value();
  }

  @override
  String get bucket {
    return _storage.bucket;
  }

  @override
  String get fullPath {
    return 'gs://${_storage.bucket}$_path';
  }

  @override
  String get name {
    return _path.split('/').last;
  }

  @override
  Reference? get parent {
    if (_path.split('/').length <= 1) {
      return null;
    } else {
      final sections = _path.split('/');
      return MockReference(_storage, sections[sections.length - 2]);
    }
  }

  @override
  Reference get root {
    return MockReference(_storage, '/');
  }

  @override
  Future<String> getDownloadURL() {
    final path = _path.startsWith('/') ? _path : '/$_path';
    return Future.value(
        'https://firebasestorage.googleapis.com/v0/b/$bucket/o$path');
  }

  @override
  Future<Uint8List?> getData([int maxSize = 10485760]) {
    return Future.value(_storage.storedDataMap[_path]);
  }

  @override
  Future<FullMetadata> updateMetadata(SettableMetadata metadata) {
    final nonNullMetadata = metadata.asMap()
      ..removeWhere((key, value) => value == null);
    _storage.storedSettableMetadataMap[_path]?.addAll(nonNullMetadata);
    return getMetadata();
  }

  @override
  Future<FullMetadata> getMetadata() {
    final metadata = _getGeneratedMetadata();
    metadata.addAll(_storage.storedSettableMetadataMap[_path] ?? {});
    return Future.value(FullMetadata(metadata));
  }

  Map<String, dynamic> _getGeneratedMetadata() {
    return {
      'bucket': bucket,
      'fullPath': fullPath,
      'metadataGeneration': 'metadataGeneration',
      'md5Hash': 'md5Hash',
      'metageneration': 'metageneration',
      'name': name,
      'size': _storage.storedDataMap[_path]?.lengthInBytes ??
          _storage.storedFilesMap[_path]!.lengthSync(),
      'creationTimeMillis': DateTime.now().millisecondsSinceEpoch,
      'updatedTimeMillis': DateTime.now().millisecondsSinceEpoch
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
