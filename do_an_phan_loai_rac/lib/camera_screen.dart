import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'classifier.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Classifier _classifier = Classifier();
  String _result = "Đang nạp mô hình AI...";
  bool _isPredicting = false; // Biến quan trọng chống nghẽn luồng

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Nạp mô hình AI MobileNetV2 (91.11%)
    bool loaded = await _classifier.loadModel();
    if (loaded) {
      final cameras = await availableCameras();
      // 2. Thiết lập Camera với độ phân giải thấp (low) để xử lý nhanh nhất có thể
      _controller = CameraController(
        cameras[0], 
        ResolutionPreset.low, 
        enableAudio: false
      );
      
      await _controller!.initialize();
      
      // 3. Bắt đầu luồng ảnh từ Camera
      _controller!.startImageStream((CameraImage image) async {
        // CƠ CHẾ CHỐNG TREO: Nếu đang xử lý ảnh cũ thì bỏ qua ảnh mới
        if (_isPredicting) return;

        if (mounted) {
          setState(() {
            _isPredicting = true;
            _result = "Đang phân tích...";
          });
        }

        try {
          // 4. Gọi bộ phân loại AI xử lý ảnh
          final res = _classifier.predict(image);

          if (mounted) {
            setState(() {
              _result = res; // Hiển thị kết quả (Ví dụ: Paper 61.74%)
            });
          }
        } catch (e) {
          debugPrint("Lỗi phân tích AI: $e");
        }

        // 5. NGHỈ 1 GIÂY để CPU điện thoại không bị quá tải
        await Future.delayed(Duration(seconds: 1));
        
        if (mounted) {
          setState(() {
            _isPredicting = false;
          });
        }
      });

      if (mounted) setState(() { _result = "Sẵn sàng nhận diện!"; });
    } else {
      if (mounted) setState(() { _result = "Lỗi nạp mô hình .tflite"; });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phân Loại Rác - Bảo Anh & Nam"),
        backgroundColor: Colors.green[800],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Hiển thị khung hình Camera
          if (_controller != null && _controller!.value.isInitialized)
            Positioned.fill(child: CameraPreview(_controller!))
          else
            Center(child: CircularProgressIndicator()),
          
          // Hiển thị kết quả AI
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(40),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), 
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]
              ),
              child: Text(
                _result, 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.green[900]
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}