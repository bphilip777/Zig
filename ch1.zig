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
  var i: u8 = 2;
  while (i < 100) {
    i *= 2;
  }
  try expect(i == 128);
}

test "while w/ continue expr" {
  var sum: u8 = 0;
  var i: u8 = 1;
  while (i <= 10) : (i += 1) {
    sum += i;
  }
  try expect(sum==55);
}

test "while w/ continue" {
  var sum: u8 = 0;
  var i: u8 = 0;
  while (i <= 3) : (i += 1) {
    if (i==2) continue;
    sum += i;
  }
  try expect(sum == 4);
}

test "while w/ break" {
  var sum: u8 = 0;
  var i: u8 = 0;
  while(i<=3) : (i+=1) {
    if (i == 2) break;
    sum += i;
  }
  try expect(sum == 1);
}

test "for" {
  const string = [_]u8{'a', 'b', 'c'};
  // payload capture
  for(string) |character, index| {
    _ = character;
    _ = index;
  }

  for (string) |character| {
    _ = character;
  }

  for (string) |_, index| {
    _ = index;
  }

  for (string) |_| {}
}

fn addFive(x: u32) u32 {
  return x + 5;
}

test "function" {
  const y = addFive(0);
  try expect(@TypeOf(y) == u32);
  try expect(y == 5);
}

fn fib(n: u16) u16 {
  if (n == 0 or n == 1) return n;
  return fib(n-1) + fib(n-2);
}

test "fn recursion" {
  const x = fib(10);
  try expect(x == 55);
}

test "defer" {
  var x: i16 = 5;
  {
    defer x += 2;
    try expect(x == 5);
  }
  try expect(x == 7);
}

test "multi defer" {
  var x: f32 = 5;
  {
    defer x += 2;
    defer x /= 2;
  }
  try expect(x == 4.5);
}

const FileOpenError = error {
  AccessDenied,
OutOfMemory,
FileNotFound,
};

const AllocationError = error{OutOfMemory};

test "coerce error from a subset to a superset" {
  const err: FileOpenError = AllocationError.OutOfMemory;
  try expect(err == FileOpenError.OutOfMemory);
}

test "error union" {
  const maybe_error: AllocationError!u16 = 10;
  const no_error = maybe_error catch 0;

  try expect(@TypeOf(no_error) == u16);
  try expect(no_error == 10);
}

fn failingFn() error{Oops}!void {
  return error.Oops;
}

test "return an error" {
  failingFn() catch |err| {
    try expect(err == error.Oops);
    return;
  };
}

fn failFn() error{Oops}!i32 {
  try failingFn();
  return 12;
}

test "try" {
  var v = failFn() catch |err| {
    try expect(err == error.Oops);
    return;
  };
  try expect(v == 12);
}

var problems: u32 = 98;

fn failFnCounter() error{Oops}!void {
  errdefer problems += 1;
  try failingFn();
}

test "errdefer" {
  failFnCounter() catch |err| {
    try expect(err == error.Oops);
    try expect(problems == 99);
    return;
  };
}

test "merge error sets" {
  const A = error{NotDir, PathNotFound};
  const B = error{OutOfMemory, PathNotFound};
  const C = A || B;
  _ = C;
}

test "switch states" {
  var x: i8 = 10;
  switch(x) {
    -1...1 => {
      x = -x;
    },
    10, 100 => {
      x = @divExact(x, 10);
    },
    else => {},
  }
    try expect(x == 1);
}

test "switch expr" {
  var x: i8 = 10;
  x = switch(x) {
    -1...1 => -x,
    10, 100 => @divExact(x, 10),
    else => x,
  };
  try expect(x == 1);
}

test "out of bounds" {
  const a = [3]u8{1,2,3};
  // var index: u8 = 5;
  var index: u8 = 2;
  const b = a[index];
  _ = b;
}

test "oob w/ no safety" {
  // Passes - but you failed
  @setRuntimeSafety(false); // Prob improves performance
  const a = [3]u8{1,2,3};
  var index: u8 = 2;
  const b =  a[index];
  _ = b;
}

test "unreachable" {
  // const x: i32 = 1;
  const x: i32 = 2;
  const y: u32 = if (x==2) 5 else unreachable;
  _ = y;
}

fn asciiToUpper(x: u8) u8 {
  return switch(x) {
    'a'...'z' => x + 'A' - 'a',
    'A'...'Z' => x,
    else => unreachable,
  };
}

test "unreachable switch" {
  try expect(asciiToUpper('a') == 'A');
  try expect(asciiToUpper('A') == 'A');
}

fn increment(num: *u8) void {
  num.* += 1;
}

