const std = @import("std");
const expect = std.testing.expect;

test "allocation" {
  const allocator = std.heap.page_allocator;

  const memory = try allocator.alloc(u8, 100);
  defer allocator.free(memory);

  try expect(memory.len == 100);
  try expect(@TypeOf(memory) == []u8);
}

test "fixed buffer allocator" {
  var buffer: [1000]u8 = undefined;
  var fba = std.heap.FixedBufferAllocator.init(&buffer);
  const allocator = fba.allocator();

  const memory = try allocator.alloc(u8, 100);
  defer allocator.free(memory);

  try expect(memory.len == 100);
  try expect(@TypeOf(memory) == []u8);
}

test "arena allocator" {
  var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer arena.deinit();
  const allocator = arena.allocator();

  _ = try allocator.alloc(u8, 1);
  _ = try allocator.alloc(u8, 10);
  _ = try allocator.alloc(u8, 100);

}
