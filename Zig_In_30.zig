const std = @import("std");

const y: i32 = 47;

fn foo() void {
  std.debug.print("Foo!\n", .{});
  // optional
  return;
}

fn baz() i32 {
  return 47;
}

fn bar(x: i32) void {
  std.debug.print("Bar param: {}\n", .{x});
}

const Vec2 = struct{
  x: f64,
  y: f64,
};

const Vec3 = struct {
  x: f64 = 0.0,
  y: f64,
  z: f64,
};

// Attaching methods to data
const LikeAnObject = struct{
  value: i32,

  fn print(self: *LikeAnObject) void {
    std.debug.print("Value: {}\n", .{self.value});
  }
};

const EnumType = enum{
  EnumOne,
  EnumTwo,
  // EnumThree = 3,
};

const MyError = error{
  GenericError
};

fn foo2(v: i32) !i32 {
  if (v == 42) return MyError.GenericError;
  return v;
}

fn wrap_foo2(v: i32) void {
  if (foo2(v)) |value| {
    std.debug.print("Value: {}\n", .{value});
  } else |err| {
    std.debug.print("Error: {}\n", .{err});
  }
}

pub fn main() void {
  std.debug.print("Hello world!\n", .{});
  
  const x: i32 = 47;
  // x = 42; // error
  // var y: i32 = 42; // error

  var z: i32 = undefined;
  std.debug.print("z: {}\n", .{z});
  var a = x + y;
  std.debug.print("a: {}\n", .{a});

  foo();
  var result = baz();
  std.debug.print("Result: {}\n", .{result});
  // baz(); // error
  _ = baz();

  var v2 = Vec2{.y = 1.0, .x = 2.0};
  std.debug.print("v2: {}\n", .{v2});
  
  // Using default values w/ structs
  var v3: Vec3 = .{.y = 0.1, .z = 0.2};
  // var w: Vec3 = .{.y = 0.1};  // missing field z
  std.debug.print("v3: {}\n", .{v3});

  var obj = LikeAnObject{.value = 47};
  obj.print();

  // Tuple = anonymous struct w/ number fields
  // std.debug.print("{}\n", .{1, 2}) # error: Unused arguments
  
  // Enums
  std.debug.print("One: {}\n", .{EnumType.EnumOne});
  std.debug.print("One: {}\n", .{EnumType.EnumTwo == .EnumTwo});
  // std.debug.print("One: {}\n", .{@enumToInt(EnumType.EnumThree) == 3});

  var array: [3]u32 = [3]u32{47, 47, 47};
  var slice = array[0..2];
  var array2: [3]u32 = [_]u32{47,47,47};
  
  // var invalid = array[4];
  std.debug.print("array[0]: {}\n", .{array[0]});
  std.debug.print("array[0]: {}\n", .{array[0]});
  std.debug.print("Slice Length: {}\n", .{slice.len});
  std.debug.print("Array 2: {}\n", .{array2[0]});
  
  // Control Flows: If, Switch(){}, While, Errors = Enums, can use if to check for errors
  wrap_foo2(42);
  wrap_foo2(47);
}