test "ptrs" {
  var x: u8 = 1;
  increment(&x);
  try expect(x == 2);
}

// test "naughty ptrs" {
//   var x: u16 = 0;
//   var y: *u8 = @intToPtr(*u8, x); // fails b/c it causes null
//   _ = y;
// }

test "const ptrs" {
  const x: u8 = 1;
  var y = &x;
  // y.* += 1;
  print("{}", .{y});
}

test "usize" {
  try expect(@sizeOf(usize) == @sizeOf(*u8));
  try expect(@sizeOf(isize) == @sizeOf(*u8));
}

fn total(values: []const u8) usize {
  var sum: usize = 0;
  for (values) |v| sum += v;
  return sum;
}

test "slices" {
  const array = [_]u8{1,2,3,4,5};
  const slice = array[0..3]; // no need for 3 dots
  try expect(total(slice) == 6); 
}

test "slices 2" {
  const array = [_]u8{1,2,3,4,5};
  const slice = array[0..3];
  try expect(@TypeOf(slice) == *const[3]u8);
}

test "slices 3" {
  var array = [_]u8{1,2,3,4,5};
  var slice = array[0..];
  _ = slice;
}

const Direction = enum{north, south, east, west};
const Value = enum(u2) {zero, one, two}; // accepts data

test "enum ordinal value" {
  try expect(@enumToInt(Value.zero) == 0);
  try expect(@enumToInt(Value.one) == 1);
  try expect(@enumToInt(Value.two) == 2);
}

const Value2 = enum(u32) {
  hundred = 100,
  thousand = 1000,
  million = 1_000_000,
  next,
};

test "set enum ordinal value" {
  try expect(@enumToInt(Value2.hundred) == 100);
  try expect(@enumToInt(Value2.thousand) == 1000);
  try expect(@enumToInt(Value2.million) == 1_000_000);
  try expect(@enumToInt(Value2.next) == 1_000_001);
}

// Below does not work
// const diffEnum = enum(u8, u16, u32, u64) {
//   eight,
//   sixteen,
//   thirtytwo,
//   sixtyfour,
// };
//
// test "diffEnums" {
//   try expect(@TypeOf(diffEnum) == u8);
//
// }

const Suit = enum {
  clubs,
  spades,
  diamons,
  hearts,
  pub fn isClubs(self: Suit) bool {
    return self == Suit.clubs;
  }
};

test "enum method" {
  try expect(Suit.spades.isClubs() == Suit.isClubs(.spades)); 
}

const Mode = enum {
  var count: u32 = 0;
  on,
  off,
};

test "hmm" {
  Mode.count += 1;
  try expect(Mode.count == 1);
}

const Vec3 = struct {
  x: f32,
  y: f32,
  z: f32,
};

test "struct usage" {
  const my_vec = Vec3 {
    .x = 0,
    .y = 100,
    .z = 50,
  };
  _ = my_vec;
}

test "missing struct field" {
  const my_vec = Vec3{
    .x = 0,
    .y = 0, // show error when missing field
    .z = 50,
  };
  _ = my_vec;
}

const Vec4 = struct {
  x: f32,
  y: f32,
  z: f32 = 0,
  w: f32 = undefined,
};

test "struct defaults" {
  const my_vec = Vec4{
    .x = 25,
    .y = -50,
  };
  _ = my_vec;
}

const Stuff = struct {
  x: i32,
  y: i32,
  fn swap(self: *Stuff) void {
    const tmp = self.x;
    self.x = self.y;
    self.y = tmp;
  }
};

test "auto def" {
  var thing = Stuff{.x = 10, .y=20};
  thing.swap();
  try expect(thing.x == 20);
  try expect(thing.y == 10);
}

// Allows you to  define types which store one of many possible typed fields - like rust enums?
// can now apply a fn to many different types - but only 1 value is active at a time
// access inactive field = detectable illegal behavior
const Result = union{
  int: i64,
  flat: f64,
  bool: bool,
};

test "simple union" {
  var result = Result{.int=1234};
  // result.float = 12.34;
  result.int = 1234;
}

const Tag = enum{a, b, c};
const Tagged = union(Tag){a:u8, b:f32, c:bool};
test "switch on tagged union" {
  var val = Tagged{.b = 1.5};
  switch (val) {
    .a => |*byte| byte.* += 1,
    .b => |*float| float.* *=2,
    .c => |*b| b.* = !b.*,
  }
  try expect(val.b == 3);
}

