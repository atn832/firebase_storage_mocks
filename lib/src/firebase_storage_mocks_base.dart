import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/src/mock_storage_reference.dart';
import 'package:firebase_storage_mocks/src/utils.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {
  final Map<String, File> storedFilesMap = {};
  final Map<String, Uint8List> storedDataMap = {};
  final Map<String, Map<String, dynamic>> storedSettableMetadataMap = {};

  @override
  Reference ref([String? path]) {
    path ??= '/';
    return MockReference(this, path);
  }

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
}

class MockUploadTask extends Mock implements UploadTask {
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
}

class MockTaskSnapshot extends Mock implements TaskSnapshot {
  final Reference reference;

  MockTaskSnapshot(this.reference);

  @override
  Reference get ref => reference;
}
