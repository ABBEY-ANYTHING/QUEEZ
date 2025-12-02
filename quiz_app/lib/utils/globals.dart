// globals.dart
import 'package:flutter/material.dart';
import 'package:quiz_app/widgets/navbar/bottom_navbar.dart';

final GlobalKey<BottomNavbarControllerState> bottomNavbarKey =
    GlobalKey<BottomNavbarControllerState>();

/// Height of the bottom navbar including safe area padding.
/// Use this to add bottom padding to scrollable content that sits behind the navbar.
const double kBottomNavbarHeight = 100.0;