const Tagged2 = union(enum) {a: u8, b:f32, c:bool, none};
test "inferred tagged union" {
  var value = Tagged2{.c = true};

  switch (value) {
    .a => |*byte| byte.* += 1,
    .b => |*float| float.* *= 2,
    .c => |*b| b.* = !b.*,
    .none => unreachable,
  }
  try expect(!value.c);
}

test "int rules" {
  const decimal: i32 = 98222;
  const hex: u8 = 0xff;
  const hex2: u8 = 0xFF;
  const octal: u16 = 0o755;
  const bin: u8 = 0b11110000;

  _ = decimal;
  _ = hex;
  _ = hex2;
  _ = octal;
  _ = bin;
}

test "int widening" {
  const a: u8 = 250;
  const b: u16 = a;
  const c: u32 = b;
  const d: u64 = c;
  try expect(d == a);
}

test "int cast" {
  const x: u64 = 200;
  const y = @intCast(u8, x);
  try expect(@TypeOf(y) == u8);
}

test "wrapping operators" {
  var a: u8 = 255;
  var b = a;
  b +%= 1;
  try expect(b == 0);
  // try expect(a == 0);
  var c: u8 = 0;
  c -%= 1;
  try expect(c == 255);
  // also *
  // also + becomes +% while += becomese +%=;
}

test "float widening" {
  const a: f16 = 0;
  const b: f32 = a;
  const c: f64 = b;
  try expect(c == @as(f128, a));
}

test "int-float conv" {
  const a: i32 = 0;
  const b = @intToFloat(f32, a);
  const c = @floatToInt(i32, b);
  try expect(c == a);
}

test "labelled blocks" {
  // Blocks are exprs - there fore enums/structs/unions might be able to store them???
  const count = blk: {
    var sum: u32 = 0;
    var i: u32 = 0;
    while (i<10) : (i+=1) sum += i;
    break :blk sum;
  };
  try expect(count == 45);
  try expect(@TypeOf(count) == u32);
}

test "nested continues" {
  var count: usize = 0;
  outer: for ([_]i32{1,2,3,4,5,6,7,8}) |_| {
    for ([_]i32{1,2,3,4,5}) |_| {
      count += 1;
      continue :outer;
    }
  }
  try expect(count == 8);
}

fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
  var i = begin;
  // no need to store value on break and then return, break will return your value!
  return while(i<end) : (i+=1) {
    if (i == number) {
      break true;
    }
  } else false;
}

// Loops are expressions too! break acceps a value
test "while loop exprs" {
  try expect(rangeHasNumber(0, 10, 3));
}

// either null or type T
test "optional" {
  var found_index: ?usize = null;
  const data = [_]i32{1,2,3,4,5,6,7,8,12};
  for(data) |v, i| {
    if (v==10) found_index = i;
  }
  try expect(found_index == null);
}

test "orelse" {
  var a: ?f32 = null;
  var b = a orelse 0;
  try expect(b == 0);
  try expect(@TypeOf(b) == f32);
}

test "orelse unreachable" {
  const a: ?f32 = 5;
  const b = a orelse unreachable;
  const c = a.?;
  try expect(b == c);
  try expect(@TypeOf(c) == f32);
}

test "payload capture" {
  const a: ?i32 = 5;
  if (a != null) {
    const value = a.?;
    _ = value;
  }
  
  // payload captured version of above
  var b: ?i32 = 5;
  if (b) |*value| {
    value.* += 1;
  }
  try expect(b.? == 6);
}

// Optionals - handles null type and data
// num_left must be outside the fn
var nums_left: u32 = 4;
fn eventuallyNullSequence() ?u32 {
  if (nums_left == 0) return null;
  nums_left -= 1;
  return nums_left;
}

test "while null capture" {

  var sum: u32 = 0;
  while(eventuallyNullSequence()) |value| {
    sum += value;
  }
  try expect(sum == 6);
}

// computed at compile time
test "comptime blocks" {
  var x = comptime fib(10);
  _ = x;

  var y = comptime blk: {
    break :blk fib(10);
  };
  _ = y;
}

test "comptime int" {
  const a = 12;
  const b = a + 10;

  const c: u4 = a;
  _ = c;
  const d: f32 = b;
  _ = d;
}

test "branching on types" {
  const a = 5;
  const b: if(a < 10) f32 else i32 = 5;
  _ = b;
}


fn matrix(
  comptime T: type,
comptime width: comptime_int,
comptime height: comptime_int,
) type {
  return [height][width]T;
}

test "return a type" {
  try expect(matrix(f32, 4, 4) == [4][4]f32);
}

fn addSmallInts(comptime T: type, a: T, b: T) T {
  return switch(@typeInfo(T)) {
    .ComptimeInt => a + b,
    .Int => |info| if (info.bits <= 16)
      a + b
    else
      @compileError("Ints too large"),
    else => @compileError("Only ints accepted"),
  };
}

