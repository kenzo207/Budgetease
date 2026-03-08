import 'package:flutter/material.dart';

class ZoltShadows {
  static List<BoxShadow> card() => const [
    BoxShadow(color: Color(0x0A0D0D0B), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x120D0D0B), blurRadius: 16, offset: Offset(0, 4), spreadRadius: -2),
  ];

  static List<BoxShadow> hero() => const [
    BoxShadow(color: Color(0x0A0D0D0B), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x1A0D0D0B), blurRadius: 32, offset: Offset(0, 8), spreadRadius: -4),
  ];

  static List<BoxShadow> glowPositive() => [
    ...card(),
    const BoxShadow(color: Color(0x4016A34A), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -4),
  ];

  static List<BoxShadow> glowWarning() => [
    ...card(),
    const BoxShadow(color: Color(0x38D97706), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -4),
  ];

  static List<BoxShadow> glowCritical() => [
    ...card(),
    const BoxShadow(color: Color(0x38DC2626), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -4),
  ];

  static List<BoxShadow> glowPremium() => const [
    BoxShadow(color: Color(0x4DC9973A), blurRadius: 24, offset: Offset(0, 6), spreadRadius: -4),
  ];

  static List<BoxShadow> button() => const [
    BoxShadow(color: Color(0x1F0D0D0B), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x140D0D0B), blurRadius: 2, offset: Offset(0, 1)),
  ];
}
