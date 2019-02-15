class Utils {
  static bool isNumber(String value) {
    RegExp regExp = new RegExp(
      r"^-{0,1}\d+.{0,1}(\d+){0,1}$",
      caseSensitive: false,
      multiLine: false,
    );
    return (regExp.hasMatch(value) == true);
  }

  static bool isNotNumber(String value) {
    return (Utils.isNumber(value) == false);
  }
}
