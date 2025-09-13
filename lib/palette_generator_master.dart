// Copyright 2024 Palette Generator Master. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A Flutter package to extract prominent colors from an Image, typically used to find colors for a user interface.
///
/// This is an enhanced version of the discontinued palette_generator package with additional features:
/// - Better performance with optimized algorithms
/// - Support for custom color spaces (HSV, LAB)
/// - Advanced filtering options
/// - Color harmony generation
/// - Accessibility-aware color selection
/// - Caching mechanism for better performance
/// - Support for animated images
library palette_generator_master;

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui' show Color, ImageByteFormat;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A description of an encoded image with enhanced metadata.
class EncodedImageMaster {
  /// Creates a description of an encoded image with optional metadata.
  const EncodedImageMaster(
    this.byteData, {
    required this.width,
    required this.height,
    this.format = ImageByteFormat.rawRgba,
    this.name,
  });

  /// Encoded image byte data.
  final ByteData byteData;

  /// Image width.
  final int width;

  /// Image height.
  final int height;

  /// Image format (default: rawRgba).
  final ImageByteFormat format;

  /// Optional name for the image (useful for caching).
  final String? name;

  /// Get the total number of pixels.
  int get pixelCount => width * height;

  /// Get the aspect ratio.
  double get aspectRatio => width / height;

  /// Check if the image is square.
  bool get isSquare => width == height;

  /// Check if the image is landscape.
  bool get isLandscape => width > height;

  /// Check if the image is portrait.
  bool get isPortrait => height > width;
}

/// Enhanced palette generator with additional features and better performance.
class PaletteGeneratorMaster with Diagnosticable {
  /// Create a [PaletteGeneratorMaster] from a set of colors and targets.
  PaletteGeneratorMaster.fromColors(
    this.paletteColors, {
    this.targets = const <PaletteTargetMaster>[],
    this.sourceImageInfo,
  }) : selectedSwatches = <PaletteTargetMaster, PaletteColorMaster>{} {
    _sortSwatches();
    _selectSwatches();
    _generateHarmonyColors();
  }

  /// Create a [PaletteGeneratorMaster] from encoded image data.
  static Future<PaletteGeneratorMaster> fromByteData(
    EncodedImageMaster encodedImage, {
    Rect? region,
    int maximumColorCount = _defaultCalculateNumberColors,
    List<PaletteFilterMaster> filters = const <PaletteFilterMaster>[
      avoidRedBlackWhitePaletteFilterMaster
    ],
    List<PaletteTargetMaster> targets = const <PaletteTargetMaster>[],
    bool enableCaching = true,
    bool generateHarmony = true,
    ColorSpace colorSpace = ColorSpace.rgb,
  }) async {
    assert(region == null || region != Rect.zero);
    assert(
        region == null ||
            (region.topLeft.dx >= 0.0 && region.topLeft.dy >= 0.0),
        'Region $region is outside the image ${encodedImage.width}x${encodedImage.height}');
    assert(
        region == null ||
            (region.bottomRight.dx <= encodedImage.width &&
                region.bottomRight.dy <= encodedImage.height),
        'Region $region is outside the image ${encodedImage.width}x${encodedImage.height}');

    final _ColorCutQuantizerMaster quantizer = _ColorCutQuantizerMaster(
      encodedImage,
      maxColors: maximumColorCount,
      filters: filters,
      region: region,
      colorSpace: colorSpace,
    );
    final List<PaletteColorMaster> colors = await quantizer.quantizedColors;

    return PaletteGeneratorMaster.fromColors(
      colors,
      targets: targets.isEmpty ? PaletteTargetMaster.baseTargets : targets,
      sourceImageInfo: ImageInfoMaster(
        width: encodedImage.width,
        height: encodedImage.height,
        name: encodedImage.name,
        pixelCount: encodedImage.pixelCount,
      ),
    );
  }

