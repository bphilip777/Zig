const std = @import("std");

fn multiples_of_n(limit: i32, n: i32) i32 {
  var val: i32 = 0;
  var sum: i32 = 0;
  while (val < limit) : (val += n) {
    sum += val;
  }
  return sum;
}

pub fn main() void {
  const limit: i32 = 1000;
  var m3: i32 = multiples_of_n(limit, 3);
  var m5: i32 = multiples_of_n(limit, 5);
  var m15: i32 = multiples_of_n(limit, 15);
  std.debug.print("Ans:{}", .{m3+m5-m15});

}
