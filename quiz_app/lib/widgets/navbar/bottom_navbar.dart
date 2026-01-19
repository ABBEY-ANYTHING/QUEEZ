import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/CreateSection/screens/create_page.dart';
import 'package:quiz_app/LibrarySection/screens/library_page.dart';
import 'package:quiz_app/ProfilePage/profile_page.dart';
import 'package:quiz_app/providers/navigation_provider.dart';
import 'package:quiz_app/screens/home_page.dart';
import 'package:quiz_app/screens/settings_page.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/custom_navigator.dart';

class BottomNavbarController extends ConsumerStatefulWidget {
  const BottomNavbarController({super.key});

  @override
  ConsumerState<BottomNavbarController> createState() =>
      BottomNavbarControllerState();
}

class BottomNavbarControllerState extends ConsumerState<BottomNavbarController>
    with TickerProviderStateMixin {
  final List<GlobalKey<NavigatorState>> navigatorKeys = List.generate(
    5,
    (index) => GlobalKey<NavigatorState>(),
  );
  late final List<Widget> _pages;

  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _navbarAnimController;
  late Animation<Offset> _navbarSlideAnimation;
  late Animation<double> _navbarFadeAnimation;
  bool _isKeyboardVisible = false;
  final List<Widget> _sections = [LibraryPage(), CreatePage()];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Navbar show/hide animation
    _navbarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _navbarSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)).animate(
          CurvedAnimation(
            parent: _navbarAnimController,
            curve: Curves.easeInOut,
          ),
        );
    _navbarFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _navbarAnimController, curve: Curves.easeInOut),
    );

    _pages = [
      const HomePage(),
      CreateNavigator(navigatorKey: navigatorKeys[1], widget: _sections[0]),
      CreateNavigator(navigatorKey: navigatorKeys[2], widget: _sections[1]),
      const ProfilePage(),
      const SettingsPage(),
    ];
    _controller.forward();
  }

  void _onNavItemTapped(int index) {
    final currentIndex = ref.read(bottomNavIndexProvider);
    if (index != currentIndex) {
      ref.read(previousNavIndexProvider.notifier).setIndex(currentIndex);
      ref.read(bottomNavIndexProvider.notifier).setIndex(index);
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _navbarAnimController.dispose();
    super.dispose();
  }

  AnimationType _getAnimationType(int previous, int current) {
    if (current == 2) return AnimationType.fade;
    if (current - previous >= 1) return AnimationType.slideLeft;
    return AnimationType.slideRight;
  }

  Widget _buildTransitioningPage(int index) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final previousIndex = ref.watch(previousNavIndexProvider);
    final bool isActive = index == selectedIndex;
    final animationType = _getAnimationType(previousIndex, selectedIndex);

    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: PageTransition(
          animation: _animation,
          animationType: animationType,
          child: _pages[index],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // Animate navbar based on keyboard visibility
    if (keyboardVisible && !_isKeyboardVisible) {
      _isKeyboardVisible = true;
      _navbarAnimController.forward();
    } else if (!keyboardVisible && _isKeyboardVisible) {
      _isKeyboardVisible = false;
      _navbarAnimController.reverse();
    }

    return Stack(
      children: [
        // Pages
        ...List.generate(_pages.length, _buildTransitioningPage),
        // Bottom navbar positioned at bottom
        if (!keyboardVisible)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SlideTransition(
              position: _navbarSlideAnimation,
              child: FadeTransition(
                opacity: _navbarFadeAnimation,
                child: _BottomNavbar(
                  currentIndex: selectedIndex,
                  onTap: _onNavItemTapped,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void setIndex(int index) {
    _onNavItemTapped(index);
  }

  bool canPopCurrentNavigator() {
    final selectedIndex = ref.read(bottomNavIndexProvider);
    final navigatorKey = navigatorKeys[selectedIndex];
    return navigatorKey.currentState?.canPop() ?? false;
  }

  void popCurrentNavigator() {
    final selectedIndex = ref.read(bottomNavIndexProvider);
    final navigatorKey = navigatorKeys[selectedIndex];
    navigatorKey.currentState?.pop();
  }
}

class _BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavbar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 1),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _NavItem(
            icon: Icons.shopping_cart_outlined,
            label: 'Store',
            index: 0,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.library_books_rounded,
            label: 'Library',
            index: 1,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _CreateButton(index: 2, currentIndex: currentIndex, onTap: onTap),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            index: 3,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            index: 4,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

// Individual nav item with spring animation and haptics
class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _handleTap() {
    if (widget.index != widget.currentIndex) {
      // Trigger haptic feedback
      HapticFeedback.lightImpact();
      widget.onTap(widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.currentIndex == widget.index;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon with scale effect
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: isActive ? 1.0 : 1.15,
                  end: isActive ? 1.15 : 1.0,
                ),
                duration: const Duration(milliseconds: 250),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    begin: isActive
                        ? AppColors.textSecondary
                        : AppColors.primary,
                    end: isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, color, _) {
                    return Icon(widget.icon, size: 24, color: color);
                  },
                ),
              ),
              const SizedBox(height: 6),
              // Label with animated color
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  begin: isActive ? AppColors.textSecondary : AppColors.primary,
                  end: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                duration: const Duration(milliseconds: 200),
                builder: (context, color, _) {
                  return Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                      letterSpacing: 0.2,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              // Animated indicator dot
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isActive ? 1.0 : 0.0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  scale: isActive ? 1.0 : 0.0,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Special Create button with floating effect
class _CreateButton extends StatefulWidget {
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CreateButton({
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<_CreateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    // Trigger medium haptic for create button
    HapticFeedback.mediumImpact();
    widget.onTap(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.currentIndex == widget.index;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryDark : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    offset: Offset(0, _elevationAnimation.value / 2),
                    blurRadius: _elevationAnimation.value,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle ring animation when active
                  if (isActive)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, _) {
                        return Container(
                          width: 52 + (value * 8),
                          height: 52 + (value * 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(
                                alpha: 0.2 * (1 - value * 0.5),
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  // Animated plus icon with rotation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: isActive ? 0.0 : 0.125,
                      end: isActive ? 0.125 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    builder: (context, rotation, child) {
                      return Transform.rotate(
                        angle: rotation * 3.14159,
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.add_rounded,
                      size: 28,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
