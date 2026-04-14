import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Classifier {
  Interpreter? _interpreter;
  // Danh sách nhãn khớp với 5 folder ảnh của Bảo Anh
  final List<String> labels = ["Glass", "Metal", "Organic", "Paper", "Plastic"];

  Future<void> loadModel() async {
    try {
      // Nạp file từ thư mục assets
      _interpreter = await Interpreter.fromAsset('assets/model_rac_thai.tflite');
      print("AI Brain: Nạp thành công!");
    } catch (e) {
      print("AI Brain Error: Không thể nạp model: $e");
    }
  }

  String predict(img.Image image) {
    if (_interpreter == null) return "AI chưa sẵn sàng";

    // 1. Resize ảnh về đúng chuẩn 224x224
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // 2. Chuyển ảnh thành mảng Tensor Float32 (Chuẩn cho bản image 4.x)
    var input = Float32List(1 * 224 * 224 * 3);
    int pixelIndex = 0;
    
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        var pixel = resizedImage.getPixel(x, y);
        // Chuẩn hóa pixel về khoảng [-1, 1]
        input[pixelIndex++] = (pixel.r - 127.5) / 127.5;
        input[pixelIndex++] = (pixel.g - 127.5) / 127.5;
        input[pixelIndex++] = (pixel.b - 127.5) / 127.5;
      }
    }

    // 3. Chạy dự đoán
    var output = List.filled(1 * 5, 0.0).reshape([1, 5]);
    _interpreter!.run(input.buffer.asUint8List(), output);

    // 4. Tìm nhãn có xác suất cao nhất
    double maxScore = -1;
    int maxIndex = 0;
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxScore) {
        maxScore = output[0][i];
        maxIndex = i;
      }
    }

    return "${labels[maxIndex]} (${(output[0][maxIndex] * 100).toStringAsFixed(2)}%)";
  }
}