import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/CreateSection/screens/create_page.dart';
import 'package:quiz_app/LibrarySection/screens/library_page.dart';
import 'package:quiz_app/ProfilePage/profile_page.dart';
import 'package:quiz_app/providers/navigation_provider.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/custom_navigator.dart';
import 'package:quiz_app/widgets/navbar/create_button.dart';
import 'package:quiz_app/widgets/navbar/navbar_shape.dart';

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
  late FloatingActionButtonLocation _fabLocation;

  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Widget> _sections = [LibraryPage(), CreatePage()];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _pages = [
      const Center(key: ValueKey("Home"), child: Text("Home Page")),
      CreateNavigator(navigatorKey: navigatorKeys[1], widget: _sections[0]),
      CreateNavigator(navigatorKey: navigatorKeys[2], widget: _sections[1]),
      const ProfilePage(),
      const Center(key: ValueKey("Settings"), child: Text("Settings Page")),
    ];
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double offset = MediaQuery.of(context).size.height * 0.030;
    _fabLocation = CreateButtonLocation(offset: offset);
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: List.generate(_pages.length, _buildTransitioningPage),
      ),
      floatingActionButton: CreateButton(onPressed: () => _onNavItemTapped(2)),
      floatingActionButtonLocation: _fabLocation,
      bottomNavigationBar: _BottomNavbar(
        currentIndex: selectedIndex,
        onTap: _onNavItemTapped,
      ),
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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.65),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, -4),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            shape: NavbarShape(),
            notchMargin: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _navIcon(Icons.dashboard_rounded, 0, 'Home'),
                  _navIcon(Icons.menu_book_rounded, 1, 'Library'),
                  const SizedBox(width: 40), // FAB space
                  _navIcon(Icons.person_rounded, 3, 'Profile'),
                  _navIcon(Icons.settings_rounded, 4, 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index, String tooltip) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (!isActive) onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppColors.accentBright.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: isActive ? 1.0 : 0.9, end: isActive ? 1.25 : 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Tooltip(
                message: tooltip,
                child: Icon(
                  icon,
                  size: 28,
                  color:
                      isActive
                          ? AppColors.accentBright
                          : AppColors.iconInactive,
                  shadows:
                      isActive
                          ? [
                            const Shadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ]
                          : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
