class File {
  final String path;
  File(this.path);

  Future<File> writeAsBytes(List<int> bytes, {bool flush = false}) async => this;
}

class Directory {
  final String path;
  Directory(this.path);
}

Never exit(int code) =>
    throw UnsupportedError('exit is not supported on web');
