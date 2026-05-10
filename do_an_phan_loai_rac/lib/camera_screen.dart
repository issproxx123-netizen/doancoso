import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'classifier.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Classifier _classifier = Classifier();
  String _result = "Đang nạp AI...";
  bool _isPredicting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    bool loaded = await _classifier.loadModel();
    if (loaded) {
      final cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);
      await _controller!.initialize();
      _startStream();
    }
  }

  void _startStream() {
    _controller!.startImageStream((CameraImage image) async {
      if (_isPredicting) return;
      if (mounted) setState(() { _isPredicting = true; });
      final res = _classifier.predict(image);
      if (mounted) setState(() { _result = res; });
      await Future.delayed(Duration(seconds: 1));
      if (mounted) setState(() { _isPredicting = false; });
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (_controller != null) await _controller!.stopImageStream();
      setState(() { _isPredicting = true; _result = "Đang phân tích ảnh thật..."; });
      
      final res = await _classifier.predictImageFile(File(pickedFile.path));
      
      setState(() { _result = "Gallery: $res"; _isPredicting = false; });
    }
  }

  IconData _getIcon(String result) {
    if (result.contains('Paper')) return Icons.description;
    if (result.contains('Metal')) return Icons.build;
    if (result.contains('Plastic')) return Icons.opacity;
    if (result.contains('Glass')) return Icons.liquor;
    if (result.contains('Organic')) return Icons.eco;
    return Icons.center_focus_strong;
  }

  Color _getColor(String result) {
    if (result.contains('Paper')) return Colors.blue;
    if (result.contains('Metal')) return Colors.red;
    if (result.contains('Plastic')) return Colors.orange;
    if (result.contains('Glass')) return Colors.teal;
    if (result.contains('Organic')) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Waste Scan - Bảo Anh & Nam"),
        backgroundColor: _getColor(_result),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            Positioned.fill(child: CameraPreview(_controller!))
          else
            Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.fromLTRB(30, 0, 30, 100),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), 
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getColor(_result), width: 3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getIcon(_result), color: _getColor(_result), size: 35),
                  SizedBox(width: 15),
                  Flexible(child: Text(_result, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getColor(_result)))),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: _getColor(_result),
        child: Icon(Icons.photo_library, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }
}