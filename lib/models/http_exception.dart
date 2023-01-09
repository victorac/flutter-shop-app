class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
  }
}

class PatchFavoriteItemException implements Exception {
  final String message = 'Failed to update favorite item';

  @override
  String toString() {
    return message;
  }
}
