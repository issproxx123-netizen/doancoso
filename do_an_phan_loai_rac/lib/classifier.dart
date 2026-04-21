import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';

class Classifier {
  Interpreter? _interpreter;
  final List<String> _labels = ['Glass', 'Metal', 'Organic', 'Paper', 'Plastic'];

  Future<bool> loadModel() async {
    try {
      // Nạp model với cấu hình tối ưu cho di động
      _interpreter = await Interpreter.fromAsset('assets/model_rac_thai.tflite');
      return true;
    } catch (e) {
      return false;
    }
  }

  String predict(CameraImage image) {
    if (_interpreter == null) return "AI chưa sẵn sàng";
    try {
      // 1. Chuyển đổi ảnh Camera sang mảng số chuẩn AI
      var input = _processImage(image);
      
      // 2. Tạo mảng chứa kết quả đầu ra [1, 5]
      var output = List.filled(1 * 5, 0.0).reshape([1, 5]);

      // 3. CHẠY AI
      _interpreter!.run(input, output);

      // 4. Tìm nhãn có điểm cao nhất
      int maxIndex = 0;
      double maxScore = -1.0;
      for (int i = 0; i < 5; i++) {
        if (output[0][i] > maxScore) {
          maxScore = output[0][i];
          maxIndex = i;
        }
      }
      
      return "${_labels[maxIndex]} (${(maxScore * 100).toStringAsFixed(1)}%)";
    } catch (e) {
      // In lỗi ra terminal để Bảo Anh dễ debug
      print("Lỗi AI: $e");
      return "Đang phân tích..."; 
    }
  }

  // HÀM XỬ LÝ ẢNH MỚI - GIÚP AI NHÌN ĐƯỢC HÌNH ẢNH
  List _processImage(CameraImage image) {
    // Chuyển đổi về dạng List 4 chiều [1, 224, 224, 3] mà Model yêu cầu
    var input = List.generate(1, (i) => 
        List.generate(224, (j) => 
            List.generate(224, (k) => 
                List.filled(3, 0.0))));

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        // Lấy tọa độ pixel tương ứng trên ảnh gốc
        int px = (x * image.width / 224).floor();
        int py = (y * image.height / 224).floor();
        
        // Lấy dữ liệu từ Plane 0 (Y) - đại diện cho đặc điểm vật thể
        double pixelValue = image.planes[0].bytes[py * image.width + px] / 255.0;
        
        // Gán vào 3 kênh màu RGB (AI sẽ nhìn dưới dạng ảnh Grayscale giả lập RGB)
        input[0][y][x][0] = pixelValue;
        input[0][y][x][1] = pixelValue;
        input[0][y][x][2] = pixelValue;
      }
    }
    return input;
  }
}