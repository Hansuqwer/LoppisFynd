import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 110);
  static const normal = Duration(milliseconds: 180);

  static const spring = Duration(milliseconds: 450);
  static const springReverse = Duration(milliseconds: 380);

  static const curve = Curves.easeOutCubic;
}
