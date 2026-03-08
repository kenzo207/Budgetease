import 'package:flutter/material.dart';

/// Zolt - Design System v3 Animations
/// Règle stricte : jamais de `Curves.bounceOut` ni de spring exagéré.
/// L'animation doit sembler intentionnelle et sobre.
class ZoltAnimations {
  // ── Durations ──
  static const durationFast     = Duration(milliseconds: 110); // Tap card
  static const durationShort    = Duration(milliseconds: 200); // Transition écran, toast sortie
  static const durationMedium   = Duration(milliseconds: 280); // Toast entrée
  static const durationStandard = Duration(milliseconds: 340); // Bottom sheet in
  static const durationSlow     = Duration(milliseconds: 700); // Progress fill, Count up
  static const durationVerySlow = Duration(milliseconds: 900); // Arc draw
  static const durationLoop     = Duration(milliseconds: 1600); // Shimmer

  // ── Curves ──
  static const curveEntrance   = Curves.easeOutCubic; // Bottom sheet in, Progress fill
  static const curveExit       = Curves.easeInCubic;  // Bottom sheet out
  static const curveTransition = Curves.easeInOut;    // Screen transition
  static const curveTap        = Curves.easeOut;      // Scale on tap
  static const curveCountUp    = Curves.easeOutExpo;  // Count up value
  static const curveLinear     = Curves.linear;       // Loop / Shimmer
}
