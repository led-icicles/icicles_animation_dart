void debugLog(String string) {
  assert((() {
    print(string);
    return true;
  })());
}
