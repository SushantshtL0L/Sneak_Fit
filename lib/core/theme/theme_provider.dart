import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/storage/user_session_service.dart';

enum AppThemeMode { light, dark, sensor }

class ThemeState {
  final bool isDarkMode;
  final bool isAutoThemeEnabled;
  final AppThemeMode themeMode;

  ThemeState({
    required this.isDarkMode,
    this.isAutoThemeEnabled = false,
    this.themeMode = AppThemeMode.light,
  });

  ThemeState copyWith({
    bool? isDarkMode,
    bool? isAutoThemeEnabled,
    AppThemeMode? themeMode,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isAutoThemeEnabled: isAutoThemeEnabled ?? this.isAutoThemeEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class ThemeViewModel extends StateNotifier<ThemeState> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'app_theme_mode';

  ThemeViewModel(this._prefs) : super(ThemeState(isDarkMode: false)) {
    _loadTheme();
  }

  void _loadTheme() {
    final modeName = _prefs.getString(_themeKey);
    if (modeName != null) {
      final mode = AppThemeMode.values.firstWhere(
        (e) => e.name == modeName,
        orElse: () => AppThemeMode.light,
      );
      setThemeMode(mode);
    }
  }

  void setThemeMode(AppThemeMode mode) {
    _prefs.setString(_themeKey, mode.name);
    
    switch (mode) {
      case AppThemeMode.light:
        state = state.copyWith(
          themeMode: mode,
          isDarkMode: false,
          isAutoThemeEnabled: false,
        );
        break;
      case AppThemeMode.dark:
        state = state.copyWith(
          themeMode: mode,
          isDarkMode: true,
          isAutoThemeEnabled: false,
        );
        break;
      case AppThemeMode.sensor:
        state = state.copyWith(
          themeMode: mode,
          isAutoThemeEnabled: true,
        );
        // Note: sensor will set isDarkMode once initialized
        break;
    }
  }

  void toggleTheme() {
    final nextDarkMode = !state.isDarkMode;
    final nextMode = nextDarkMode ? AppThemeMode.dark : AppThemeMode.light;
    setThemeMode(nextMode);
  }

  void setDarkMode(bool value) {
    if (state.isDarkMode != value) {
      state = state.copyWith(
        isDarkMode: value,
        themeMode: state.isAutoThemeEnabled 
            ? state.themeMode 
            : (value ? AppThemeMode.dark : AppThemeMode.light),
      );
    }
  }

  void toggleAutoTheme() {
    final nextAuto = !state.isAutoThemeEnabled;
    setThemeMode(nextAuto ? AppThemeMode.sensor : (state.isDarkMode ? AppThemeMode.dark : AppThemeMode.light));
  }
}

final themeViewModelProvider = StateNotifierProvider<ThemeViewModel, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeViewModel(prefs);
});
