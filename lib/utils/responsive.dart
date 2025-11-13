import 'package:flutter/widgets.dart';

/// Responsive utility class for adaptive layouts
/// Works across Mobile, Tablet, and Web (larger screens)
class Responsive {
  final BuildContext context;
  Responsive(this.context);

  // Screen width and height
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  /// Width percentage — example: wp(50) => 50% of screen width
  double wp(double percent) => width * percent / 100;

  /// Height percentage — example: hp(20) => 20% of screen height
  double hp(double percent) => height * percent / 100;

  /// Scalable text (sp) — adjusts text size based on screen size
  double sp(double size) {
    final base = (width + height) / 2;
    return size * base / 420; // baseline 420px for mobile scaling
  }

  /// 🔹 Device breakpoints
  bool get isMobile => width < 600; // small phones
  bool get isTablet => width >= 600 && width < 1024; // tablets
  bool get isDesktop => width >= 1024; // larger screens (web, desktop)

  /// 🔹 Dynamic grid count (handy for dashboards)
  int get gridCount {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }

  /// 🔹 Horizontal padding — responsive margin helper
  double get horizontalPadding {
    if (isDesktop) return 80;
    if (isTablet) return 40;
    return 16;
  }

  /// 🔹 Vertical padding
  double get verticalPadding {
    if (isDesktop) return 40;
    if (isTablet) return 24;
    return 16;
  }
}
