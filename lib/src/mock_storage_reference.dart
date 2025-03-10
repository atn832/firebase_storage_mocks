import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_storage_mocks/src/mock_list_result.dart';

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
    _storage.storedDataMap.put(_path, file);
    _storage.storedSettableMetadataMap[_path] = metadata?.asMap() ?? {};
    return MockUploadTask(this);
  }

  @override
  UploadTask putData(Uint8List data, [SettableMetadata? metadata]) {
    _storage.storedDataMap.put(_path, data);
    _storage.storedSettableMetadataMap[_path] = metadata?.asMap() ?? {};
    return MockUploadTask(this);
  }

  @override
  UploadTask putString(
    String data, {
    PutStringFormat format = PutStringFormat.raw,
    SettableMetadata? metadata,
  }) {
    _storage.storedDataMap.put(_path, data);
    _storage.storedSettableMetadataMap[_path] = metadata?.asMap() ?? {};
    return MockUploadTask(this);
  }

  @override
  Future<void> delete() {
    if (_storage.storedDataMap.containsKey(_path)) {
      _storage.storedDataMap.remove(_path);
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
    final value = _storage.storedDataMap.get(_path);
    Uint8List? data;
    if (value is Uint8List) {
      data = value;
    } else if (value is File) {
      data = value.readAsBytesSync();
    } else if (value is String) {
      data = Uint8List.fromList(utf8.encode(value));
    }

    return Future.value(data);
  }

  @override
  Future<ListResult> listAll() {
    final normalizedPath = _path.endsWith('/') ? _path : _path + '/';
    final prefixes = <String>[], items = <String>[];

    for (var child in _storage.storedDataMap.keys) {
      if (!child.startsWith(normalizedPath)) continue;
      final relativeChild = child.substring(normalizedPath.length);
      if (relativeChild.contains('/')) {
        final prefix = normalizedPath + relativeChild.split('/')[0];
        if (!prefixes.contains(prefix)) prefixes.add(prefix);
      } else {
        items.add(child);
      }
    }
    prefixes.sort();
    items.sort();
    return Future.value(MockListResult(
        items: items.map((item) => MockReference(_storage, item)).toList(),
        prefixes:
            prefixes.map((prefix) => MockReference(_storage, prefix)).toList(),
        storage: _storage));
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
      'size': _storage.storedDataMap.values.fold<int>(0, (previousValue, element) {
        final int size;
        if (element is File) {
          size = element.lengthSync();
        } else if (element is String) {
          size = element.length;
        } else if (element is Uint8List) {
          size = element.length;
        } else {
          size = 0;
        }

        return previousValue + size;
      }),
      'creationTimeMillis': DateTime.now().millisecondsSinceEpoch,
      'updatedTimeMillis': DateTime.now().millisecondsSinceEpoch
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
