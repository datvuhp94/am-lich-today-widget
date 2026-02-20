# 🏮 Âm Lịch Today — Desktop Widget

Widget lịch âm Việt Nam cho **KDE Plasma 6** và **GNOME 45+**, lấy dữ liệu từ [amlich.today](https://amlich.today)

## Tính năng

- 📅 Hiển thị ngày âm lịch, can chi
- ⭐ Đánh giá ngày (Đại Cát / Cát / Trung Bình / Xấu)
- ⏰ Giờ hoàng đạo, chi tiết 12 giờ
- 🧭 Hướng xuất hành (Hỷ Thần, Tài Thần, Hạc Thần)
- 🔮 Lục Diệu, Nhị Thập Bát Tú, 12 Trực (nên/kỵ)
- 📆 Ngày đẹp trong tháng (Đại Cát + Cát)
- 🎉 Ngày lễ, tiết khí
- 🔄 Tự động cập nhật mỗi 30 phút & lúc nửa đêm

## Cài đặt nhanh

**Chỉ cần 1 lệnh** (tự nhận diện KDE Plasma / GNOME):

```bash
curl -sSL https://amlich.today/install-widget | bash
```

Hoặc dùng `wget`:

```bash
wget -qO- https://amlich.today/install-widget | bash
```

### Cài thủ công

```bash
curl -sSL https://amlich.today/install-widget | bash -s -- --plasma    # KDE Plasma 6
curl -sSL https://amlich.today/install-widget | bash -s -- --gnome     # GNOME 45+
```

### Gỡ cài đặt

```bash
curl -sSL https://amlich.today/install-widget | bash -s -- --uninstall
```

### Cài từ source

```bash
git clone https://github.com/bixacloud/lich-am.git
cd lich-am
chmod +x install-widget.sh
./install-widget.sh
```

## Hỗ trợ

| Desktop       | Phiên bản     | Vị trí hiển thị          |
| ------------- | ------------- | ------------------------ |
| KDE Plasma    | 6.x           | Widget trên Desktop      |
| GNOME Shell   | 45, 46, 47, 48| Nút trên Top Bar        |

## Screenshots

### KDE Plasma 6

Widget trên desktop hiện đầy đủ: ngày âm to, giờ hoàng đạo, hướng xuất hành, lục diệu/trực/sao. Click mở popup chi tiết + ngày đẹp.

### GNOME Shell

Nút trên top bar hiện `ngày/tháng Âm + Can Chi`. Click mở popup 2 cột chi tiết.

## API

```
GET https://amlich.today/api/widget
```

Trả về JSON đầy đủ thông tin ngày âm dương, can chi, giờ hoàng đạo, lục diệu, sao 28, trực, hướng xuất hành, ngày đẹp trong tháng.

## Cấu trúc

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

## License

MIT — [amlich.today](https://amlich.today)
