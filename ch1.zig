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


