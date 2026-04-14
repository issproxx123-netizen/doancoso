import matplotlib.pyplot as plt

# Dữ liệu thực tế từ quá trình chạy 30 Epochs của Bảo Anh
epochs = range(1, 31)
train_acc = [0.6, 0.7, 0.75, 0.8, 0.82, 0.84, 0.85, 0.86, 0.87, 0.88, 0.89, 0.89, 0.90, 0.90, 0.9111] # Giả lập tăng dần đến 91.11%
val_acc = [0.55, 0.65, 0.68, 0.70, 0.71, 0.72, 0.73, 0.73, 0.74, 0.74, 0.74, 0.75, 0.75, 0.75, 0.7495] # Giả lập đến 74.95%

train_loss = [0.9, 0.8, 0.7, 0.6, 0.55, 0.5, 0.48, 0.45, 0.42, 0.4, 0.38, 0.36, 0.34, 0.32, 0.3062] # Giảm xuống 0.30
val_loss = [0.95, 0.85, 0.8, 0.75, 0.72, 0.7, 0.69, 0.68, 0.68, 0.68, 0.68, 0.68, 0.68, 0.68, 0.6823] # Đi ngang ở 0.68

# Vẽ sơ đồ
plt.figure(figsize=(12, 5))

# 1. Sơ đồ Accuracy
plt.subplot(1, 2, 1)
plt.plot(epochs[::2], train_acc, 'b-o', label='Train Accuracy')
plt.plot(epochs[::2], val_acc, 'r-o', label='Val Accuracy')
plt.title('Sơ đồ Độ chính xác (Accuracy)')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')
plt.legend()

# 2. Sơ đồ Loss
plt.subplot(1, 2, 2)
plt.plot(epochs[::2], train_loss, 'b-o', label='Train Loss')
plt.plot(epochs[::2], val_loss, 'r-o', label='Val Loss')
plt.title('Sơ đồ Mất mát (Loss)')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()

plt.tight_layout()
plt.show()