import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

void main() {
  group('PaletteGeneratorMaster Tests', () {
    test('PaletteTargetMaster creation', () {
      final target = PaletteTargetMaster(
        saturationWeight: 0.5,
        lightnessWeight: 0.3,
        populationWeight: 0.2,
      );

      expect(target.saturationWeight, 0.5);
      expect(target.lightnessWeight, 0.3);
      expect(target.populationWeight, 0.2);
    });

    test('PaletteTargetMaster predefined targets', () {
      expect(PaletteTargetMaster.vibrant, isNotNull);
      expect(PaletteTargetMaster.lightVibrant, isNotNull);
      expect(PaletteTargetMaster.darkVibrant, isNotNull);
      expect(PaletteTargetMaster.muted, isNotNull);
      expect(PaletteTargetMaster.lightMuted, isNotNull);
      expect(PaletteTargetMaster.darkMuted, isNotNull);
    });

    test('ColorSpace enum values', () {
      expect(ColorSpace.values.length, 3);
      expect(ColorSpace.values.contains(ColorSpace.rgb), true);
      expect(ColorSpace.values.contains(ColorSpace.hsv), true);
      expect(ColorSpace.values.contains(ColorSpace.lab), true);
    });

    test('PaletteColorMaster creation', () {
      const color = PaletteColorMaster(Colors.red, 100);
      expect(color.color, Colors.red);
      expect(color.population, 100);
    });

    test('EncodedImageMaster creation', () {
      final byteData = ByteData(4);
      byteData.setUint8(0, 1);
      byteData.setUint8(1, 2);
      byteData.setUint8(2, 3);
      byteData.setUint8(3, 4);

      final encodedImage = EncodedImageMaster(
        byteData,
        width: 100,
        height: 100,
      );
      expect(encodedImage.width, 100);
      expect(encodedImage.height, 100);
      expect(encodedImage.byteData.lengthInBytes, 4);
    });

    test('Basic package structure', () {
      // Test that main classes are available
      expect(PaletteTargetMaster, isNotNull);
      expect(PaletteColorMaster, isNotNull);
      expect(EncodedImageMaster, isNotNull);
      expect(ColorSpace, isNotNull);
    });
  });
}
