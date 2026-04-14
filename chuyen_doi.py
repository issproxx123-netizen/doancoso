import tensorflow as tf

# 1. Tải mô hình .h5 bạn vừa huấn luyện xong
model = tf.keras.models.load_model('model_rac_thai.h5')

# 2. Chuyển đổi sang định dạng TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# 3. Lưu file lại để tuần sau đưa vào Flutter
with open('model_rac_thai.tflite', 'wb') as f:
    f.write(tflite_model)

print("--- CHUYỂN ĐỔI THÀNH CÔNG! ---")