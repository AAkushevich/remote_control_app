import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CaptureRepository {
  Future<ui.Image?> captureScreen(GlobalKey boundaryKey) async {
    try {
      RenderRepaintBoundary? boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print('Boundary is null');
        return null;
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      return image;
    } catch (e) {
      print('Error capturing screenshot: $e');
      return null;
    }
  }
}
