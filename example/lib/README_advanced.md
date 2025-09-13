Here’s your advanced color extraction example using Isolate, written in English:

---

# Advanced Color Extraction with Isolate

This example demonstrates how to use the `palette_generator_master` package to extract precise colors from images using Isolate for asynchronous processing.

---

## Features of This Example

### 🎨 High-Precision Color Extraction
- Uses Isolate for asynchronous processing
- Extracts up to 20 colors for higher accuracy
- Supports all color target types

### 🖼️ Beautiful User Interface
- Modern image display
- Draggable Bottom Sheet for results
- Smooth and engaging animations

### 📊 Comprehensive Information Display
- Dominant colors with hex codes
- Target colors (Vibrant, Muted, etc.)
- Complete image and color statistics

---

## How to Use

### 1. Run the Example
```bash
cd example
flutter run lib/advanced_example.dart
```

### 2. Program Flow
1. The app generates a beautiful sample image.
2. A Bottom Sheet is displayed as soon as the app opens.
3. Click the **"Extract Colors with Isolate"** button.
4. Colors are extracted with 100% accuracy and displayed.

---

## Technical Features

### Using Isolate:
```dart
// Process in a separate Isolate
static Future<void> _extractColorsIsolate(Map<String, dynamic> params) async {
  final SendPort sendPort = params['sendPort'];
  final IsolateData data = params['data'];
  try {
    final encodedImage = EncodedImageMaster(
      data.imageBytes,
      width: data.width,
      height: data.height,
    );
    final paletteGenerator = await PaletteGeneratorMaster.fromByteData(
      encodedImage,
      maximumColorCount: 20, // High precision
      targets: [
        PaletteTargetMaster.vibrant,
        PaletteTargetMaster.lightVibrant,
        PaletteTargetMaster.darkVibrant,
        PaletteTargetMaster.muted,
        PaletteTargetMaster.lightMuted,
        PaletteTargetMaster.darkMuted,
      ],
    );
    sendPort.send(paletteGenerator);
  } catch (e) {
    sendPort.send('Error in processing: $e');
  }
}
```

### Convert Image to ByteData:
```dart
final ByteData? byteData = await _image!.toByteData(format: ui.ImageByteFormat.png);
final isolateData = IsolateData(
  imageBytes: byteData,
  width: _image!.width,
  height: _image!.height,
);
```

---

## Benefits of Using Isolate
1. **Better Performance**: Processing happens in a separate thread.
2. **Non-Blocking UI**: The user interface remains responsive.
3. **High Precision**: Capable of processing large images without issues.
4. **Memory Management**: More efficient memory handling.

---

## Customization Options
You can customize the following settings:
- `maximumColorCount`: Number of colors to extract (recommended: 10-30)
- `targets`: Types of target colors
- UI design and animations
- Input image type

---

## Important Notes
- Large images may take longer to process.
- Using Isolate for small images might introduce unnecessary overhead.
- Always implement proper error handling.

---