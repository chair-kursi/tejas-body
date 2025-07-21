# Assets Directory

This directory contains all the static assets used in the Tejas Flutter app.

## Directory Structure

```
assets/
├── images/          # App images, illustrations, and graphics
│   ├── splash/      # Splash screen assets
│   ├── auth/        # Authentication flow images
│   ├── onboarding/  # Onboarding illustrations
│   └── common/      # Shared images
├── icons/           # App icons and UI icons
│   ├── navigation/  # Bottom navigation icons
│   ├── actions/     # Action button icons
│   └── status/      # Status and state icons
└── fonts/           # Custom fonts (if any)
    └── SF-Pro-Display/
```

## Image Guidelines

### Format Requirements
- **PNG**: For images with transparency
- **JPG**: For photos and complex images
- **SVG**: For scalable icons and simple graphics

### Size Guidelines
- **1x**: Base size for mdpi (Android) / 1x (iOS)
- **2x**: 2x size for xhdpi (Android) / 2x (iOS)
- **3x**: 3x size for xxhdpi (Android) / 3x (iOS)

### Naming Convention
- Use lowercase with underscores: `splash_illustration.png`
- Include size suffix for multiple resolutions: `icon_home_24.png`
- Use descriptive names: `auth_success_illustration.svg`

## Icon Guidelines

### Size Standards
- **16x16**: Small UI icons
- **24x24**: Standard UI icons
- **32x32**: Medium icons
- **48x48**: Large icons
- **64x64**: Extra large icons

### Color Guidelines
- Use the app's color palette from `app_colors.dart`
- Provide both light and dark variants if needed
- Use SVG for scalable icons when possible

## Adding New Assets

1. **Add the asset file** to the appropriate directory
2. **Update pubspec.yaml** if adding new directories
3. **Use consistent naming** following the guidelines above
4. **Optimize file sizes** before adding to the project

## Current Assets Needed

### Authentication Flow
- [ ] Splash screen illustration
- [ ] Login/signup illustration
- [ ] OTP verification illustration
- [ ] Success checkmark animation
- [ ] Profile setup illustration
- [ ] Role selection icons

### Onboarding Flow
- [ ] Language selection flags/icons
- [ ] Academic level illustrations
- [ ] Stream selection icons

### Common UI
- [ ] App logo (multiple sizes)
- [ ] Loading animations
- [ ] Error state illustrations
- [ ] Empty state illustrations

## Asset Optimization

### Tools Recommended
- **TinyPNG**: For PNG compression
- **SVGO**: For SVG optimization
- **ImageOptim**: For general image optimization

### Best Practices
- Compress images without losing quality
- Use appropriate formats for each use case
- Consider using vector graphics for scalable elements
- Test assets on different screen densities

## Usage in Code

### Loading Images
```dart
Image.asset('assets/images/splash/splash_illustration.png')
```

### Loading Icons
```dart
SvgPicture.asset('assets/icons/navigation/home.svg')
```

### Using in Theme
```dart
decoration: BoxDecoration(
  image: DecorationImage(
    image: AssetImage('assets/images/common/background.png'),
  ),
)
```
