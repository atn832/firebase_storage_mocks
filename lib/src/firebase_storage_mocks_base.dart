import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/src/mock_storage_reference.dart';
import 'package:firebase_storage_mocks/src/utils.dart';

class MockFirebaseStorage implements FirebaseStorage {
  final storedDataMap = _StoredDataMap();
  final Map<String, Map<String, dynamic>> storedSettableMetadataMap = {};

  @override
  Reference ref([String? path]) {
    path ??= '/';
    return MockReference(this, path);
  }

  // Originally from https://github.com/firebase/flutterfire/blob/3dfc0997050ee4351207c355b2c22b46885f971f/packages/firebase_storage/firebase_storage/lib/src/firebase_storage.dart#L111.
  @override
  Reference refFromURL(String url) {
    assert(url.startsWith('gs://') || url.startsWith('http'),
        "'a url must start with 'gs://' or 'https://'");

    String? path;

    if (url.startsWith('http')) {
      final parts = partsFromHttpUrl(url);

      assert(parts != null,
          "url could not be parsed, ensure it's a valid storage url");

      path = parts!['path'];
    } else {
      path = pathFromGoogleStorageUrl(url);
    }
    return ref(path);
  }

  @override
  String get bucket => 'some-bucket';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUploadTask implements UploadTask {
  final Future<TaskSnapshot> delegate;
  final TaskSnapshot _snapshot;

  MockUploadTask(reference)
      : delegate = Future.value(MockTaskSnapshot(reference)),
        _snapshot = MockTaskSnapshot(reference);

  @override
  Future<S> then<S>(FutureOr<S> Function(TaskSnapshot) onValue,
          {Function? onError}) =>
      delegate.then(onValue, onError: onError);

  @override
  Stream<TaskSnapshot> asStream() {
    return delegate.asStream();
  }

  @override
  Future<TaskSnapshot> whenComplete(Function action) {
    return delegate;
  }

  @override
  Future<TaskSnapshot> timeout(Duration timeLimit,
      {FutureOr<TaskSnapshot> Function()? onTimeout}) {
    return delegate.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<TaskSnapshot> catchError(Function onError,
      {bool Function(Object error)? test}) {
    return delegate.catchError(onError, test: test);
  }

  @override
  Future<bool> cancel() {
    return Future.value(true);
  }

  @override
  Future<bool> resume() {
    return Future.value(true);
  }

  @override
  Future<bool> pause() {
    return Future.value(true);
  }

  @override
  TaskSnapshot get snapshot {
    return _snapshot;
  }

  @override
  Stream<TaskSnapshot> get snapshotEvents {
    return delegate.asStream();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTaskSnapshot implements TaskSnapshot {
  final Reference reference;

  MockTaskSnapshot(this.reference);

  @override
  Reference get ref => reference;

  @override
  TaskState get state => TaskState.success;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StoredDataMap {
  final _data = <String, dynamic>{};

  dynamic get(String key) {
    return _data[_normalizeKey(key)];
  }

  int getSize(String key) {
    final element = _data[_normalizeKey(key)];
    if (element is File) {
      return element.lengthSync();
    } else if (element is String) {
      return element.length;
    } else if (element is Uint8List) {
      return element.length;
    } else {
      return 0;
    }
  }

  void put(String key, dynamic value) => _data[_normalizeKey(key)] = value;

  dynamic remove(String key) {
    _data.remove(_normalizeKey(key));
  }

  Iterable<String> get keys => _data.keys;

  Iterable<dynamic> get values => _data.values;

  bool containsKey(String key) => _data.containsKey(_normalizeKey(key));

  String _normalizeKey(String key) {
    if (key.startsWith('/')) {
      return key.substring(1, key.length);
    } else {
      return key;
    }
  }
}
