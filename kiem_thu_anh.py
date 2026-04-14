import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image

# 1. Load mô hình đã train ở Tuần 3
model = tf.keras.models.load_model('model_rac_thai.h5')
categories = ['Glass', 'Metal', 'Organic', 'Paper', 'Plastic']

# 2. Hàm dự đoán ảnh
def predict_waste(img_path):
    img = image.load_img(img_path, target_size=(224, 224))
    img_array = image.img_to_array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    
    predictions = model.predict(img_array)
    result = categories[np.argmax(predictions)]
    confidence = np.max(predictions) * 100
    
    print(f"--- KẾT QUẢ KIỂM THỬ NHÓM NAM & BẢO ANH ---")
    print(f"Loại rác dự đoán: {result} ({confidence:.2f}%)")

# 3. Chạy thử với 1 tấm ảnh rác bất kỳ trong máy
# Bạn thay đường dẫn ảnh thực tế của bạn vào đây nhé
test_img = r'C:\Users\USER\Downloads\test_rac.jpg' 
predict_waste(test_img)