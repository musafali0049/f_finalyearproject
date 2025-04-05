// responsive_helper.dart
import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Screen width ka ratio ke hisaab se value return karta hai
  static double width(BuildContext context, double ratio) {
    return MediaQuery.of(context).size.width * ratio;
  }

  // Screen height ka ratio ke hisaab se value return karta hai
  static double height(BuildContext context, double ratio) {
    return MediaQuery.of(context).size.height * ratio;
  }
}
