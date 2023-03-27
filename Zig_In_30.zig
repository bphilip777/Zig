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
  GenericError,
  OtherError,
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

pub fn printer(value: *i32) void {
  std.debug.print("Pointer: {}\n", .{value});
  std.debug.print("Value: {}\n", .{value.*});
}

const MyStruct = struct {
value: i32
};

pub fn printer2(s: *MyStruct) void {
  std.debug.print("Value: {}\n", .{s.value});
}

fn nullChoice(value: ?*i32) void {
  if (value) |v| {
    std.debug.print("Value: {}\n", .{v.*});
  } else {
    std.debug.print("Null!\n", .{});
  }
}

fn meta(x: anytype) @TypeOf(x) {
  if (@TypeOf(x) == i64) {
    return x + 2;
  } else {
    return 2 * x;
  }
}

// Generics
fn Vec2Of(comptime T: type) type {
  return struct {
    x: T,
    y: T,
  };
}

const V2i64 = Vec2Of(i64);
const V2f64 = Vec2Of(f64);

// Factory type
const Gpa = std.heap.GeneralPurposeAllocator(.{});


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

  // Pointers
  var val: i32 = 47;
  printer(&val);
  // Ptrs must be aligned correctly w/ value it's pointing to
  var mys = MyStruct{.value = 47};
  printer2(&mys);

  // Any value is nullable - unions of base type + null, unwrap w/ .?
  var v4: i32 = 49;
  var vptr: ?*i32 = &v4;
  // var throwaway1: ?*i32 = null;
  // var throwaway2: *i32 = null; // error: expectedd type i32, found null

  // std.debug.print("Value: {}\n", .{vptr.*}); // Error: Attempt to deref non-ptr type
  std.debug.print("Value: {}\n", .{vptr.?.*});

  // Use ptrs from C ABI fn - auto converted to null, use if to unwrap
  var v5: i32 = 48;
  var vptr2: ?*i32 = &v5;
  var vptr3: ?*i32 = null;
  nullChoice(vptr2);
  nullChoice(vptr3);

  // Meta-programming
  // Types = compile-time 
  // Runtime code will work at compile time 
  // Struct field evaluation is duck-typed = if it has all props of duck, then it's a duck, type of structure typing
  // Static Type: Variable has types, values have types, variables cannot change type
  // Dynamic Typing: Variables have no type, values have types, variables change type dynamically
  var xx: i64 = 48;
  var yy: i32 = 47;
  std.debug.print("I64-foo: {}\n", .{meta(xx)});
  std.debug.print("I32-foo: {}\n", .{meta(yy)});

  // Generics
  var vi = V2i64{.x=47, .y=47};
  var vf = V2f64{.x=48.0, .y=48.0};
  std.debug.print("I64 vec: {}\n", .{vi});
  std.debug.print("F64 vec: {}\n", .{vf});


  // Heap
  // create allocator factory struct -> std.mem.Allocator -> use alloc/free + create/destroy -> deinit Allocator factory
  var gpaH = Gpa{};
  var gallocH = &gpaH.allocator;
  defer _ = gpaH.deinit();
  var sliceH = try gallocH.alloc(i32, 2);
  var singleH = try gallocH.create(i32);
  sliceH[0] = 47;
  sliceH[1] = 48;
  singleH.* = 49;

  std.debug.print("Slice: [{}, {}]\n", .{sliceH[0], sliceH[1]});
  std.debug.print("Single: {}\n", .{singleH.*});
}
