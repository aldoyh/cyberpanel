# CyberPanel Version Check and Dark Theme

This repository includes two new features for CyberPanel:

1. **Version Check Script** - A standalone bash script to check for updates
2. **Dark Theme** - A comprehensive dark theme with accessibility features

## Version Check Script

### Usage

The `version_check.sh` script fetches the latest CyberPanel version from GitHub and compares it with your current installation.

#### Standard Usage
```bash
./version_check.sh
```

#### Test Mode (for development/testing)
```bash
CYBERPANEL_TEST_MODE=1 ./version_check.sh
```

### Features

- ✅ Fetches latest version from cyberpanel.net/version.txt
- ✅ Compares with local installation
- ✅ Retrieves commit information from GitHub API
- ✅ Provides clear upgrade instructions
- ✅ Colorized output for better readability
- ✅ Supports both production and development environments
- ✅ Exit codes: 0 (up to date), 1 (update available/error)

### Installation Paths

The script automatically detects:
- Production: `/usr/local/CyberCP/`
- Development: Current directory

## Dark Theme

### Features

The `cyberpanel_dark_theme.css` provides a comprehensive dark theme for CyberPanel with:

- 🌙 **Dark color scheme** - Easy on the eyes
- 🎨 **High contrast** - Improved readability
- ♿ **Accessibility features** - WCAG compliant
- 📱 **Responsive design** - Mobile-friendly
- 🎯 **Focus indicators** - Keyboard navigation support
- 🎪 **Reduced motion** - Respects user preferences
- 🔧 **CSS variables** - Easy customization

### Color Palette

```css
:root {
    --bg-primary: #0d1117;      /* Main background */
    --bg-secondary: #161b22;    /* Cards, panels */
    --bg-tertiary: #21262d;     /* Headers, inputs */
    --text-primary: #f0f6fc;    /* Main text */
    --text-secondary: #8b949e;  /* Secondary text */
    --accent-color: #238636;    /* Primary accent */
    --border-color: #30363d;    /* Borders */
}
```

### Integration

To use the dark theme, add it to your CyberPanel installation:

1. **Via the Design Interface:**
   - Go to Main > Design
   - Select a theme or add custom CSS
   - Copy the contents of `cyberpanel_dark_theme.css`

2. **Manual Installation:**
   ```bash
   cp cyberpanel_dark_theme.css /usr/local/CyberCP/public/static/
   ```

### Compatibility

- ✅ Compatible with CyberPanel v2.4+
- ✅ Works with existing theme system
- ✅ Supports all major browsers
- ✅ Mobile responsive
- ✅ High contrast mode support

## Testing

Run the included test suite:

```bash
./test_cyberpanel_features.sh
```

### Test Coverage

- ✅ Version check script functionality
- ✅ Dark theme CSS validation
- ✅ Syntax checking
- ✅ Accessibility features
- ✅ File permissions

## Files

- `version_check.sh` - Version comparison script
- `cyberpanel_dark_theme.css` - Dark theme stylesheet
- `test_cyberpanel_features.sh` - Test suite
- `README_FEATURES.md` - This documentation

## Requirements

### Version Check Script
- bash 4.0+
- curl
- git (for commit comparison)
- Internet connection (or test mode)

### Dark Theme
- Modern web browser
- CyberPanel v2.4+
- CSS3 support

## Examples

### Version Check Output

```
==========================================
    CyberPanel Version Check Script
==========================================

[INFO] Using development version file: ./version.txt
[INFO] Using development git repository
[INFO] Fetching latest version information...
[SUCCESS] Latest version: 2.4 (Build 4)

==========================================
         VERSION COMPARISON
==========================================

CURRENT VERSION:
  Version: 2.4
  Build:   3
  Commit:  dc4bccfa...

LATEST VERSION:
  Version: 2.4
  Build:   4
  Commit:  abcd1234...

⚠ A newer version is available!
  Current: v2.4.3
  Latest:  v2.4.4
==========================================
```

### Dark Theme Preview

The dark theme provides:
- Dark backgrounds with proper contrast ratios
- Consistent styling across all components
- Smooth hover effects and transitions
- Accessibility-compliant focus indicators
- Support for system preferences (dark mode, reduced motion)

## Contributing

When modifying these features:

1. Update tests in `test_cyberpanel_features.sh`
2. Ensure backward compatibility
3. Test accessibility features
4. Update documentation

## License

These features are provided under the same license as CyberPanel.