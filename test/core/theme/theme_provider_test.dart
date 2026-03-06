import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';

void main() {
  late ThemeViewModel viewModel;

  setUp(() {
    viewModel = ThemeViewModel();
  });

  test('should start with light mode by default', () {
    expect(viewModel.state.isDarkMode, false);
    expect(viewModel.state.isAutoThemeEnabled, false);
  });

  test('toggleTheme should flip isDarkMode', () {
    viewModel.toggleTheme();
    expect(viewModel.state.isDarkMode, true);
    
    viewModel.toggleTheme();
    expect(viewModel.state.isDarkMode, false);
  });

  test('setDarkMode should set specific mode', () {
    viewModel.setDarkMode(true);
    expect(viewModel.state.isDarkMode, true);
    
    viewModel.setDarkMode(false);
    expect(viewModel.state.isDarkMode, false);
  });

  test('toggleAutoTheme should flip isAutoThemeEnabled', () {
    viewModel.toggleAutoTheme();
    expect(viewModel.state.isAutoThemeEnabled, true);
  });
}
