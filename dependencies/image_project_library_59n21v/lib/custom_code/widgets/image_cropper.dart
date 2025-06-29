// Automatic FlutterFlow imports
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:crop_image/crop_image.dart';

class ImageCropper extends StatefulWidget {
  const ImageCropper({
    Key? key,
    this.width,
    this.height,
    required this.imageData,
    this.loadImage,
    required this.nextPage,
    required this.nextPageParameterName,
  }) : super(key: key);

  final double? width;
  final double? height;
  final FFUploadedFile imageData;
  final Future Function()? loadImage;
  final String nextPage;
  final String nextPageParameterName;

  @override
  State<ImageCropper> createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  late CropController _controller;
  late Image _croppedImage;

  @override
  void initState() {
    super.initState();
    _controller = CropController();
    _croppedImage = Image.memory(widget.imageData.bytes!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: CropImage(
              controller: _controller,
              image: _croppedImage,
              paddingSize: 25.0,
              alwaysMove: true,
            ),
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _controller.rotation = CropRotation.up;
            _controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
            _controller.aspectRatio = 1.0;
          },
        ),
        IconButton(
          icon: const Icon(Icons.aspect_ratio),
          onPressed: _aspectRatios,
        ),
        IconButton(
          icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
          onPressed: _rotateLeft,
        ),
        IconButton(
          icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
          onPressed: _rotateRight,
        ),
        TextButton(
          onPressed: () {
            _finished();
          },
          child: const Text('Done'),
        ),
      ],
    );
  }

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [
            // special case: no aspect ratio
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1.0),
              child: const Text('free'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1 / 2),
              child: const Text('1:2'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      _controller.aspectRatio = value == -1 ? null : value;
      _controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _rotateLeft() async => _controller.rotateLeft();

  Future<void> _rotateRight() async => _controller.rotateRight();

  Future<void> _finished() async {
    final Image croppedImage = await _controller.croppedImage();

    Future<void> _navigateToNextPage(BuildContext context) async {
      final ui.Image croppedBitmap = await _controller.croppedBitmap();
      final ByteData? byteData =
          await croppedBitmap.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final uploadedFile =
            FFUploadedFile(bytes: bytes); // Create FFUploadedFile object
        // Navigate to the next page and pass the FFUploadedFile object as a parameter
        context.pushNamed(
          widget.nextPage,
          queryParameters: {
            widget.nextPageParameterName: serializeParam(
              uploadedFile,
              ParamType.FFUploadedFile,
            ),
          }.withoutNulls,
        );
      }
    }

    await showDialog<bool>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(6.0),
          titlePadding: const EdgeInsets.all(8.0),
          title: const Text('Cropped image'),
          children: [
            Text('relative: ${_controller.crop}'),
            Text('pixels: ${_controller.cropSize}'),
            const SizedBox(height: 5),
            croppedImage,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToNextPage(context);
                  },
                  child: const Text('Confirm'), // Change text to 'Confirm'
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // You can add any additional actions here, such as resetting the crop
                  },
                  child: const Text('Edit'), // Add a button for editing
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
