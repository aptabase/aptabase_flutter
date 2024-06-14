import "dart:math";

class RandomString {
  static final _rnd = Random();

  static String randomize() {
    final epochInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final random = _rnd.nextInt(100000000).toString().padLeft(8, "0");

    return "$epochInSeconds$random";
  }
}
