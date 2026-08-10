# JMoney

Ứng dụng quản lý tài chính cá nhân theo hũ, lưu dữ liệu 100% cục bộ bằng MMKV
trong sandbox của ứng dụng. JMoney hỗ trợ các template 4 hũ, 6 hũ và 50/20/30;
ngân sách tháng; mục tiêu; quỹ dự phòng; giao dịch định kỳ; chuyển tiền giữa
các hũ; và chia thu nhập tự động, chia đều hoặc thủ công.

MMKV lưu một snapshot JSON có version dưới instance `jmoney.finance`. Schema v2
tự động migrate dữ liệu v1 và giữ bản backup gần nhất trước khi migrate hoặc
khôi phục dữ liệu. Người dùng cũng có thể export/import snapshot JSON trong app.
Khi chạy trên Web/Chrome, cùng snapshot đó được lưu trong `localStorage` vì
MMKV dùng FFI và không hỗ trợ Web.

Nhắc giao dịch định kỳ dùng local notification trên Android/iOS/macOS. Nếu
quyền notification bị từ chối, các kỳ đến hạn vẫn xuất hiện trong danh sách
chờ xác nhận của ứng dụng.

## Run

```sh
flutter pub get
flutter gen-l10n
flutter test
flutter run
```

The repository helper supports all Flutter targets and common checks:

```sh
./tool/jmoney.sh web
./tool/jmoney.sh android
./tool/jmoney.sh ios
./tool/jmoney.sh reset
./tool/jmoney.sh check
```

Run `./tool/jmoney.sh help` for the complete command list.

Tiếng Việt là locale mặc định. ARB tiếng Anh được duy trì làm bản dịch dự
phòng tại `lib/l10n`.