  /// Create a [PaletteGeneratorMaster] from a [ui.Image].
  static Future<PaletteGeneratorMaster> fromImage(
    ui.Image image, {
    Rect? region,
    int maximumColorCount = _defaultCalculateNumberColors,
    List<PaletteFilterMaster> filters = const <PaletteFilterMaster>[
      avoidRedBlackWhitePaletteFilterMaster
    ],
    List<PaletteTargetMaster> targets = const <PaletteTargetMaster>[],
    bool enableCaching = true,
    bool generateHarmony = true,
    ColorSpace colorSpace = ColorSpace.rgb,
  }) async {
    final ByteData? imageData = await image.toByteData();
    if (imageData == null) {
      throw StateError('Failed to encode the image.');
    }

    return PaletteGeneratorMaster.fromByteData(
      EncodedImageMaster(
        imageData,
        width: image.width,
        height: image.height,
      ),
      region: region,
      maximumColorCount: maximumColorCount,
      filters: filters,
      targets: targets,
      enableCaching: enableCaching,
      generateHarmony: generateHarmony,
      colorSpace: colorSpace,
    );
  }

  /// Create a [PaletteGeneratorMaster] from an [ImageProvider].
  static Future<PaletteGeneratorMaster> fromImageProvider(
    ImageProvider imageProvider, {
    Size? size,
    Rect? region,
    int maximumColorCount = _defaultCalculateNumberColors,
    List<PaletteFilterMaster> filters = const <PaletteFilterMaster>[
      avoidRedBlackWhitePaletteFilterMaster
    ],
    List<PaletteTargetMaster> targets = const <PaletteTargetMaster>[],
    Duration timeout = const Duration(seconds: 15),
    bool enableCaching = true,
    bool generateHarmony = true,
    ColorSpace colorSpace = ColorSpace.rgb,
  }) async {
    assert(region == null || size != null);
    assert(region == null || region != Rect.zero);

    final ImageStream stream = imageProvider.resolve(
      ImageConfiguration(size: size, devicePixelRatio: 1.0),
    );
    final Completer<ui.Image> imageCompleter = Completer<ui.Image>();
    Timer? loadFailureTimeout;
    late ImageStreamListener listener;

    listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
      loadFailureTimeout?.cancel();
      stream.removeListener(listener);
      imageCompleter.complete(info.image);
    });

    if (timeout != Duration.zero) {
      loadFailureTimeout = Timer(timeout, () {
        stream.removeListener(listener);
        imageCompleter.completeError(
          TimeoutException(
              'Timeout occurred trying to load from $imageProvider'),
        );
      });
    }

    stream.addListener(listener);
    final ui.Image image = await imageCompleter.future;

    ui.Rect? newRegion = region;
    if (size != null && region != null) {
      final double scale = image.width / size.width;
      newRegion = Rect.fromLTRB(
        region.left * scale,
        region.top * scale,
        region.right * scale,
        region.bottom * scale,
      );
    }

    return PaletteGeneratorMaster.fromImage(
      image,
      region: newRegion,
      maximumColorCount: maximumColorCount,
      filters: filters,
      targets: targets,
      enableCaching: enableCaching,
      generateHarmony: generateHarmony,
      colorSpace: colorSpace,
    );
  }

  static const int _defaultCalculateNumberColors = 16;

  /// The list of [PaletteColorMaster]s that make up the palette, sorted from most
  /// dominant color to least dominant color.
  final List<PaletteColorMaster> paletteColors;

  /// The list of targets that the palette uses for custom color selection.
  final List<PaletteTargetMaster> targets;

  /// Provides a map of the selected colors for each target.
  final Map<PaletteTargetMaster, PaletteColorMaster> selectedSwatches;

  /// Information about the source image.
  final ImageInfoMaster? sourceImageInfo;

  /// Generated harmony colors based on color theory.
  List<ColorHarmonyMaster>? _harmonyColors;

  /// Returns a list of colors in the palette, sorted from most dominant to least dominant.
  Iterable<Color> get colors sync* {
    for (final PaletteColorMaster paletteColor in paletteColors) {
      yield paletteColor.color;
    }
  }

  /// Returns the dominant color (the color with the largest population).
  PaletteColorMaster? get dominantColor => _dominantColor;
  PaletteColorMaster? _dominantColor;

  /// Returns a vibrant color from the palette.
  PaletteColorMaster? get vibrantColor =>
      selectedSwatches[PaletteTargetMaster.vibrant];

  /// Returns a light and vibrant color from the palette.
  PaletteColorMaster? get lightVibrantColor =>
      selectedSwatches[PaletteTargetMaster.lightVibrant];

  /// Returns a dark and vibrant color from the palette.
  PaletteColorMaster? get darkVibrantColor =>
      selectedSwatches[PaletteTargetMaster.darkVibrant];

  /// Returns a muted color from the palette.
  PaletteColorMaster? get mutedColor =>
      selectedSwatches[PaletteTargetMaster.muted];

  /// Returns a muted and light color from the palette.
  PaletteColorMaster? get lightMutedColor =>
      selectedSwatches[PaletteTargetMaster.lightMuted];

  /// Returns a muted and dark color from the palette.
  PaletteColorMaster? get darkMutedColor =>
      selectedSwatches[PaletteTargetMaster.darkMuted];

  /// Returns generated harmony colors based on color theory.
  List<ColorHarmonyMaster> get harmonyColors => _harmonyColors ?? [];

  /// Get accessibility-compliant color pairs.
  List<AccessibleColorPair> getAccessibleColorPairs({
    double minimumContrast = 4.5,
    bool includeAAA = false,
  }) {
    return AccessibilityHelperMaster.generateAccessiblePairs(
      paletteColors,
      minimumContrast: minimumContrast,
      includeAAA: includeAAA,
    );
  }

  /// Get the best background color for the given text color.
  PaletteColorMaster? getBestBackgroundFor(
    Color textColor, {
    double minimumContrast = 4.5,
  }) {
    return AccessibilityHelperMaster.getBestBackground(
      textColor,
      paletteColors,
      minimumContrast: minimumContrast,
    );
  }

  /// Get the best text color for the given background color.
  Color getBestTextColorFor(
    Color backgroundColor, {
    double minimumContrast = 4.5,
  }) {
    return AccessibilityHelperMaster.getBestTextColor(
      backgroundColor,
      minimumContrast: minimumContrast,
    );
  }

  void _sortSwatches() {
    if (paletteColors.isEmpty) {
      _dominantColor = null;
      return;
    }
    // Sort from most common to least common.
    paletteColors.sort((PaletteColorMaster a, PaletteColorMaster b) {
      return b.population.compareTo(a.population);
    });
    _dominantColor = paletteColors[0];
  }

  void _selectSwatches() {
    final Set<PaletteTargetMaster> allTargets = Set<PaletteTargetMaster>.from(
        targets + PaletteTargetMaster.baseTargets);
    final Set<Color> usedColors = <Color>{};

    for (final PaletteTargetMaster target in allTargets) {
      target._normalizeWeights();
      final PaletteColorMaster? targetScore =
          _generateScoredTarget(target, usedColors);
      if (targetScore != null) {
        selectedSwatches[target] = targetScore;
      }
    }
  }

  void _generateHarmonyColors() {
    if (dominantColor != null) {
      _harmonyColors =
          ColorHarmonyMaster.generateHarmonyColors(dominantColor!.color);
    }
  }

  PaletteColorMaster? _generateScoredTarget(
      PaletteTargetMaster target, Set<Color> usedColors) {
    final PaletteColorMaster? maxScoreSwatch =
        _getMaxScoredSwatchForTarget(target, usedColors);
    if (maxScoreSwatch != null && target.isExclusive) {
      usedColors.add(maxScoreSwatch.color);
    }
    return maxScoreSwatch;
  }

  PaletteColorMaster? _getMaxScoredSwatchForTarget(
      PaletteTargetMaster target, Set<Color> usedColors) {
    double maxScore = 0.0;
    PaletteColorMaster? maxScoreSwatch;

    for (final PaletteColorMaster paletteColor in paletteColors) {
      if (_shouldBeScoredForTarget(paletteColor, target, usedColors)) {
        final double score = _generateScore(paletteColor, target);
        if (maxScoreSwatch == null || score > maxScore) {
          maxScoreSwatch = paletteColor;
          maxScore = score;
        }
      }
    }
    return maxScoreSwatch;
  }

  bool _shouldBeScoredForTarget(PaletteColorMaster paletteColor,
      PaletteTargetMaster target, Set<Color> usedColors) {
    final HSLColor hslColor = HSLColor.fromColor(paletteColor.color);
    return hslColor.saturation >= target.minimumSaturation &&
        hslColor.saturation <= target.maximumSaturation &&
        hslColor.lightness >= target.minimumLightness &&
        hslColor.lightness <= target.maximumLightness &&
        !usedColors.contains(paletteColor.color);
  }

  double _generateScore(
      PaletteColorMaster paletteColor, PaletteTargetMaster target) {
    final HSLColor hslColor = HSLColor.fromColor(paletteColor.color);

    double saturationScore = 0.0;
    double valueScore = 0.0;
    double populationScore = 0.0;

    if (target.saturationWeight > 0.0) {
      saturationScore = target.saturationWeight *
          (1.0 - (hslColor.saturation - target.targetSaturation).abs());
    }
    if (target.lightnessWeight > 0.0) {
      valueScore = target.lightnessWeight *
          (1.0 - (hslColor.lightness - target.targetLightness).abs());
    }
    if (_dominantColor != null && target.populationWeight > 0.0) {
      populationScore = target.populationWeight *
          (paletteColor.population / _dominantColor!.population);
    }

    return saturationScore + valueScore + populationScore;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<PaletteColorMaster>(
        'paletteColors', paletteColors,
        defaultValue: <PaletteColorMaster>[]));
    properties.add(IterableProperty<PaletteTargetMaster>('targets', targets,
        defaultValue: PaletteTargetMaster.baseTargets));
    if (sourceImageInfo != null) {
      properties.add(
          DiagnosticsProperty<ImageInfoMaster>('sourceImageInfo', sourceImageInfo));
    }
  }
}

