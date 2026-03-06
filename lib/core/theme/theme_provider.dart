
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeState {
  final bool isDarkMode;
  final bool isAutoThemeEnabled;

  ThemeState({
    required this.isDarkMode,
    this.isAutoThemeEnabled = false,
  });

  ThemeState copyWith({
    bool? isDarkMode,
    bool? isAutoThemeEnabled,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isAutoThemeEnabled: isAutoThemeEnabled ?? this.isAutoThemeEnabled,
    );
  }
}

class ThemeViewModel extends StateNotifier<ThemeState> {
  ThemeViewModel() : super(ThemeState(isDarkMode: false));

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setDarkMode(bool value) {
    if (state.isDarkMode != value) {
      state = state.copyWith(isDarkMode: value);
    }
  }

  void toggleAutoTheme() {
    state = state.copyWith(isAutoThemeEnabled: !state.isAutoThemeEnabled);
  }
}

final themeViewModelProvider = StateNotifierProvider<ThemeViewModel, ThemeState>((ref) {
  return ThemeViewModel();
});
