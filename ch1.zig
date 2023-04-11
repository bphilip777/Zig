const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;


test "basic variables and constants" {
  const constant: i32 = 5;
  var variable: u32 = 5000;

  const inferred_constant = @as(i32, 5);
  var inferred_variable = @as(u32, 5000);

  const a: i32 = undefined;
  var b: u32 = undefined;

  _ = constant;
  _ = variable;
  _ = inferred_constant;
  _ = inferred_variable;
  _ = a;
  _ = b;
}

test "arrays" {
  const a = [5]u8{'h', 'e', 'l', 'l', 'o'};
  const b = [_]u8{'w', 'o', 'r', 'l', 'd'};  
  _ = a;
  const len = b.len;
  print("{}", .{len});  
}

test "if state" {
  const a = true;
  var x: u16 = 0;
  if (a) {
    x += 1;
  } else {
    x += 2;
  }
  try expect(x == 1);
}

test "if state expr" {
  const a = true;
  var x: u16 = 0;
  x += if(a) 1 else 2;
  try expect(x == 1);
}

test "while" {

}