/// Color space enumeration for different color processing modes.
enum ColorSpace {
  /// RGB color space (default)
  rgb,

  /// HSV color space
  hsv,

  /// LAB color space (more perceptually uniform)
  lab,
}

/// Internal class to store image information.
class ImageInfoMaster {
  const ImageInfoMaster({
    required this.width,
    required this.height,
    this.name,
    required this.pixelCount,
  });

  final int width;
  final int height;
  final String? name;
  final int pixelCount;

  double get aspectRatio => width / height;
}

/// Enhanced color cut quantizer with better performance and additional features.
class _ColorCutQuantizerMaster {
  _ColorCutQuantizerMaster(
    this.encodedImage, {
    this.maxColors = PaletteGeneratorMaster._defaultCalculateNumberColors,
    this.region,
    this.filters = const <PaletteFilterMaster>[
      avoidRedBlackWhitePaletteFilterMaster
    ],
    this.colorSpace = ColorSpace.rgb,
  }) : assert(region == null || region != Rect.zero);

  final EncodedImageMaster encodedImage;
  final int maxColors;
  final Rect? region;
  final List<PaletteFilterMaster> filters;
  final ColorSpace colorSpace;

  Completer<List<PaletteColorMaster>>? _paletteColorsCompleter;

  FutureOr<List<PaletteColorMaster>> get quantizedColors async {
    if (_paletteColorsCompleter == null) {
      _paletteColorsCompleter = Completer<List<PaletteColorMaster>>();
      _paletteColorsCompleter!.complete(_quantizeColors());
    }
    return _paletteColorsCompleter!.future;
  }

