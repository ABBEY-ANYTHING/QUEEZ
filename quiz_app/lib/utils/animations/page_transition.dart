import 'package:flutter/material.dart';
import 'package:quiz_app/utils/exceptions.dart';
import 'package:quiz_app/utils/routes.dart';

enum AnimationType {
  slideLeft,
  slideRight,
  slideUp,
  slideDown,
  fade,
  scale,
  rotation,
  bounce,
}

class PageTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final AnimationType animationType;

  const PageTransition({
    super.key,
    required this.child,
    required this.animation,
    required this.animationType,
  });

  @override
  Widget build(BuildContext context) {
    switch (animationType) {
      case AnimationType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case AnimationType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case AnimationType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case AnimationType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case AnimationType.fade:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      case AnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: child,
        );
      case AnimationType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.25, end: 0.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case AnimationType.bounce:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.bounceOut),
              ),
          child: child,
        );
    }
  }
}

Route customRoute(Widget page, AnimationType animationType) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return PageTransition(
        animation: animation,
        animationType: animationType,
        child: page,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

void customNavigate(
  BuildContext context,
  String routeName,
  AnimationType animationType, {
  Map<String, dynamic>? arguments,
  GlobalKey<NavigatorState>? navigatorKey, // Add this
}) {
  final builder = routeMap[routeName];
  if (builder != null) {
    final navigator = navigatorKey?.currentState ?? Navigator.of(context);
    navigator.push(
      PageRouteBuilder(
        settings: RouteSettings(arguments: arguments),
        pageBuilder: (context, animation, secondaryAnimation) {
          return PageTransition(
            animation: animation,
            animationType: animationType,
            child: builder(context),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  } else {
    throw RouteNotFoundException(routeName);
  }
}

void customNavigateReplacement(
  BuildContext context,
  String routeName,
  AnimationType animationType, {
  Map<String, dynamic>? arguments,
  GlobalKey<NavigatorState>? navigatorKey, // Add this
}) {
  final builder = routeMap[routeName];
  if (builder != null) {
    final navigator = navigatorKey?.currentState ?? Navigator.of(context);
    navigator.pushReplacement(
      PageRouteBuilder(
        settings: RouteSettings(arguments: arguments),
        pageBuilder: (context, animation, secondaryAnimation) {
          return PageTransition(
            animation: animation,
            animationType: animationType,
            child: builder(context),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  } else {
    throw RouteNotFoundException(routeName);
  }
}
