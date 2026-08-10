# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Product Purpose

JMoney là ứng dụng quản lý tài chính cá nhân theo phương pháp hũ và ngân sách tháng. Người dùng lập kế hoạch, phân bổ thu nhập, ghi nhận chi tiêu, theo dõi mục tiêu và duy trì các khoản định kỳ mà không cần tài khoản cloud.

## Users

Người dùng cá nhân muốn duy trì kỷ luật phân bổ thu nhập và biết tiền đã được chi cho mục đích nào mà không cần tài khoản hay dịch vụ cloud.

## Operating Context

- Ghi nhanh khoản thu hoặc khoản chi trên điện thoại.
- Kiểm tra số dư từng hũ và tổng quan trong tháng.
- Điều chỉnh hũ, tỷ lệ phân bổ và danh mục theo nhu cầu cá nhân.
- Xem lại lịch sử và cơ cấu chi tiêu theo danh mục.
- Đặt hạn mức tháng, xem mức đã dùng và số tiền nên chi mỗi ngày.
- Theo dõi mục tiêu, quỹ dự phòng và các khoản định kỳ.

## Capabilities and Constraints

- Flutter là nền tảng triển khai.
- Giao diện hỗ trợ l10n.
- Tiếng Việt là ngôn ngữ mặc định.
- Tiếng Anh được chuẩn bị làm ngôn ngữ dự phòng.
- Dữ liệu được lưu 100% cục bộ bằng MMKV trong sandbox của ứng dụng; không có đăng nhập hoặc đồng bộ cloud.
- Trên Web, app dùng `localStorage` làm backend tương đương vì MMKV/FFI không hỗ trợ trình duyệt; dữ liệu vẫn chỉ nằm trong browser của người dùng.
- Trạng thái tài chính dùng snapshot JSON schema v2. Dữ liệu v1 được backup rồi migrate; import luôn backup trạng thái hiện tại trước khi thay thế.
- Bốn hũ mặc định: Nhu cầu thiết yếu 55%, Tiết kiệm & Đầu tư 25%, Hưởng thụ 10%, Giáo dục & Phát triển 10%.
- App dùng cảnh minh họa cục bộ theo tháng như một wallpaper nhẹ; cảnh quan và cặp cung tự đổi nhưng không làm thay đổi interactive tint hoặc màu ngữ nghĩa tài chính.
- Có template 4 hũ JMoney, 6 hũ và 50/20/30; áp dụng template không xóa hũ có lịch sử.
- Hũ có mô tả công dụng tùy chọn và mô tả này được lưu cùng snapshot MMKV.
- Hũ và danh mục hỗ trợ tạo, đọc, sửa, xóa.
- Catalog mặc định gồm 20 danh mục chi tiêu được nhóm theo hũ và 7 nguồn thu nhập; mỗi mục có icon Icons8 cục bộ. Giao dịch thu nhập lưu nguồn thu đã chọn.
- Từ Tổng quan, mỗi hũ có màn hình chi tiết riêng để ghi chi tiêu, nạp trực tiếp 100% vào hũ và xem lịch sử biến động số dư gồm thu, chi, chuyển vào và chuyển ra.
- Khoản thu hỗ trợ chia theo tỷ lệ, chia đều hoặc chia thủ công vào một tập hũ được chọn.
- Khoản chi bắt buộc chọn hũ và danh mục; app cảnh báo nhưng không chặn khi vượt hạn mức.
- Tổng chi, thống kê danh mục và tiến độ ngân sách được tính riêng theo tháng dương lịch; sang ngày 1 bắt đầu kỳ mới từ 0 nhưng không xóa giao dịch cũ.
- Người dùng có thể chuyển tháng trước/sau hoặc quay về tháng hiện tại trên Tổng quan. Mỗi tháng có số dư hũ riêng bắt đầu từ 0; tỷ lệ hũ kế thừa đúng tháng trước, hoặc dùng mặc định 55/25/10/10 khi không có kỳ trước.
- Thống kê cho phép chuyển tháng trước/sau hoặc quay về tháng hiện tại; tổng chi, biểu đồ và danh mục chỉ phản ánh kỳ tháng đang chọn.
- Lịch sử giao dịch được nhóm theo tháng rồi theo ngày để người dùng xem lại các kỳ trước.
- Chuyển tiền giữa hũ là giao dịch trung tính, không tính vào thu nhập hoặc chi tiêu.
- Giao dịch hỗ trợ sửa, tìm kiếm, lọc và ghi nguồn tiền.
- Mục tiêu và đóng góp chỉ earmark số tiền trong kế hoạch, không tự thay đổi số dư hũ liên kết.
- Lịch định kỳ tạo occurrence chống trùng. Người dùng có thể xác nhận, bỏ qua hoặc bật auto-post.
- Local notification là lớp hỗ trợ; việc từ chối quyền không được làm gián đoạn dữ liệu hoặc danh sách nhắc trong app.
- Giá trị tiền được lưu theo số nguyên VND; phần dư khi phân bổ được đưa vào hũ cuối để tổng tiền luôn khớp tuyệt đối.
- Mọi ô nhập tiền hiển thị dấu phân cách hàng nghìn theo locale trong lúc gõ và loại dấu định dạng trước khi ghi dữ liệu.
- Hũ đã có lịch sử tài chính không thể bị xóa nhằm bảo toàn số dư và dấu vết phân bổ.

## Brand Commitments

- Tên sản phẩm hiện tại là JMoney.
- Nhận diện là ứng dụng tài chính Apple-inspired: system typography, grouped surfaces, một interactive tint và navigation native. Minh họa theo tháng chỉ là lớp nhận diện phụ; không mang không khí casino hoặc gamification.

## Evidence on Hand

Đặc tả nghiệp vụ và danh sách dữ liệu seed được cung cấp trong yêu cầu ngày 31/07/2026. Chưa có tài sản thương hiệu hoặc tuyên bố thương mại.

## Product Principles

- Không tự giả định nghiệp vụ trước khi có yêu cầu.
- Mọi nội dung hiển thị cho người dùng đều đi qua hệ thống l10n.
- Tôn trọng quy ước và khả năng truy cập của từng nền tảng đích.
- Giao dịch tài chính và cập nhật số dư phải hoàn tất nguyên tử.
- Dữ liệu tài chính không rời khỏi thiết bị.
- Người dùng có thể đặt lại toàn bộ dữ liệu từ màn Quản lý; thao tác xóa cả snapshot, bản sao lưu và lịch nhắc, sau đó tạo lại 4 hũ cùng danh mục mặc định.