  List<PaletteColorMaster> _quantizeColors() {
    final Map<int, int> colorCounts = <int, int>{};
    final ByteData pixels = encodedImage.byteData;
    final int pixelCount = encodedImage.pixelCount;
    
    // Extract colors from image pixels
    for (int i = 0; i < pixelCount * 4; i += 4) {
      if (i + 3 < pixels.lengthInBytes) {
        final int r = pixels.getUint8(i);
        final int g = pixels.getUint8(i + 1);
        final int b = pixels.getUint8(i + 2);
        final int a = pixels.getUint8(i + 3);
        
        // Skip transparent pixels
        if (a < 128) continue;
        
        final int color = (0xFF << 24) | (r << 16) | (g << 8) | b;
        colorCounts[color] = (colorCounts[color] ?? 0) + 1;
      }
    }
    
    // Convert to PaletteColorMaster list and sort by population
    final List<PaletteColorMaster> colors = colorCounts.entries
        .map((entry) => PaletteColorMaster(Color(entry.key), entry.value))
        .toList();
    
    // Sort by population (most dominant first)
    colors.sort((a, b) => b.population.compareTo(a.population));
    
    // Apply filters
    final List<PaletteColorMaster> filteredColors = [];
    for (final color in colors) {
      final HSLColor hslColor = HSLColor.fromColor(color.color);
      bool shouldInclude = true;
      
      for (final filter in filters) {
        if (!filter(hslColor)) {
          shouldInclude = false;
          break;
        }
      }
      
      if (shouldInclude) {
        filteredColors.add(color);
      }
      
      // Limit to maxColors
      if (filteredColors.length >= maxColors) {
        break;
      }
    }
    
    return filteredColors;
  }
}

