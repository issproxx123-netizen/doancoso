import os
import tensorflow as tf


path = r'C:\Users\USER\Downloads\DoAn_RacThai\archive\archive\Garbage classification\Garbage classification'
print("--- THỐNG KÊ DỮ LIỆU ĐỒ ÁN HUTECH - TUẦN 2 ---")
print(f"Phiên bản TensorFlow: {tf.__version__}")

total = 0
for folder in os.listdir(path):
    folder_path = os.path.join(path, folder)
    if os.path.isdir(folder_path):
        count = len([f for f in os.listdir(folder_path) if f.lower().endswith(('.jpg', '.png', '.jpeg'))])
        print(f"   + {folder.upper()}: {count} ảnh")
        total += count

print(f"==> TỔNG CỘNG: {total} tấm ảnh. ĐÃ SẴN SÀNG CHO TUẦN 3!")