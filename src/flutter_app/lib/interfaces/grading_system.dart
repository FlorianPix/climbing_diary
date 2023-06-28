
enum GradingSystem {
  usa, ukTech, ukAdj, french, uiaa, australia,	saxony, scandinavian, brasil,	fb
}

extension ToString on GradingSystem {
  String toShortString() {
    return toString().split('.').last;
  }
}