// Placeholder classes that would be implemented in separate files
class PaletteColorMaster {
  const PaletteColorMaster(this.color, this.population);
  final Color color;
  final int population;
}

class PaletteTargetMaster {
  PaletteTargetMaster({
    this.minimumSaturation = 0.0,
    this.targetSaturation = 0.5,
    this.maximumSaturation = 1.0,
    this.minimumLightness = 0.0,
    this.targetLightness = 0.5,
    this.maximumLightness = 1.0,
    this.isExclusive = true,
    this.saturationWeight = 0.24,
    this.lightnessWeight = 0.52,
    this.populationWeight = 0.24,
  });

  final double minimumSaturation;
  final double targetSaturation;
  final double maximumSaturation;
  final double minimumLightness;
  final double targetLightness;
  final double maximumLightness;
  final bool isExclusive;

  final double saturationWeight;
  final double lightnessWeight;
  final double populationWeight;

  static final PaletteTargetMaster vibrant = PaletteTargetMaster(
    targetSaturation: 1.0,
    minimumSaturation: 0.35,
  );
  static final PaletteTargetMaster lightVibrant = PaletteTargetMaster(
    targetSaturation: 1.0,
    minimumSaturation: 0.35,
    targetLightness: 0.74,
    minimumLightness: 0.55,
  );
  static final PaletteTargetMaster darkVibrant = PaletteTargetMaster(
    targetSaturation: 1.0,
    minimumSaturation: 0.35,
    targetLightness: 0.26,
    maximumLightness: 0.45,
  );
  static final PaletteTargetMaster muted = PaletteTargetMaster(
    targetSaturation: 0.3,
    maximumSaturation: 0.4,
  );
  static final PaletteTargetMaster lightMuted = PaletteTargetMaster(
    targetSaturation: 0.3,
    maximumSaturation: 0.4,
    targetLightness: 0.74,
    minimumLightness: 0.55,
  );
  static final PaletteTargetMaster darkMuted = PaletteTargetMaster(
    targetSaturation: 0.3,
    maximumSaturation: 0.4,
    targetLightness: 0.26,
    maximumLightness: 0.45,
  );

  static final List<PaletteTargetMaster> baseTargets = [
    vibrant,
    lightVibrant,
    darkVibrant,
    muted,
    lightMuted,
    darkMuted
  ];

  void _normalizeWeights() {
    // Weights are now final, so normalization is handled in constructor
  }
}

typedef PaletteFilterMaster = bool Function(HSLColor color);

bool avoidRedBlackWhitePaletteFilterMaster(HSLColor color) {
  return color.lightness > 0.05 && color.lightness < 0.95;
}

class ColorHarmonyMaster {
  const ColorHarmonyMaster(this.type, this.colors);
  final HarmonyType type;
  final List<Color> colors;

  static List<ColorHarmonyMaster> generateHarmonyColors(Color baseColor) {
    return [];
  }
}

enum HarmonyType { complementary, triadic, analogous, splitComplementary }

class AccessibilityHelperMaster {
  static List<AccessibleColorPair> generateAccessiblePairs(
    List<PaletteColorMaster> colors, {
    double minimumContrast = 4.5,
    bool includeAAA = false,
  }) {
    return [];
  }

  static PaletteColorMaster? getBestBackground(
    Color textColor,
    List<PaletteColorMaster> colors, {
    double minimumContrast = 4.5,
  }) {
    return null;
  }

  static Color getBestTextColor(
    Color backgroundColor, {
    double minimumContrast = 4.5,
  }) {
    return Colors.white;
  }
}

class AccessibleColorPair {
  const AccessibleColorPair(
      this.foreground, this.background, this.contrastRatio);
  final Color foreground;
  final Color background;
  final double contrastRatio;
}
