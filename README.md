Hướng dẫn cài đặt và sử dụng
Cài đặt
Tạo thư mục qb-jobgarage trong thư mục resources của server FiveM của bạn.
Tạo các thư mục con: client, server, và sql.
Tạo các file như đã cung cấp ở trên và đặt chúng vào các thư mục tương ứng.
Chạy file SQL trong database của bạn để tạo bảng job_vehicles.
Thêm ensure qb-jobgarage vào file server.cfg của bạn.
Khởi động lại server hoặc chạy lệnh refresh và ensure qb-jobgarage trong console.
Yêu cầu
QBCore Framework
oxmysql
ox_lib (tùy chọn, nếu bạn sử dụng Config.UseOxLib = true)
qb-target hoặc ox_target (tùy chọn, nếu bạn sử dụng Config.UseTarget = true)
Cấu hình
Bạn có thể tùy chỉnh script bằng cách chỉnh sửa file config.lua:

Thêm nghề nghiệp mới:

Thêm một mục mới vào Config.JobGarages với tên nghề nghiệp làm khóa.
Cấu hình các vị trí garage, danh sách xe và giới hạn số lượng xe theo cấp bậc.
Thêm vị trí garage mới:

Thêm một mục mới vào mảng locations của nghề nghiệp tương ứng.
Cấu hình tọa độ lấy xe, tọa độ spawn xe và tọa độ cất xe.
Thêm xe mới:

Thêm một mục mới vào mảng vehicles của cấp bậc tương ứng.
Cấu hình model, label, livery và extras của xe.
Thay đổi giới hạn số lượng xe:

Chỉnh sửa giá trị trong bảng limits của nghề nghiệp tương ứng.
Cấu hình tương tác:

Bạn có thể chọn sử dụng target system hoặc DrawText bằng cách điều chỉnh Config.UseTarget và Config.UseDrawText.
Sử dụng
Lấy xe:

Đến điểm lấy xe của nghề nghiệp của bạn.
Nhấn E (hoặc tương tác với target) để mở menu garage.
Chọn xe bạn muốn lấy.
Cất xe:

Lái xe đến điểm cất xe.
Nhấn E (hoặc tương tác với target) để cất xe vào garage.
Lệnh admin:

/clearvehicles [id] - Xóa tất cả xe của một người chơi.
/clearjobvehicles [job] - Xóa tất cả xe của một nghề nghiệp.
Tính năng
Quản lý garage riêng cho từng nghề nghiệp.
Giới hạn số lượng xe theo cấp bậc.
Lưu trữ tình trạng xe (nhiên liệu, độ hỏng thân xe, độ hỏng động cơ).
Hỗ trợ nhiều vị trí garage cho mỗi nghề nghiệp.
Hỗ trợ cả polyzone và target system.
Hỗ trợ DrawText khi không sử dụng target system.
Thông báo khi đạt giới hạn số lượng xe.
Tùy chỉnh livery và extras cho từng loại xe.
Lưu trữ và khôi phục tình trạng xe khi lấy ra và cất vào.
Khắc phục sự cố
Nếu bạn gặp vấn đề với script, hãy thử các giải pháp sau:

Xe không xuất hiện khi lấy ra:

Kiểm tra xem điểm spawn có bị chặn không.
Kiểm tra xem bạn đã đạt giới hạn số lượng xe chưa.
Kiểm tra logs server để xem có lỗi SQL nào không.
Không thể cất xe:

Đảm bảo bạn đang ngồi trong xe.
Kiểm tra xem xe có phải là xe của nghề nghiệp không.
Đảm bảo bạn đang ở gần điểm cất xe.
Không thể lấy xe đã cất:

Kiểm tra xem xe có được đánh dấu là đã cất trong database không (out = 0).
Kiểm tra xem bạn có đủ quyền để lấy xe không.
Lỗi ox_lib:

Đảm bảo ox_lib đã được cài đặt và hoạt động.
Nếu không muốn sử dụng ox_lib, hãy đặt Config.UseOxLib = false trong config.lua.
Lỗi target system:

Đảm bảo qb-target hoặc ox_target đã được cài đặt và hoạt động.
Nếu không muốn sử dụng target system, hãy đặt Config.UseTarget = false trong config.lua.
