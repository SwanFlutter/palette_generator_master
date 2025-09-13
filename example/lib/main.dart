// Copyright 2024 Palette Generator Master Example. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

void main() {
  runApp(const PaletteGeneratorMasterApp());
}

class PaletteGeneratorMasterApp extends StatelessWidget {
  const PaletteGeneratorMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palette Generator Master Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ImageColorsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImageColorsPage extends StatefulWidget {
  const ImageColorsPage({super.key});

  @override
  State<ImageColorsPage> createState() => _ImageColorsPageState();
}

class _ImageColorsPageState extends State<ImageColorsPage>
    with TickerProviderStateMixin {
  PaletteGeneratorMaster? paletteGenerator;
  bool isLoading = false;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sample images for demonstration
  final List<String> sampleImages = [
    'assets/images/sample1.jpg',
    'assets/images/sample2.jpg',
    'assets/images/sample3.jpg',
    'assets/images/sample4.jpg',
  ];

  int currentImageIndex = 0;
  ColorSpace selectedColorSpace = ColorSpace.rgb;
  bool showHarmonyColors = true;
  bool showAccessibilityInfo = true;
  double contrastThreshold = 4.5;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _updatePaletteGenerator();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updatePaletteGenerator() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // For demonstration, we'll create a simple colored image
      final ui.Image image = await _createSampleImage();

      final PaletteGeneratorMaster generator =
          await PaletteGeneratorMaster.fromImage(
            image,
            maximumColorCount: 16,
            colorSpace: selectedColorSpace,
            generateHarmony: showHarmonyColors,
            targets: [
              PaletteTargetMaster.vibrant,
              PaletteTargetMaster.lightVibrant,
              PaletteTargetMaster.darkVibrant,
              PaletteTargetMaster.muted,
              PaletteTargetMaster.lightMuted,
              PaletteTargetMaster.darkMuted,
            ],
          );

      setState(() {
        paletteGenerator = generator;
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        errorMessage = 'Error generating palette: $e';
        isLoading = false;
      });
    }
  }

  Future<ui.Image> _createSampleImage() async {
    // Create a sample gradient image for demonstration
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const Size size = Size(200, 200);

    // Create a gradient with different colors based on current index
    final List<List<Color>> gradients = [
      [Colors.blue.shade800, Colors.blue.shade200, Colors.white],
      [Colors.red.shade800, Colors.orange.shade400, Colors.yellow.shade200],
      [Colors.green.shade800, Colors.teal.shade400, Colors.cyan.shade200],
      [Colors.purple.shade800, Colors.pink.shade400, Colors.purple.shade100],
    ];

    final List<Color> currentGradient =
        gradients[currentImageIndex % gradients.length];

    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: currentGradient,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Add some geometric shapes for more color variety
    final Paint shapePaint = Paint()
      ..color = currentGradient.first.withOpacity(0.7);
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.3),
      30,
      shapePaint,
    );

    shapePaint.color = currentGradient.last.withOpacity(0.8);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.6, 40, 40),
      shapePaint,
    );

    final ui.Picture picture = recorder.endRecording();
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }

  void _nextImage() {
    setState(() {
      currentImageIndex = (currentImageIndex + 1) % 4;
    });
    _animationController.reset();
    _updatePaletteGenerator();
  }

  void _changeColorSpace(ColorSpace? newColorSpace) {
    if (newColorSpace != null && newColorSpace != selectedColorSpace) {
      setState(() {
        selectedColorSpace = newColorSpace;
      });
      _updatePaletteGenerator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Palette Generator Master'),
        backgroundColor: paletteGenerator?.dominantColor?.color ?? Colors.blue,
        foregroundColor: paletteGenerator?.dominantColor != null
            ? paletteGenerator!.getBestTextColorFor(
                paletteGenerator!.dominantColor!.color,
                minimumContrast: contrastThreshold,
              )
            : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _nextImage,
            tooltip: 'Next Sample Image',
          ),
          PopupMenuButton<ColorSpace>(
            icon: const Icon(Icons.palette),
            tooltip: 'Color Space',
            onSelected: _changeColorSpace,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ColorSpace.rgb,
                child: Text('RGB Color Space'),
              ),
              const PopupMenuItem(
                value: ColorSpace.hsv,
                child: Text('HSV Color Space'),
              ),
              const PopupMenuItem(
                value: ColorSpace.lab,
                child: Text('LAB Color Space'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating palette...'),
                ],
              ),
            )
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updatePaletteGenerator,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePreview(),
                    const SizedBox(height: 24),
                    _buildControlPanel(),
                    const SizedBox(height: 24),
                    _buildPaletteSection(),
                    if (showHarmonyColors) ...[
                      const SizedBox(height: 24),
                      _buildHarmonyColorsSection(),
                    ],
                    if (showAccessibilityInfo) ...[
                      const SizedBox(height: 24),
                      _buildAccessibilitySection(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _getCurrentGradient(),
        ),
        child: const Center(
          child: Text(
            'Sample Image',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getCurrentGradient() {
    final List<List<Color>> gradients = [
      [Colors.blue.shade800, Colors.blue.shade200, Colors.white],
      [Colors.red.shade800, Colors.orange.shade400, Colors.yellow.shade200],
      [Colors.green.shade800, Colors.teal.shade400, Colors.cyan.shade200],
      [Colors.purple.shade800, Colors.pink.shade400, Colors.purple.shade100],
    ];

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradients[currentImageIndex % gradients.length],
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Color Space:'),
                      DropdownButton<ColorSpace>(
                        value: selectedColorSpace,
                        onChanged: _changeColorSpace,
                        items: const [
                          DropdownMenuItem(
                            value: ColorSpace.rgb,
                            child: Text('RGB'),
                          ),
                          DropdownMenuItem(
                            value: ColorSpace.hsv,
                            child: Text('HSV'),
                          ),
                          DropdownMenuItem(
                            value: ColorSpace.lab,
                            child: Text('LAB'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contrast Threshold: ${contrastThreshold.toStringAsFixed(1)}',
                      ),
                      Slider(
                        value: contrastThreshold,
                        min: 3.0,
                        max: 7.0,
                        divisions: 8,
                        onChanged: (value) {
                          setState(() {
                            contrastThreshold = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Show Harmony Colors'),
                    value: showHarmonyColors,
                    onChanged: (value) {
                      setState(() {
                        showHarmonyColors = value ?? true;
                      });
                      _updatePaletteGenerator();
                    },
                    dense: true,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Show Accessibility Info'),
                    value: showAccessibilityInfo,
                    onChanged: (value) {
                      setState(() {
                        showAccessibilityInfo = value ?? true;
                      });
                    },
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteSection() {
    if (paletteGenerator == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Extracted Palette',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTargetColors(),
        const SizedBox(height: 16),
        _buildAllColors(),
      ],
    );
  }

  Widget _buildTargetColors() {
    final Map<String, PaletteColorMaster?> targetColors = {
      'Vibrant': paletteGenerator!.vibrantColor,
      'Light Vibrant': paletteGenerator!.lightVibrantColor,
      'Dark Vibrant': paletteGenerator!.darkVibrantColor,
      'Muted': paletteGenerator!.mutedColor,
      'Light Muted': paletteGenerator!.lightMutedColor,
      'Dark Muted': paletteGenerator!.darkMutedColor,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Target Colors',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: targetColors.entries.map((entry) {
                return _buildColorChip(
                  entry.key,
                  entry.value?.color,
                  entry.value?.population,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllColors() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Extracted Colors',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: paletteGenerator!.paletteColors.map((paletteColor) {
                return _buildColorChip(
                  'Pop: ${paletteColor.population}',
                  paletteColor.color,
                  paletteColor.population,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChip(String label, Color? color, int? population) {
    if (color == null) {
      return Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: const Center(
          child: Text('N/A', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final textColor = paletteGenerator!.getBestTextColorFor(
      color,
      minimumContrast: contrastThreshold,
    );

    return GestureDetector(
      onTap: () {
        _showColorDetails(color, label, population);
      },
      child: Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHarmonyColorsSection() {
    if (paletteGenerator?.harmonyColors.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color Harmony',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Generated Harmony Colors',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Based on color theory principles',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                // Placeholder for harmony colors
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Harmony colors will be displayed here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibilitySection() {
    if (paletteGenerator == null) return const SizedBox.shrink();

    final accessiblePairs = paletteGenerator!.getAccessibleColorPairs(
      minimumContrast: contrastThreshold,
      includeAAA: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accessibility Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WCAG Compliant Color Pairs (${contrastThreshold.toStringAsFixed(1)}:1 minimum)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (accessiblePairs.isEmpty)
                  const Text(
                    'No accessible color pairs found with current settings.',
                    style: TextStyle(color: Colors.orange),
                  )
                else
                  Column(
                    children: accessiblePairs.take(5).map((pair) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: pair.background,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: pair.foreground,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Contrast Ratio: ${pair.contrastRatio.toStringAsFixed(2)}:1',
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                            Icon(
                              pair.contrastRatio >= 7.0
                                  ? Icons.verified
                                  : pair.contrastRatio >= 4.5
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: pair.contrastRatio >= 7.0
                                  ? Colors.green
                                  : pair.contrastRatio >= 4.5
                                  ? Colors.blue
                                  : Colors.orange,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColorDetails(Color color, String label, int? population) {
    final hslColor = HSLColor.fromColor(color);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hex: #${color.value.toRadixString(16).substring(2).toUpperCase()}',
            ),
            Text('RGB: ${color.red}, ${color.green}, ${color.blue}'),
            Text(
              'HSL: ${(hslColor.hue).toStringAsFixed(0)}°, ${(hslColor.saturation * 100).toStringAsFixed(0)}%, ${(hslColor.lightness * 100).toStringAsFixed(0)}%',
            ),
            if (population != null) Text('Population: $population pixels'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text:
                      '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                ),
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Color hex copied to clipboard!')),
              );
            },
            child: const Text('Copy Hex'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
