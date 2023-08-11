extension Filter<T> on Stream<List<T>> { // check the 'where' function in stream.dart
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
