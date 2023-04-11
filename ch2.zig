const std = @import("std");
const expect = std.testing.expect;

// take pages of memory from heap = large amounts of data
test "Page" {
  const allocator = std.heap.page_allocator;

  const memory = try allocator.alloc(u8, 100);
  defer allocator.free(memory);

  try expect(memory.len == 100);
  try expect(@TypeOf(memory) == []u8);
}

// create fixed buffer - no heap
test "FBA" {
  var buffer: [1000]u8 = undefined;
  var fba = std.heap.FixedBufferAllocator.init(&buffer);
  const allocator = fba.allocator();

  const memory = try allocator.alloc(u8, 100);
  defer allocator.free(memory);

  try expect(memory.len == 100);
  try expect(@TypeOf(memory) == []u8);
}

// allocate many times - free once
test "Arena" {
  var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer arena.deinit();
  const allocator = arena.allocator();

  _ = try allocator.alloc(u8, 1);
  _ = try allocator.alloc(u8, 10);
  _ = try allocator.alloc(u8, 100);
}

// GPA: double-free, use after free, detect leaks, safety checks + thread safety turned off w/ configs
// safety over performance - still many times faster than page allocator
test "GPA" {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  defer {
    const leaked = gpa.deinit();
    if (leaked) expect(false) catch @panic("Test failed");
  }
  const bytes = try allocator.alloc(u8, 100);
  defer allocator.free(bytes);
}

// High performance but no safety - std.heap.c_allocator
// must link libc w/ -lc in terminal calls

// ArrayList - like c++ std::vector
const eql = std.mem.eql;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

test "arraylist" {
  var list = ArrayList(u8).init(test_allocator);
  defer list.deinit();

  try list.append('H');
  try list.append('e');
  try list.append('l');
  try list.append('l');
  try list.append('o');
  try list.appendSlice(" World!");

  try expect(eql(u8, list.items, "Hello World!"));
}


// Basic filesystem
test "create, write, seekto, and read files" {
  const file = try std.fs.cwd().createFile(
  "junk_file.txt",
  .{.read=true},
  );
  defer file.close();

  const bytes_written = try file.writeAll("Hello File!");
  _ = bytes_written;

  var buffer: [100]u8 = undefined;
  try file.seekTo(0);
  const bytes_read = try file.readAll(&buffer);

  try expect(eql(u8, buffer[0..bytes_read], "Hello File!"));
}

// This is also failing - why
// test "file stat" {
//   const file = try std.fs.cwd().createFile(
//     "junk_file2.txt",
//     .{.read=true},
//   );
//   defer file.close();
//
//   const stat = try file.stat();
//   try expect(stat.size == 0);
//   try expect(stat.kind == .File);
//   try expect(stat.ctime == std.time.nanoTimestamp());
//   try expect(stat.mtime == std.time.nanoTimestamp());
//   try expect(stat.atime == std.time.nanoTimestamp());
// }

// I don't know why this doesnt work
// test "make dir" {
//     try std.fs.cwd().makeDir("test-tmp");
//     const dir = try std.fs.cwd().openDir(
//         "test-tmp",
//         .{ .iterate = true },
//     );
//     defer {
//         std.fs.cwd().deleteTree("test-tmp") catch unreachable;
//     }
//
//     _ = try dir.createFile("x", .{});
//     _ = try dir.createFile("y", .{});
//     _ = try dir.createFile("z", .{});
//
//     var file_count: usize = 0;
//     var iter = dir.iterate();
//     while (try iter.next()) |entry| {
//         if (entry.kind == .File) file_count += 1;
//     }
//
//     try expect(file_count == 3);
// }
//

// Readers + Writers
test "io writer usage" {
  var list = ArrayList(u8).init(test_allocator);
  defer list.deinit();

  const bytes_written = try list.writer().write("Hello World!");
  try expect(bytes_written == 12);
  try expect(eql(u8, list.items, "Hello World!"));
}

test "io reader usage" {
  const message = "Hello File!";

  const file = try std.
}
