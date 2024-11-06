const std = @import("std");
const debug = std.debug;
const mem = std.mem;
const net = std.net;
const os = std.os;
const posix = std.posix;

const IoUring = std.os.linux.IoUring;

const linux = std.os.linux;

pub fn main() !void {
    // Khởi tạo io_uring với 1 entry
    var ring = try IoUring.init(1, 0);
    defer ring.deinit();

    // Chuẩn bị một SQE để thực hiện write(2) vào stdout (fd=1)
    const message = "Hello, uring!\n";
    const sqe = try ring.write(0, 1, message[0..], 0);

    // Gửi SQE tới kernel
    _ = try ring.submit();

    // Lấy CQE từ completion queue
    const cqe = try ring.copy_cqe();

    // Kiểm tra lỗi
    if (cqe.res < 0) {
        std.debug.print("Write failed: {}\n", .{-cqe.res});
        return;
    }

    std.debug.print("Wrote {} bytes\n", .{sqe.len});
}
