extension AlternatableLength on List {
  /// Returns `true` if this string is `null` or empty.
  int lengthOrShorter(int maxLength) {
    if (length > maxLength) {
      return maxLength;
    } else {
      return length;
    }
  }
}
