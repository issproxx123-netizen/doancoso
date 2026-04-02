import tensorflow as tf
from tensorflow.keras.preprocessing import image_dataset_from_directory

# 1. Đường dẫn Dataset (Giữ nguyên như file kiem_tra.py)
path = r'C:\Users\USER\Downloads\DoAn_RacThai\archive\archive\Garbage classification\Garbage classification'

# 2. Chia dữ liệu 80% học (Train), 20% kiểm tra (Val)
train_ds = image_dataset_from_directory(
    path, validation_split=0.2, subset="training", seed=123,
    image_size=(224, 224), batch_size=32)

val_ds = image_dataset_from_directory(
    path, validation_split=0.2, subset="validation", seed=123,
    image_size=(224, 224), batch_size=32)

# 3. Dùng mô hình MobileNetV2 (Nhẹ, chạy mượt trên điện thoại)
base_model = tf.keras.applications.MobileNetV2(input_shape=(224, 224, 3), include_top=False, weights='imagenet')
base_model.trainable = False 

model = tf.keras.Sequential([
    base_model,
    tf.keras.layers.GlobalAveragePooling2D(),
    tf.keras.layers.Dense(5, activation='softmax') # Phân loại 5 loại rác
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# 4. Bắt đầu huấn luyện (Chạy 5 vòng để lấy báo cáo)
print("--- NHÓM NAM & BẢO ANH BẮT ĐẦU HUẤN LUYỆN ---")
model.fit(train_ds, validation_data=val_ds, epochs=5)

# 5. Lưu kết quả thành file model
model.save('model_rac_thai.h5')
print("--- ĐÃ LƯU MÔ HÌNH THÀNH CÔNG ---")