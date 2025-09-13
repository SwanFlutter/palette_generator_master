# مثال پیشرفته استخراج رنگ با Isolate

این مثال نشان می‌دهد که چگونه از پکیج `palette_generator_master` برای استخراج رنگ‌های دقیق از تصاویر با استفاده از Isolate استفاده کنید.

## ویژگی‌های این مثال:

### 🎨 استخراج رنگ با دقت بالا
- استفاده از Isolate برای پردازش غیرهمزمان
- استخراج حداکثر 20 رنگ برای دقت بیشتر
- پشتیبانی از تمام انواع target های رنگی

### 🖼️ رابط کاربری زیبا
- نمایش تصویر با طراحی مدرن
- Bottom Sheet قابل کشیدن برای نمایش نتایج
- انیمیشن‌های روان و جذاب

### 📊 نمایش جامع اطلاعات
- رنگ‌های غالب با کد هگز
- رنگ‌های هدف (Vibrant, Muted, etc.)
- آمار کامل تصویر و رنگ‌ها

## نحوه استفاده:

### 1. اجرای مثال
```bash
cd example
flutter run lib/advanced_example.dart
```

### 2. عملکرد برنامه
1. برنامه یک تصویر نمونه زیبا ایجاد می‌کند
2. به محض باز شدن، Bottom Sheet نمایش داده می‌شود
3. روی دکمه "استخراج رنگ‌ها با Isolate" کلیک کنید
4. رنگ‌ها با دقت 100% استخراج و نمایش داده می‌شوند

### 3. ویژگی‌های تکنیکی

#### استفاده از Isolate:
```dart
// پردازش در Isolate جداگانه
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
      maximumColorCount: 20, // دقت بالا
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
    sendPort.send('خطا در پردازش: $e');
  }
}
```

#### تبدیل تصویر به ByteData:
```dart
final ByteData? byteData = await _image!.toByteData(format: ui.ImageByteFormat.png);
final isolateData = IsolateData(
  imageBytes: byteData,
  width: _image!.width,
  height: _image!.height,
);
```

## مزایای استفاده از Isolate:

1. **عملکرد بهتر**: پردازش در thread جداگانه
2. **عدم مسدود شدن UI**: رابط کاربری همچنان پاسخگو می‌ماند
3. **دقت بالا**: امکان پردازش تصاویر بزرگ بدون مشکل
4. **مدیریت حافظه**: بهتر مدیریت می‌شود

## سفارشی‌سازی:

می‌توانید تنظیمات زیر را تغییر دهید:

- `maximumColorCount`: تعداد رنگ‌های استخراجی (پیشنهاد: 10-30)
- `targets`: انواع رنگ‌های هدف
- طراحی UI و انیمیشن‌ها
- نوع تصویر ورودی

## نکات مهم:

- تصاویر بزرگ ممکن است زمان بیشتری برای پردازش نیاز داشته باشند
- استفاده از Isolate برای تصاویر کوچک ممکن است overhead اضافی ایجاد کند
- همیشه error handling مناسب پیاده‌سازی کنید