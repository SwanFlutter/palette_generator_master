import 'dart:async';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

void main() {
  runApp(const AdvancedPaletteApp());
}

class AdvancedPaletteApp extends StatelessWidget {
  const AdvancedPaletteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Palette Generator',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ImagePaletteScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImagePaletteScreen extends StatefulWidget {
  const ImagePaletteScreen({super.key});

  @override
  State<ImagePaletteScreen> createState() => _ImagePaletteScreenState();
}

class _ImagePaletteScreenState extends State<ImagePaletteScreen> {
  ui.Image? _image;
  PaletteGeneratorMaster? _paletteGenerator;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImageAndShowBottomSheet();
  }

  Future<void> _loadImageAndShowBottomSheet() async {
    try {
      // Load a sample image from assets
      final ui.Image image = await _loadImageFromAssets(
        'assets/sample_image.jpg',
      );
      setState(() {
        _image = image;
      });

      // Show bottom sheet immediately after loading image
      if (mounted) {
        _showPaletteBottomSheet();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطا در بارگذاری تصویر: $e';
      });
    }
  }

  Future<ui.Image> _loadImageFromAssets(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      // If asset doesn't exist, create a sample image
      return await _createSampleImage();
    }
  }

  Future<ui.Image> _createSampleImage() async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const Size size = Size(400, 300);

    // Create a beautiful gradient background
    final Paint backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Color(0xFFf093fb),
          Color(0xFFf5576c),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Add some colorful shapes
    final Paint circlePaint1 = Paint()..color = const Color(0xFF4facfe);
    final Paint circlePaint2 = Paint()..color = const Color(0xFF00f2fe);
    final Paint circlePaint3 = Paint()..color = const Color(0xFFa8edea);
    final Paint circlePaint4 = Paint()..color = const Color(0xFFfed6e3);

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      40,
      circlePaint1,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      35,
      circlePaint2,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      45,
      circlePaint3,
    );
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.8),
      30,
      circlePaint4,
    );

    // Add some rectangles
    final Paint rectPaint1 = Paint()..color = const Color(0xFFffecd2);
    final Paint rectPaint2 = Paint()..color = const Color(0xFFfcb69f);

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.5, 60, 40),
      rectPaint1,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.4, 50, 35),
      rectPaint2,
    );

    final ui.Picture picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }

  void _showPaletteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'استخراج رنگ‌های تصویر',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // Content
              Expanded(child: _buildBottomSheetContent(scrollController)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetContent(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          if (_image != null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(
                  painter: ImagePainter(_image!),
                  size: const Size(double.infinity, 200),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Extract colors button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _extractColorsWithIsolate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('در حال استخراج رنگ‌ها...'),
                      ],
                    )
                  : const Text(
                      'استخراج رنگ‌ها با Isolate',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Palette results
          if (_paletteGenerator != null) ...[
            const SizedBox(height: 20),
            _buildPaletteResults(),
          ],
        ],
      ),
    );
  }

  Future<void> _extractColorsWithIsolate() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Convert image to byte data
      final ByteData? byteData = await _image!.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('خطا در تبدیل تصویر به ByteData');
      }

      // Create isolate data
      final isolateData = IsolateData(
        imageBytes: byteData,
        width: _image!.width,
        height: _image!.height,
      );

      // Run palette extraction in isolate
      final ReceivePort receivePort = ReceivePort();
      await Isolate.spawn(_extractColorsIsolate, {
        'sendPort': receivePort.sendPort,
        'data': isolateData,
      });

      // Wait for result
      final result = await receivePort.first;
      receivePort.close();

      if (result is String) {
        // Error occurred
        setState(() {
          _errorMessage = result;
          _isLoading = false;
        });
      } else if (result is PaletteGeneratorMaster) {
        // Success
        setState(() {
          _paletteGenerator = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطا در استخراج رنگ‌ها: $e';
        _isLoading = false;
      });
    }
  }

  static Future<void> _extractColorsIsolate(Map<String, dynamic> params) async {
    final SendPort sendPort = params['sendPort'];
    final IsolateData data = params['data'];

    try {
      print('🎨 شروع پردازش تصویر در Isolate...');
      print('📏 ابعاد تصویر: ${data.width} x ${data.height}');
      
      // Create encoded image
      final encodedImage = EncodedImageMaster(
        data.imageBytes,
        width: data.width,
        height: data.height,
      );

      print('🔍 استخراج رنگ‌ها با حداکثر 20 رنگ...');
      // Generate palette with high precision
      final paletteGenerator = await PaletteGeneratorMaster.fromByteData(
        encodedImage,
        maximumColorCount: 20, // Higher count for more precision
        targets: [
          PaletteTargetMaster.vibrant,
          PaletteTargetMaster.lightVibrant,
          PaletteTargetMaster.darkVibrant,
          PaletteTargetMaster.muted,
          PaletteTargetMaster.lightMuted,
          PaletteTargetMaster.darkMuted,
        ],
      );

      // لاگ رنگ‌های غالب
      print('\n🎯 رنگ‌های غالب استخراج شده:');
      final paletteColors = paletteGenerator.paletteColors;
      for (int i = 0; i < paletteColors.length; i++) {
        final color = paletteColors[i];
        final hex = '#${color.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        print('  ${i + 1}. $hex - تعداد پیکسل: ${color.population}');
      }

      // لاگ رنگ‌های هدف
      print('\n🎨 رنگ‌های هدف:');
      final vibrant = paletteGenerator.vibrantColor;
      final lightVibrant = paletteGenerator.lightVibrantColor;
      final darkVibrant = paletteGenerator.darkVibrantColor;
      final muted = paletteGenerator.mutedColor;
      final lightMuted = paletteGenerator.lightMutedColor;
      final darkMuted = paletteGenerator.darkMutedColor;

      if (vibrant != null) {
        final hex = '#${vibrant.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        print('  Vibrant: $hex');
      }
      if (lightVibrant != null) {
        final hex = '#${lightVibrant.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        print('  Light Vibrant: $hex');
      }
      if (darkVibrant != null) {
        final hex = '#${darkVibrant.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        print('  Dark Vibrant: $hex');
      }
      if (muted != null) {
        final hex = '#${muted.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        print('  Muted: $hex');
      }
      if (lightMuted != null) {
        final hex = '#${lightMuted.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        print('  Light Muted: $hex');
      }
      if (darkMuted != null) {
        final hex = '#${darkMuted.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        print('  Dark Muted: $hex');
      }

      print('✅ پردازش کامل شد!');
      sendPort.send(paletteGenerator);
    } catch (e) {
      print('❌ خطا در پردازش: $e');
      sendPort.send('خطا در پردازش: $e');
    }
  }

  Widget _buildPaletteResults() {
    final generator = _paletteGenerator!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'رنگ‌های استخراج شده:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Dominant colors
        _buildColorSection('رنگ‌های غالب', generator.colors.take(6).toList()),

        const SizedBox(height: 16),

        // Target colors
        _buildTargetColors(generator),

        const SizedBox(height: 16),

        // Color statistics
        _buildColorStatistics(generator),
      ],
    );
  }

  Widget _buildColorSection(String title, List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) => _buildColorChip(color)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorChip(Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Text(
              '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetColors(PaletteGeneratorMaster generator) {
    final targets = [
      ('Vibrant', generator.vibrantColor?.color),
      ('Light Vibrant', generator.lightVibrantColor?.color),
      ('Dark Vibrant', generator.darkVibrantColor?.color),
      ('Muted', generator.mutedColor?.color),
      ('Light Muted', generator.lightMutedColor?.color),
      ('Dark Muted', generator.darkMutedColor?.color),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'رنگ‌های هدف:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...targets.map((target) {
          if (target.$2 == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: target.$2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.$1,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '#${target.$2!.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildColorStatistics(PaletteGeneratorMaster generator) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'آمار رنگ‌ها:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('تعداد کل رنگ‌ها: ${generator.colors.length}'),
          if (generator.dominantColor != null)
            Text(
              'رنگ غالب: #${generator.dominantColor!.color.value.toRadixString(16).substring(2).toUpperCase()}',
            ),
          if (generator.sourceImageInfo != null) ...[
            Text(
              'ابعاد تصویر: ${generator.sourceImageInfo!.width} × ${generator.sourceImageInfo!.height}',
            ),
            Text(
              'نسبت تصویر: ${generator.sourceImageInfo!.aspectRatio.toStringAsFixed(2)}',
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استخراج رنگ پیشرفته'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null)
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      painter: ImagePainter(_image!),
                      size: const Size(300, 200),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              const Text(
                'برای مشاهده رنگ‌های استخراج شده،\nروی دکمه زیر کلیک کنید',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showPaletteBottomSheet,
                icon: const Icon(Icons.palette),
                label: const Text('نمایش پالت رنگ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IsolateData {
  final ByteData imageBytes;
  final int width;
  final int height;

  IsolateData({
    required this.imageBytes,
    required this.width,
    required this.height,
  });
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final Rect srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final Rect dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
