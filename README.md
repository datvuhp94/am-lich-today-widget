# 🏮 Âm Lịch Today — Desktop Widget

[![Website](https://img.shields.io/badge/website-amlich.today-red)](https://amlich.today)
[![License](https://img.shields.io/badge/license-GPL--3.0-blue)](LICENSE)

Widget lịch âm Việt Nam cho **KDE Plasma 6** và **GNOME 45+**, lấy dữ liệu real-time từ [amlich.today](https://amlich.today)

## ✨ Tính năng

- 📅 Ngày âm lịch, can chi, ngũ hành
- ⭐ Đánh giá ngày (Đại Cát / Cát / Trung Bình / Xấu)
- ⏰ Giờ hoàng đạo, chi tiết 12 giờ
- 🧭 Hướng xuất hành (Hỷ Thần, Tài Thần, Hạc Thần)
- 🔮 Lục Diệu, Nhị Thập Bát Tú, 12 Trực (nên/kỵ)
- 📆 Ngày đẹp trong tháng (Đại Cát + Cát)
- 🎉 Ngày lễ, tiết khí
- 🔄 Tự động cập nhật mỗi 30 phút & lúc nửa đêm

## 🚀 Cài đặt

**Chỉ cần 1 lệnh:**

```bash
curl -sSL https://amlich.today/install-widget | bash
```

Hoặc dùng `wget`:

```bash
wget -qO- https://amlich.today/install-widget | bash
```

Script tự nhận diện KDE Plasma / GNOME và cài đặt phiên bản tương ứng.

### Cài thủ công

```bash
# KDE Plasma 6
curl -sSL https://amlich.today/install-widget | bash -s -- --plasma

# GNOME 45+
curl -sSL https://amlich.today/install-widget | bash -s -- --gnome
```

### Gỡ cài đặt

```bash
curl -sSL https://amlich.today/install-widget | bash -s -- --uninstall
```

### Cài từ source

```bash
git clone https://github.com/datvuhp94/am-lich-today-widget.git
cd am-lich-today-widget
chmod +x install-widget.sh
./install-widget.sh
```

## 📸 Screenshots

### KDE Plasma 6

Widget trên desktop hiện đầy đủ: ngày âm to, giờ hoàng đạo, hướng xuất hành, lục diệu/trực/sao.
Click mở popup chi tiết 2 cột + ngày đẹp trong tháng.

### GNOME Shell

Nút trên top bar hiện `ngày/tháng Âm + Can Chi`.
Click mở popup 2 cột chi tiết với đầy đủ thông tin.

## 🖥 Hỗ trợ

| Desktop       | Phiên bản      | Vị trí hiển thị          |
| ------------- | -------------- | ------------------------ |
| KDE Plasma    | 6.x            | Widget trên Desktop      |
| GNOME Shell   | 45, 46, 47, 48 | Nút trên Top Bar        |

## 🔗 API

Widget lấy dữ liệu từ API public:

```
GET https://amlich.today/api/widget
GET https://amlich.today/api/widget?date=20/02/2026
```

Trả về JSON đầy đủ thông tin ngày âm dương, can chi, giờ hoàng đạo, lục diệu, sao 28, trực, hướng xuất hành, ngày đẹp trong tháng.

## 📁 Cấu trúc

```
plasmoid/                          # KDE Plasma 6
  com.amlich.today/
    metadata.json
    contents/ui/main.qml

gnome-extension/                   # GNOME Shell
  amlich-today@amlich.today/
    metadata.json
    extension.js
    stylesheet.css

install-widget.sh                  # Script cài đặt chung
```

## 📄 License

GPL-3.0 — [amlich.today](https://amlich.today)
