import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

/// Provider for bottom navbar selected index
@riverpod
class BottomNavIndex extends _$BottomNavIndex {
  @override
  int build() {
    return 0; // Default to first tab
  }

  void setIndex(int index) {
    state = index;
  }
}

/// Provider for tracking previous navigation index
@riverpod
class PreviousNavIndex extends _$PreviousNavIndex {
  @override
  int build() {
    return -1;
  }

  void setIndex(int index) {
    state = index;
  }
}

/// Provider for tracking keyboard visibility
@riverpod
class KeyboardVisible extends _$KeyboardVisible {
  @override
  bool build() {
    return false;
  }

  void setVisible(bool visible) {
    state = visible;
  }
}
