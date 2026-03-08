import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late ThemeViewModel viewModel;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    // Stub the getString and setString methods
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    
    viewModel = ThemeViewModel(mockPrefs);
  });

  test('should start with light mode by default', () {
    expect(viewModel.state.isDarkMode, false);
    expect(viewModel.state.isAutoThemeEnabled, false);
    expect(viewModel.state.themeMode, AppThemeMode.light);
  });

  test('toggleTheme should flip isDarkMode and persist', () async {
    viewModel.toggleTheme();
    expect(viewModel.state.isDarkMode, true);
    verify(() => mockPrefs.setString(any(), AppThemeMode.dark.name)).called(1);
    
    viewModel.toggleTheme();
    expect(viewModel.state.isDarkMode, false);
    verify(() => mockPrefs.setString(any(), AppThemeMode.light.name)).called(1);
  });

  test('setThemeMode should set specific mode and persist', () {
    viewModel.setThemeMode(AppThemeMode.dark);
    expect(viewModel.state.isDarkMode, true);
    expect(viewModel.state.themeMode, AppThemeMode.dark);
    verify(() => mockPrefs.setString(any(), AppThemeMode.dark.name)).called(1);
  });

  test('toggleAutoTheme should flip isAutoThemeEnabled', () {
    viewModel.toggleAutoTheme();
    expect(viewModel.state.isAutoThemeEnabled, true);
    expect(viewModel.state.themeMode, AppThemeMode.sensor);
  });
}
