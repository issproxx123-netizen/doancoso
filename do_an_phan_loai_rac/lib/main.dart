import 'package:flutter/material.dart';
import 'camera_screen.dart'; // Import file mắt thần mà bạn vừa tạo

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GarbageApp(),
    ));

class GarbageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HUTECH - Phân Loại Rác AI'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Thông tin mô hình bạn đã train trên máy MSI
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.analytics, color: Colors.blue, size: 40),
                title: Text('Mô hình: MobileNetV2', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Độ chính xác: 91.11%'),
              ),
            ),
            SizedBox(height: 50),
            
            // Hình ảnh minh họa Camera
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_enhance, size: 80, color: Colors.green),
                      SizedBox(height: 10),
                      Text("Hệ thống đã sẵn sàng", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            
            // NÚT BẤM ĐÃ ĐƯỢC "ĐẤU DÂY"
            ElevatedButton(
              onPressed: () {
                // Lệnh chuyển sang màn hình Camera
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              child: Text(
                'BẮT ĐẦU QUÉT RÁC',
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            
            SizedBox(height: 15),
            Text(
              "Sinh viên thực hiện: Trình Bảo Anh",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}