test "typeinfo switch" {
  const x = addSmallInts(u16, 20, 30);
  try expect(@TypeOf(x) == u16);
  try expect(x == 50);
}

fn GetBiggerInt(comptime T: type) type {
  return @Type(.{
    .Int = .{
      .bits = @typeInfo(T).Int.bits + 1,
      .signedness = @typeInfo(T).Int.signedness,
    },
  });
}

test "@Type" {
  try expect(GetBiggerInt(u8) == u9);
  try expect(GetBiggerInt(i31) == i32);
}

// return struct = generic data struct in zig = use @This 
// std.mem.eql = compares 2 slices 
fn Vec(
comptime count: comptime_int,
comptime T: type,
) type {
  return struct {
    data: [count]T,
  
    const Self = @This();

    fn abs(self: Self) Self {
      var tmp = Self{.data=undefined};
      for (self.data) |elem, i| {
        tmp.data[i] = if (elem < 0)
          -elem
        else 
          elem;
      }
      return tmp;
    }

    fn init(data: [count]T) Self {
      return Self{.data = data};
    }
  };
}

const eql = std.mem.eql;
test "gen vec" {
  const x = Vec(3, f32).init([_]f32{10, -10, 5});
  const y = x.abs();
  try expect(eql(f32, &y.data, &[_]f32{10, 10, 5}));
}

// What's difference b/w anytype and T
fn plusOne(x: anytype) @TypeOf(x) {
  return x + 1;
}

// below does not work w/ T, anytype is its own thing
// type does not work at compile time only run time 
// anytype works at compile time
fn plusTwo(x: anytype) @TypeOf(x) {
  return x + 2;
}

test "inferred fn param" {
  try expect(plusOne(@as(u32, 1)) == 2);
  var x: i32 = 2;
  try expect(plusTwo(x) == 4);
}

// concat arrays quickly = cool stuff
test "++" {
  const x: [4]u8 = undefined;
  const y = x[0..];
  const a: [6]u8 = undefined;
  const b = a[0..];
  const new = y ++ b;
  try expect(new.len == 10);
}

test "**" {
  const pattern = [_]u8{0xCC, 0xAA};
  const memory = pattern ** 3;
  try expect(eql(
    u8,
    &memory,
    &[_]u8{0xCC, 0xAA, 0xCC, 0xAA, 0xCC, 0xAA}
  ));
}

test "opt ifs" {
  var maybe_num: ?usize = 10;
  if (maybe_num) |n| {
    try expect(@TypeOf(n) == usize);
    try expect(n == 10);
  } else {
    unreachable;
  }
}

test "error union if" {
  var ent_num: error{UnknownEntity}!u32 = 5;
  if (ent_num) |entity| {
    try expect(@TypeOf(entity) == u32);
    try expect(entity == 5);
  } else |err| {
    _ = err catch {};
    unreachable;
  }
}

test "while opt" {
  var i: ?u32 = 10;
  while(i) |num| : (i.? -= 1) {
    try expect(@TypeOf(num) == u32);
    if (num == 1) {
      i = null;
      break;
    }
  }
  try expect(i == null);
}

var numbers_left2: u32 = undefined;
fn eventuallyErrorSequence() !u32 {
  return if (numbers_left2 == 0) error.ReachedZero else blk: {
    numbers_left2 -= 1;
    break :blk numbers_left2;
  };
}

test "while error union capture" {
  var sum: u32 = 0;
  numbers_left2 = 3;
  while (eventuallyErrorSequence()) |value| {
    sum += value;
  } else |err| {
    try expect(err == error.ReachedZero);
  }
}

test "for capture" {
  const x = [_]i8{1,5,120, -5};
  for (x) |v| try expect(@TypeOf(v) == i8);
}

// switch cases on tagged unions 
const Info = union(enum) {
  a: u32,
  b: []const u8,
  c,
  d: u32,
};

test "switch capture" {
  var b = Info{.a=10};
  const x = switch(b) {
    .b => |str| blk: {
      try expect(@TypeOf(str) == []const u8);
      break :blk 1;
    },
    .c => 2,
    .a, .d => |num| blk: { // can have multiple matches on same line if separated by ,
      try expect(@TypeOf(num) == u32);
      break :blk num*2;
    },
  };
  try expect(x == 20);
}

test "for w/ ptr capture" {
  var data = [_]u8{1,2,3};
  for (data) |*byte| byte.* +=1;
  try expect(eql(u8, &data, &[_]u8{2,3,4}));
}

