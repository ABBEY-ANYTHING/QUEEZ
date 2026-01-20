import 'package:flutter/material.dart';

/// Custom clipper for the thumbnail with organic shape
class ThumbnailShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Create an organic blob-like shape
    path.moveTo(w * 0.1, h * 0.05);
    path.quadraticBezierTo(w * 0.5, 0, w * 0.9, h * 0.08);
    path.quadraticBezierTo(w, h * 0.15, w * 0.95, h * 0.4);
    path.quadraticBezierTo(w, h * 0.6, w * 0.92, h * 0.85);
    path.quadraticBezierTo(w * 0.85, h, w * 0.5, h * 0.95);
    path.quadraticBezierTo(w * 0.15, h, w * 0.08, h * 0.85);
    path.quadraticBezierTo(0, h * 0.7, 0, h * 0.5);
    path.quadraticBezierTo(0, h * 0.2, w * 0.1, h * 0.05);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Custom clipper for the decorative accent shape
class AccentShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Create a flowing wave shape
    path.moveTo(w * 0.3, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h * 0.6);
    path.quadraticBezierTo(w * 0.7, h * 0.8, w * 0.4, h * 0.5);
    path.quadraticBezierTo(w * 0.1, h * 0.2, w * 0.3, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
