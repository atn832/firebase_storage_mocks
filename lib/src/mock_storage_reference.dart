import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:mockito/mockito.dart';

class MockReference extends Mock implements Reference {
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
    _storage.storedMetadata[_path] = _createFullMetadata(metadata);
    return MockUploadTask(this);
  }

  @override
  UploadTask putData(Uint8List data, [SettableMetadata? metadata]) {
    _storage.storedDataMap[_path] = data;
    _storage.storedMetadata[_path] = _createFullMetadata(metadata);
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
    if (_storage.storedMetadata.containsKey(_path)) {
      _storage.storedMetadata.remove(_path);
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
  Future<Uint8List> getData([int maxSize = 10485760]) {
    return Future.value(_storage.storedDataMap[_path]);
  }

  @override
  Future<FullMetadata> updateMetadata(SettableMetadata metadata) {
    // ignore: omit_local_variable_types
    final newSettable = _getNewSettableFromFullMetadata(_storage.storedMetadata[_path], metadata);
    _storage.storedMetadata[_path] = _createFullMetadata(newSettable);
    return Future<FullMetadata>.value(_storage.storedMetadata[_path]);
  }

  FullMetadata _createFullMetadata(SettableMetadata? metadata) {
    // ignore: omit_local_variable_types
    final Map<String, dynamic> newMetadata = metadata?.asMap() ?? <String, dynamic>{};
    final a = _storage.storedMetadata[_path]; //Riguarda customMetadata

    newMetadata['bucket'] = _storage.storedMetadata[_path]?.bucket ?? bucket;
    newMetadata['fullPath'] = _storage.storedMetadata[_path]?.fullPath ?? fullPath;
    newMetadata['metadataGeneration'] = _storage.storedMetadata[_path]?.metadataGeneration ?? 'metadataGeneration';
    newMetadata['md5Hash'] = _storage.storedMetadata[_path]?.md5Hash ?? 'md5Hash' ;
    newMetadata['metageneration'] = _storage.storedMetadata[_path]?.metadataGeneration ?? 'metageneration';
    newMetadata['name'] = _storage.storedMetadata[_path]?.name ?? name;
    newMetadata['size'] = _storage.storedMetadata[_path]?.size 
      ?? _storage.storedDataMap[_path]?.lengthInBytes ?? _storage.storedFilesMap[_path]!.lengthSync();
    newMetadata['creationTimeMillis'] = _storage.storedMetadata[_path]?.timeCreated?.millisecondsSinceEpoch 
      ?? DateTime.now().millisecondsSinceEpoch;
    newMetadata['updatedTimeMillis'] = DateTime.now().millisecondsSinceEpoch;
    return FullMetadata(newMetadata);
  }

  SettableMetadata _getNewSettableFromFullMetadata(FullMetadata? fullMetadata, SettableMetadata settableMetadata) {
    return SettableMetadata(
      cacheControl: settableMetadata.cacheControl ?? fullMetadata?.cacheControl,
      contentDisposition: settableMetadata.contentDisposition ?? fullMetadata?.contentDisposition,
      contentEncoding: settableMetadata.contentEncoding ?? fullMetadata?.contentEncoding,
      contentLanguage: settableMetadata.contentLanguage ?? fullMetadata?.contentLanguage,
      contentType: settableMetadata.contentType ?? fullMetadata?.contentType,
      customMetadata: settableMetadata.customMetadata ?? fullMetadata?.customMetadata
    );
  }

  @override
  Future<FullMetadata> getMetadata() {
    return Future<FullMetadata>.value(_storage.storedMetadata[_path]);
  }
}