// Inline
test "inline for" {
  const types = [_]type{i32, f32, u8, bool};
  var sum: usize = 0;
  inline for (types) |T| sum += @sizeOf(T);
  try expect(sum == 10);
}

// maintain type safety for pts whose types we don't yet know about
// const Window = opaque{};
// const Button = opaque{};
//
// extern fn show_window(*Window) callconv(.C) void;
//
// test "opaque" {
//   var main_window: *Window = undefined;
//   show_window(main_window);
//   
//   // Bleow will fail
//   // var ok_btn: *Button = undefined;
//   // show_window(ok_btn);
// }

// const Window2 = opaque {
//   fn show(self: *Window2) void {
//     show_window2(self);
//   }
// };
//
// extern fn show_window2(*Window2) callconv(.C) void;
//
// test "opaque with declarations" {
//   var main_window: *Window2 = undefined;
//   main_window.show();
// }

// can coerce to other struct types
test "anonymous struct literal" {
  // Is this the anonymous part?
  const Point = struct{x:i32, y:i32};
  var pt: Point = .{
    .x = 13,
    .y = 64,
  };
  try expect(pt.x == 13);
  try expect(pt.y == 64);
}

// never coerced to another type
test "fully anonymous struct" {
  try dump(.{
    .int = @as(u32, 1234),
    .float = @as(f64, 12.34),
    .b = true,
    .s = "hi",
  });
}

fn dump(args: anytype) !void {
  try expect(args.int == 1234);
  try expect(args.float == 12.34);
  try expect(args.b);
  try expect(args.s[0] == 'h');
  try expect(args.s[1] == 'i');
}

// anonymous struct w/o field names = tuples
test "tuple" {
  const values = .{
    @as(u32, 1234),
    @as(f64, 12.34),
    true,
    "hi",
  } ++ .{false} ** 2;
  try expect(values[0] == 1234);
  try expect(values[4] == false);
  inline for(values) |v,i| {
    if (i!=2) continue;
    try expect(v);
  }
  try expect(values.len == 6);
  try expect(values.@"3"[0] == 'h'); // what is going on here?
  // @"" acts as excape, anything inside is an identifier
}

test "sentinel termination" {
  const terminated = [3:0]u8{3,2,1};
  try expect(terminated.len == 3);
  // try expect(@bitCast([4]u8, terminated)[3] == 0); // idk why this fails
}

test "string literal" {
  try expect(@TypeOf("hello") == *const [5:0]u8);
}

test "C String" {
  const c_string: [*:0]const u8 = "hello";
  var array: [5]u8 = undefined;

  var i: usize = 0;
  while(c_string[i] != 0) : (i+=1) {
    array[i] = c_string[i];
  }
}

// sentinel termination types coerce to non-sentinal counterparts
test "coercion" {
  var a: [*:0]u8 = undefined;
  const b: [*]u8 = a;
  _ = b;

  var c: [5:0]u8 = undefined;
  const d: [5]u8 = c;
  _ = d;

  var e: [:10]f32 = undefined;
  const f = e;
  _ = f;
}

test "sentinel terminated slicing" {
  var x = [_:0]u8{255} ** 3;
  const y = x[0..3:0];
  _ = y;
}

// Vectors for SIMD
const meta = std.meta;
const Vector = meta.Vector;

test "vector add" {
  const x: Vector(4, f32) = .{1,-10,20,-1};
  const y: Vector(4, f32) = .{2, 10, 0, 1};
  const z = x + y;
  try expect(meta.eql(z, Vector(4, f32){3, 0, 20, 0}));
}

test "vector indexing" {
  const x: Vector(4, u8) = .{255, 0, 255, 0};
  try expect(x[0] == 255);
}

test "vector * scalar" {
  const x: Vector(3, f32) = .{12.5, 37.5, 2.5};
  const y = x * @splat(3, @as(f32, 2)); // used to create a vector of same values
  try expect(meta.eql(y, Vector(3, f32){25, 75, 5}));
}

const mlen = std.mem.len;

test "vector looping" {
  const x = Vector(4, u8){255, 0, 255, 0};
  var sum = blk: {
    var tmp: u10 = 0;
    var i: u8 = 0;
    while (i<mlen(x)) : (i+=1) tmp += x[i];
    break :blk tmp;
  };
  try expect(sum == 510);
}

test "vector coercion" {
  const arr: [4]f32 = @Vector(4, f32){1,2,3,4};
  try expect(@TypeOf(arr[0]) == f32);
}

// @import = takes file - creates struct - declarated labeleed pub end up in struct for use 
// std is special case, rest are file path 
