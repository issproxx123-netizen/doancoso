import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'classifier.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  Classifier _classifier = Classifier();
  String _result = "Đang khởi động AI...";
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // BƯỚC 1: Nạp model trước
    await _classifier.loadModel();
    
    // BƯỚC 2: Sau khi nạp xong mới lấy danh sách Camera
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      controller = CameraController(
        cameras[0], 
        ResolutionPreset.medium, 
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Chuẩn cho Android
      );

      await controller!.initialize();
      
      // BƯỚC 3: Bắt đầu quét luồng ảnh
      controller!.startImageStream((CameraImage image) {
        if (!isProcessing) {
          isProcessing = true;
          _analyzeImage(image);
        }
      });

      if (mounted) {
        setState(() {
          _result = "Sẵn sàng nhận diện!";
        });
      }
    }
  }

  void _analyzeImage(CameraImage image) async {
    // Chuyển đổi định dạng ảnh từ Camera sang định dạng thư viện Image hiểu
    img.Image convertedImage = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      numChannels: 1, // Xử lý nhanh
    );

    // Gọi AI dự đoán
    String finalResult = _classifier.predict(convertedImage);

    if (mounted) {
      setState(() {
        _result = "Phát hiện: $finalResult";
      });
    }
    
    // Nghỉ 500ms để không bị giật lag máy Xiaomi
    await Future.delayed(Duration(milliseconds: 500));
    isProcessing = false;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("HUTECH AI - PHÂN LOẠI RÁC"),
        backgroundColor: Colors.green[900],
        elevation: 0,
      ),
      body: Stack(
        children: [
          CameraPreview(controller!),
          // Khung vuông soi rác
          Center(
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          // Bảng kết quả dưới cùng
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(30),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
              ),
              child: Text(
                _result,
                style: TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}