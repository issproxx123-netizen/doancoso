import 'dart:typed_data';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img; // Thư viện quan trọng để xử lý màu sắc

class Classifier {
  Interpreter? _interpreter;
  final List<String> _labels = ['Glass', 'Metal', 'Organic', 'Paper', 'Plastic'];

  Future<bool> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model_rac_thai.tflite');
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- LUỒNG 1: QUÉT CAMERA (Dùng Plane 0 để tối ưu tốc độ) ---
  String predict(CameraImage image) {
    if (_interpreter == null) return "AI chưa sẵn sàng";
    try {
      var input = _processCameraImage(image);
      var output = List.filled(1 * 5, 0.0).reshape([1, 5]);
      _interpreter!.run(input, output);

      int maxIndex = 0;
      double maxScore = -1.0;
      for (int i = 0; i < 5; i++) {
        if (output[0][i] > maxScore) {
          maxScore = output[0][i];
          maxIndex = i;
        }
      }
      if (maxScore < 0.5) return "Hãy đưa lại gần hơn...";
      return "${_labels[maxIndex]} (${(maxScore * 100).toStringAsFixed(1)}%)";
    } catch (e) {
      return "Đang quét..."; 
    }
  }

  // --- LUỒNG 2: PHÂN TÍCH ẢNH GALLERY (Đã sửa lỗi giữ nguyên 3 kênh màu RGB) ---
  Future<String> predictImageFile(File imageFile) async {
    if (_interpreter == null) return "AI chưa sẵn sàng";
    try {
      final imageData = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageData);
      // Resize ảnh về đúng kích thước MobileNetV2 yêu cầu
      final resizedImage = img.copyResize(decodedImage!, width: 224, height: 224);

      var input = List.generate(1, (i) => 
          List.generate(224, (j) => 
              List.generate(224, (k) => 
                  List.filled(3, 0.0))));

      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          
          // SỬA LỖI TẠI ĐÂY: Lấy giá trị màu thật của từng kênh R, G, B
          input[0][y][x][0] = pixel.r / 255.0; // Màu Đỏ
          input[0][y][x][1] = pixel.g / 255.0; // Màu Xanh lá
          input[0][y][x][2] = pixel.b / 255.0; // Màu Xanh dương
        }
      }

      var output = List.filled(1 * 5, 0.0).reshape([1, 5]);
      _interpreter!.run(input, output);

      int maxIndex = 0;
      double maxScore = -1.0;
      for (int i = 0; i < 5; i++) {
        if (output[0][i] > maxScore) { maxScore = output[0][i]; maxIndex = i; }
      }
      
      // Vẫn giữ ngưỡng tin cậy để kết quả thật sự chính xác
      if (maxScore < 0.5) return "Ảnh không rõ, hãy thử lại!";
      return "${_labels[maxIndex]} (${(maxScore * 100).toStringAsFixed(1)}%)";
    } catch (e) {
      return "Lỗi phân tích File";
    }
  }

  // Xử lý ảnh Camera (Dành cho quét thời gian thực)
  List _processCameraImage(CameraImage image) {
    var input = List.generate(1, (i) => List.generate(224, (j) => List.generate(224, (k) => List.filled(3, 0.0))));
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        int px = (x * image.width / 224).floor();
        int py = (y * image.height / 224).floor();
        double pixelValue = image.planes[0].bytes[py * image.width + px] / 255.0;
        input[0][y][x][0] = pixelValue;
        input[0][y][x][1] = pixelValue;
        input[0][y][x][2] = pixelValue;
      }
    }
    return input;
  }
}