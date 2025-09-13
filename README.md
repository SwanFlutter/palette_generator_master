# Palette Generator Master

[![Pub Version](https://img.shields.io/pub/v/palette_generator_master.svg)](https://pub.dev/packages/palette_generator_master)
[![Flutter](https://img.shields.io/badge/Flutter-3.22.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.4.0+-blue.svg)](https://dart.dev/)

A powerful Flutter package for extracting prominent colors from images with advanced features including multi-color space support, accessibility compliance, and color harmony generation.

**This package is a complete rewrite and enhancement of the discontinued `palette_generator` package (0.3.3+7)** with modern Flutter development practices, enhanced performance, and new capabilities.

## ✨ Features

### 🎨 Advanced Color Extraction
- **Multi-color space support**: RGB, HSV, and LAB color spaces for more accurate analysis
- **Enhanced quantization algorithms** for better color clustering
- **Improved dominant color detection** with advanced scoring
- **Customizable target colors** (vibrant, muted, light, dark variations)

### ♿ Accessibility First
- **WCAG 2.1 compliance checking** for color contrast
- **Automatic contrast ratio calculation** between color pairs
- **Best text color selection** for any background color
- **Accessible color pair generation** with customizable contrast thresholds

### 🌈 Color Harmony
- **Automatic harmony generation** based on color theory principles
- **Complementary, analogous, and triadic** color schemes
- **Customizable harmony algorithms** for different design needs

### ⚡ Performance & Quality
- **Optimized algorithms** for faster processing
- **Memory-efficient** color analysis
- **Null safety** throughout the codebase
- **Modern Flutter practices** with comprehensive error handling

## 🚀 Getting Started

### Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  palette_generator_master: ^1.0.1
```

Then run:

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

// Generate palette from an image
Future<void> generatePalette() async {
  // Load your image
  final ImageProvider imageProvider = AssetImage('assets/my_image.jpg');
  
  // Generate palette
  final PaletteGeneratorMaster paletteGenerator = 
      await PaletteGeneratorMaster.fromImageProvider(
    imageProvider,
    maximumColorCount: 16,
    colorSpace: ColorSpace.lab, // Use LAB color space for better accuracy
    generateHarmony: true,      // Generate color harmony
  );
  
  // Access extracted colors
  final Color? dominantColor = paletteGenerator.dominantColor?.color;
  final Color? vibrantColor = paletteGenerator.vibrantColor?.color;
  final Color? mutedColor = paletteGenerator.mutedColor?.color;
  
  // Get all extracted colors
  final List<PaletteColorMaster> allColors = paletteGenerator.paletteColors;
  
  // Get harmony colors
  final List<Color> harmonyColors = paletteGenerator.harmonyColors;
}
```

### Advanced Usage

#### Custom Color Targets

```dart
final PaletteGeneratorMaster generator = 
    await PaletteGeneratorMaster.fromImageProvider(
  imageProvider,
  targets: [
    PaletteTargetMaster.vibrant,
    PaletteTargetMaster.darkVibrant,
    PaletteTargetMaster.lightMuted,
    // Create custom target
    PaletteTargetMaster(
      saturationWeight: 0.8,
      lightnessWeight: 0.6,
      populationWeight: 0.4,
      minimumSaturation: 0.3,
      maximumSaturation: 0.9,
      minimumLightness: 0.2,
      maximumLightness: 0.8,
    ),
  ],
);
```

#### Accessibility Features

```dart
// Get accessible color pairs
final List<AccessibleColorPair> accessiblePairs = 
    generator.getAccessibleColorPairs(
  minimumContrast: 4.5, // WCAG AA standard
  includeAAA: true,      // Include AAA level (7:1 ratio)
);

// Get best text color for a background
final Color backgroundColor = Colors.blue;
final Color textColor = generator.getBestTextColorFor(
  backgroundColor,
  minimumContrast: 4.5,
);

// Check contrast ratio between two colors
final double contrastRatio = AccessibilityHelper.calculateContrastRatio(
  Colors.white,
  Colors.blue,
);
```

#### Color Space Conversion

```dart
// Convert between color spaces
final LabColor labColor = ColorSpaceConverter.rgbToLab(Colors.red);
final HsvColor hsvColor = ColorSpaceConverter.rgbToHsv(Colors.green);
final Color rgbColor = ColorSpaceConverter.labToRgb(labColor);
```

#### Working with Different Image Sources

```dart
// From asset image
final generator1 = await PaletteGeneratorMaster.fromImageProvider(
  AssetImage('assets/image.jpg'),
);

// From network image
final generator2 = await PaletteGeneratorMaster.fromImageProvider(
  NetworkImage('https://example.com/image.jpg'),
);

// From ui.Image
final ui.Image image = await loadImageFromSomewhere();
final generator3 = await PaletteGeneratorMaster.fromImage(image);

// From byte data
final Uint8List bytes = await loadImageBytes();
final generator4 = await PaletteGeneratorMaster.fromByteData(
  bytes,
  EncodedImageFormat.png,
);
```

## 📱 Example App

The package includes a comprehensive example app that demonstrates all features:

- Interactive color space selection
- Real-time accessibility information
- Color harmony visualization
- Detailed color information with copy-to-clipboard
- Modern Material 3 design

To run the example:

```bash
cd example
flutter run
```

## 🎯 API Reference

### PaletteGeneratorMaster

The main class for generating color palettes from images.

#### Static Methods

```dart
// Generate from ImageProvider
static Future<PaletteGeneratorMaster> fromImageProvider(
  ImageProvider imageProvider, {
  int maximumColorCount = 16,
  ColorSpace colorSpace = ColorSpace.rgb,
  bool generateHarmony = false,
  List<PaletteTargetMaster>? targets,
  PaletteFilterMaster? filter,
})

// Generate from ui.Image
static Future<PaletteGeneratorMaster> fromImage(
  ui.Image image, {
  int maximumColorCount = 16,
  ColorSpace colorSpace = ColorSpace.rgb,
  bool generateHarmony = false,
  List<PaletteTargetMaster>? targets,
  PaletteFilterMaster? filter,
})

// Generate from byte data
static Future<PaletteGeneratorMaster> fromByteData(
  Uint8List data,
  EncodedImageFormat format, {
  int maximumColorCount = 16,
  ColorSpace colorSpace = ColorSpace.rgb,
  bool generateHarmony = false,
  List<PaletteTargetMaster>? targets,
  PaletteFilterMaster? filter,
})
```

#### Properties

```dart
// Target colors
PaletteColorMaster? get vibrantColor;
PaletteColorMaster? get lightVibrantColor;
PaletteColorMaster? get darkVibrantColor;
PaletteColorMaster? get mutedColor;
PaletteColorMaster? get lightMutedColor;
PaletteColorMaster? get darkMutedColor;
PaletteColorMaster? get dominantColor;

// All extracted colors
List<PaletteColorMaster> get paletteColors;

// Harmony colors (if generated)
List<Color> get harmonyColors;
```

#### Methods

```dart
// Get accessible color pairs
List<AccessibleColorPair> getAccessibleColorPairs({
  double minimumContrast = 4.5,
  bool includeAAA = false,
});

// Get best text color for background
Color getBestTextColorFor(
  Color backgroundColor, {
  double minimumContrast = 4.5,
});
```

### PaletteColorMaster

Represents a color in the palette with additional information.

```dart
class PaletteColorMaster {
  final Color color;
  final int population;
  
  // Accessibility helpers
  Color get titleTextColor;
  Color get bodyTextColor;
  
  // Color information
  double get hue;
  double get saturation;
  double get lightness;
}
```

### PaletteTargetMaster

Defines target characteristics for color extraction.

```dart
class PaletteTargetMaster {
  final double saturationWeight;
  final double lightnessWeight;
  final double populationWeight;
  final double minimumSaturation;
  final double maximumSaturation;
  final double minimumLightness;
  final double maximumLightness;
  
  // Predefined targets
  static const PaletteTargetMaster vibrant;
  static const PaletteTargetMaster lightVibrant;
  static const PaletteTargetMaster darkVibrant;
  static const PaletteTargetMaster muted;
  static const PaletteTargetMaster lightMuted;
  static const PaletteTargetMaster darkMuted;
}
```

## 🔄 Migration from palette_generator

If you're migrating from the discontinued `palette_generator` package:

### Class Name Changes

| Old Class | New Class |
|-----------|----------|
| `PaletteGenerator` | `PaletteGeneratorMaster` |
| `PaletteColor` | `PaletteColorMaster` |
| `PaletteTarget` | `PaletteTargetMaster` |
| `EncodedImage` | `EncodedImageMaster` |

### API Changes

```dart
// Old way
final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
  AssetImage('image.jpg'),
);

// New way
final PaletteGeneratorMaster generator = await PaletteGeneratorMaster.fromImageProvider(
  AssetImage('image.jpg'),
  colorSpace: ColorSpace.lab, // New: color space support
  generateHarmony: true,      // New: harmony generation
);
```

### New Features Not in Original

- Multi-color space support (RGB, HSV, LAB)
- Accessibility features and WCAG compliance
- Color harmony generation
- Enhanced performance and accuracy
- Modern null-safe API

## 🎨 Color Spaces

### RGB (Red, Green, Blue)
- **Best for**: General purpose, web colors
- **Characteristics**: Device-dependent, intuitive for developers
- **Use when**: Working with standard web/mobile colors

### HSV (Hue, Saturation, Value)
- **Best for**: Color manipulation, artistic applications
- **Characteristics**: More intuitive for humans, easier color adjustments
- **Use when**: Need to adjust brightness/saturation programmatically

### LAB (Lightness, A*, B*)
- **Best for**: Perceptually uniform color analysis
- **Characteristics**: Device-independent, perceptually uniform
- **Use when**: Need most accurate color analysis (recommended)

## ♿ Accessibility Guidelines

This package follows WCAG 2.1 guidelines:

### Contrast Ratios
- **AA Level**: 4.5:1 for normal text, 3:1 for large text
- **AAA Level**: 7:1 for normal text, 4.5:1 for large text

### Usage
```dart
// Check if colors meet WCAG AA
final bool isAccessible = AccessibilityHelper.meetsWCAG_AA(
  foreground: Colors.black,
  background: Colors.white,
);

// Get accessible pairs from palette
final accessiblePairs = generator.getAccessibleColorPairs(
  minimumContrast: 4.5,
);
```

## 🎯 Performance Tips

1. **Use appropriate color space**: LAB for accuracy, RGB for speed
2. **Limit maximum colors**: 16 colors usually sufficient
3. **Use filters**: Filter out unwanted colors early
4. **Cache results**: Store generated palettes for reuse

```dart
// Optimized for performance
final generator = await PaletteGeneratorMaster.fromImageProvider(
  imageProvider,
  maximumColorCount: 12,     // Reasonable limit
  colorSpace: ColorSpace.rgb, // Faster than LAB
  generateHarmony: false,     // Skip if not needed
  filter: avoidRedBlackWhitePaletteFilterMaster, // Filter unwanted colors
);
```

## 🐛 Troubleshooting

### Common Issues

**Q: Colors look different than expected**
A: Try using LAB color space for more perceptually accurate results.

**Q: Performance is slow**
A: Reduce `maximumColorCount` or use RGB color space instead of LAB.

**Q: Not getting vibrant colors**
A: Adjust the target parameters or use a custom `PaletteTargetMaster`.

**Q: Accessibility pairs are empty**
A: Lower the `minimumContrast` threshold or ensure your image has sufficient color variety.



**Made with ❤️ for the Flutter community**

*This package continues the legacy of the original palette_generator with modern enhancements and new capabilities.*
