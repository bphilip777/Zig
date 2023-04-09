const std = @import("std");
const expect = @import("std").testing.expect; // works like assert in other langauges?

test "basic vars" {
  const c: u32 = 5;
  var variable: u32 = 5000;
  _ = c;
  _ = variable;
}

const inferred_constant = @as(i32, 5);
var inferred_variable = @as(u32, 5000);

test "basic undefineds " {
  const a: i32 = undefined;
  const b: u32 = undefined;
  _ = a;
  _ = b;
}

// Difference b/w '' & "" - '' = u8, "" = *const [1:0]u8
test "basic arrays " {
  const a  = [5]u8{'h', 'e', 'l', 'l', 'o'};
  const b = [_]u8{'w', 'o', 'r', 'l', 'd'};
  const length = a.len;
  _ = b;
  _ = length;
}

test "if states" {
  const a3 = true;
  var x: u16 = 0;
  if (a3) {
    x += 1;
  } else {
    x += 12;
  }
  try expect(x == 1);
}

test "while" {
  var i: u8 = 2;
  while(i < 100) {
    i*=2;
  }
  try expect(i == 128);
}

test "while w/ expr" {
  var sum: u8 = 0;
  var i: u8 = 1;
  while(i <= 10) : (i += 1) {
    sum += i;
  }
  try expect(sum == 55);
}

test "while w/ break" {
  var sum: u8 = 0;
  var i: u8 = 0;
  while (i<=3) : (i+=1) {
    if (i == 2) break;
    sum += i;
  }
  try expect(sum == 1);
}

test "for" {
  const string = [_]u8{'a', 'b', 'c'};
  for (string) |character, index| {
    _ = character;
    _ = index;
  }

  for (string) |character| {
    _ = character;
  }

  for (string) |_| {}
}

// variables = snake_case
// functions = camelCase

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

test "fib func" {
  const x = fib(10);
  try expect(x == 55);
}

test "defer" {
  var x:i16 = 5;
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

test "coerce error from subset to superset" {
  const err: FileOpenError = AllocationError.OutOfMemory;
  try expect(err == FileOpenError.OutOfMemory);
}

test "Error Union" {
  const maybe_error: AllocationError!u16 = 10;
  const no_error = maybe_error catch 0;

  try expect(@TypeOf(no_error) == u16);
  try expect(no_error == 10);
}

fn failingFunction() error{Oops}!void {
  return error.Oops;
}

test "return error" {
  failingFunction() catch |err| {
    try expect(err == error.Oops);
    return;
  };
}

fn failFn() error{Oops}!i32 {
  try failingFunction();
  return 12;
}
// try x == x catch |err| return err;
test "try above" {
  var v = failFn() catch |err| {
    try expect(err == error.Oops);
    return;
  };
  try expect(v==12);
}

// // Errdefer = defer but returns error from inside it's block 
// var problems: u32 = 98;
// fn failFnCounter() error{Oops}!void {
//   errdefer problems += 1;
//   try failingFunction();
// }
//
// // Tests defer error
// test "errdefer" {
//   failingFunction() catch |err| {
//     try expect(err == error.Oops);
//     try expect(problems == 99);
//     return;
//   };
// }

fn createFile() !void {
  return error.AccessDenied;
}

test "inferred error set" {
  const x: error{AccessDenied}!void = createFile();
  _ = x catch {};
}

const A = error{NotDir, PathNotFound};
const B = error{OutOfMemory, PathNotFound};
const C = A || B; // || does not work how I thought it did

// In zig ... is loop, in Rust it's ..=
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
  try expect(x==1);
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

// test "out of bounds" {
//   const a4 = [3]u8{1,2,3};
//   var index: u8 = 5;
//   const b4 = a4[index];
//   _ = b4; // how to get rid of error unused local variable
// }

test "oob no safety" {
  @setRuntimeSafety(false);
  const a5 = [3]u8{1,2,3};
  var index2: u8 = 5;
  const b5 = a5[index2];
  _ = b5;
}

// Assert to compiler that statement won't be reached to improve optimizations
// If you reach that code - throws error to crash program
// test "unreachable" {
//     const x: i32 = 1;
//     const y: u32 = if (x == 2) 5 else unreachable;
//     _ = y;
// }

// Unreachable in switch statement
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

// Pts - not allowed tobe 0 or null, *T = ptr, reference = &T, dereference = T.*
fn increment(num: *u8) void {
  num.* += 1;
}

test "pointers" {
  var x_ptr: u8 = 1;
  increment(&x_ptr);
  try expect(x_ptr == 2);
}

// setting ptr to 0 = detectable illegal behavior - this will be a fuckin pain
// test "naughty ptr" {
//   var x: u16 = 0;
//   var y: *u8 = @intToPtr(*u8, x);
//   _ = y;
// }

// Illegal behavior to change value of a constant ptr
// test "const ptrs" {
//   const x: u8 = 1;
//   var y = &x;
//   y.* += 1;
// }

// Ptrs == sized integers, 1 byte
test "usize" {
  try expect(@sizeOf(usize) == @sizeOf(*u8));
  try expect(@sizeOf(isize) == @sizeOf(*u8));
}

// Slices = [*]T + usize, syntax = []T, good for arbitrary amounts of data 
// x[n..m] = slice from an array = slicing 
fn total(values: []const u8) usize {
  var sum: usize = 0;
  for(values) |v| sum += v;
  return sum;
}

test "slices" {
  const array = [_] u8{1,2,3,4,5,6};
  const slice = array[0..3]; // creates a slice of a certain size at compile time
  try expect(total(slice) == 6);
}

test "slices 2" {
  const array = [_]u8{1,2,3,4,5};
  const slice = array[0..3]; // can do 3.. to go to end, cannot do same to start from beginning
  try expect(@TypeOf(slice) == *const [3]u8);
}

test "slices 3" {
  var array = [_]u8{1,2,3,4,5};
  var slice = array[0..];
  _ = slice;
}

// Enums 
const Direction = enum { north, south, east, west};
const Value = enum(u2) {zero, one, two};

test "enum ordinal value" {
  try expect(@enumToInt(Value.zero) == 0);
  try expect(@enumToInt(Value.one) == 1);
  try expect(@enumToInt(Value.two) == 2);
}

const Value2 = enum(u32) {
  hundred = 100,
  thousand = 1000,
  million = 1_000_000, // this works!!!! that's great!
  next,
};

test "set enum ordinal value" {
  try expect(@enumToInt(Value2.hundred) == 100);
  try expect(@enumToInt(Value2.thousand) == 1000);
  try expect(@enumToInt(Value2.million) == 1_000_000);
  try expect(@enumToInt(Value2.next) == 1_000_001);
}

const Suit = enum {
  clubs,
  spades,
  diamons,
  hearts,
  pub fn isClubs(self: Suit) bool {
    return self == Suit.clubs;
  }
};

// Wtf is this syntax??!
test "enum method" {
  try expect(Suit.spades.isClubs() == Suit.isClubs(.spades));
}

// Namespaced globals whose values are unrelated + unattached to instances of enum type
const Mode = enum {
  var count: u32 = 0;
  on,
  off,
};

test "hmm" {
  Mode.count += 1;
  try expect(Mode.count == 1);
}

const Vec3 = struct{
  x: f32, y: f32, z:f32
};

test "struct usage" {
  const my_vector = Vec3{
    .x = 0, .y=100, .z=50,
  };
  _ = my_vector;
}

// All fields must have a value 
// test "missing struct field" {
//   const my_vector = Vec3 {
//     .x = 0,
//     .z = 50,
//   };
//   _ = my_vector;
// }

// Default values
const Vec4 = struct {
  x: f32, y: f32, z: f32=0.0, w: f32=undefined
};

// must have alldefaults defined at initialization
test "struct defaults" {
  const my_vector = Vec4 {
    .x = 25,
    .y = -50,
  };
  _ = my_vector;
}

const Stuff = struct {
  x: i32,
  y: i32,
  // explicitly adds fn to this struct
  fn swap(self: *Stuff) void {
    const tmp = self.x;
    self.x = self.y;
    self.y = tmp;
  }
};

test "auto deref" {
  var thing = Stuff{.x=10, .y=20};
  thing.swap(); // accesses the contents of struct thing without having to specify
  try expect(thing.x == 20);
  try expect(thing.y == 10);
}

// Unions: Only 1 field active at a time, how do you know which? 
// const Result = union {
//   int: i64,
//   float: f64,
//   bool: bool,
// };
//
// test "simple union" {
//   var result = Result{.int=1234};
//   result.float = 12.32;
// }

// Tagged enums: detect active field - payload capture - switch on tag type + capture its value 
// ptr acpture = values immutable, |*value| = capture ptr = allowing deref to mutate its original value 
// const Tag = enum{a,b,c};
// const Tagged = union(Tag) {a: u8, b: f32, c:bool };
const Tagged = union(enum) {a:u8, b:f32, c:bool}; // Equivalent to above

test "switch on tagged union" {
  var value = Tagged{.b = 1.5}; // union defined as f32
  // Zig will test each statement in swtich to see if it works - that's good
  switch (value) {
    .a => |*byte| byte.* += 1,
    .b => |*float| float.* *= 2,
    .c => |*b| b.* = !b.*,    
  }
  try expect(value.b == 3);
}

// void member = have types omitted - below is a none of type void
const Tagged2 = union(enum) {a: u8, b: f32, c:bool, none };

// Integer Rules: supports hex, octal, binary integer literals
// Also supports _ as visual separator - must match type though 

// Integer widening allowed 
test "integer widening" {
  const a: u8 = 250;
  const b: u16 = a;
  const c: u32 = b;
  try expect(c == a);
}

test "@intCast" {
  const x: u64 = 200;
  const y = @intCast(u8, x);
  try expect(@TypeOf(y) == u8);
}

test "well defined overflow" {
  var a: u8 = 255;
  a +%= 1;
  try expect(a == 0);
}

// Floats
// Strictly IEEE compliant unless @setFloatMode(.Optimized) = --ffast-math under gcc 
test "float widening" {
  const a: f16 = 0;
  const b: f32 = a;
  const c: f64 = b;
  try expect(c == @as(f128, a));
}

test "int-float conversion" {
  const a: i32 = 0;
  const b = @intToFloat(f32, a);
  const c = @floatToInt(i32, b);
  try expect(c == a);
}

// blocks = expr w/ labels = yield values 
// label called blk, syntax is name:
// blks yield values, can be used in place of a value 
// empty blk {} has a value of void 
test "labelled blocks" {
  const count = blk: {
    var sum: u32 = 0;
    var i: u32 = 0;
    while(i<10) : (i+=1) sum += i;
    break :blk sum;
  };
  try expect(count == 45);
  try expect(@TypeOf(count) == u32);
}

// below is equivalent to C's i++
test "blocks 2" {
  const count = blk: {
    var i: u32 = 0;
    const tmp = i;
    i += 1;
    break :blk tmp; // tmp is the return value - defined by :bllk
  };
  try expect(count == 0);
}

// Can give loops labels allowing easier breaks + continues - actually dope
test "neseted continues" {
  var count: usize = 0;
  outer: for ([_]i32{1,2,3,4,5,6,7,8}) |_| {
    for ([_]i32{1,2,3,4,5}) |_| {
      count += 1;
      continue :outer; // moves outer forward
    }
  }
}

// break acceps a value + else states on while loops not like in rust - might be able to get crazy performance like Rust
fn rangeHasNumber(begin:usize, end:usize, number:usize) bool {
  var i = begin;
  return while (i<end) : (i+=1) {
    if (i==number) {
      break true;
    }
  }
  else false;
}

test "while loop expr" {
  try expect(rangeHasNumber(0, 10, 3));
}

// Optionals - syntax ?T, store null data or T
// orelse acts when option is null - kind of like match in rust but weaker
test "orelse" {
  var a: ?f32 = null;
  var b = a orelse 0;
  try expect(b == 0);
  try expect(@TypeOf(b) == f32);
}

// .? = shorthand for orelse unreachable
test "orelse unreachable" {
  const a5: ?f32 = 5;
  const b5 = a5 orelse unreachable;
  const c5 = a5.?;
  try expect(b5 == c5);
  try expect(@TypeOf(c5) == f32);
}

// Payload capture on unreachable
test "if optional payload capture" {
  const a: ?i32 = 5; // optional
  if (a != null) {
    const value = a.?; // a.? = a orelse 0
    _ = value;
  }
  
  // Below is super interesting - b optional gives 5 - not a ptr, can get a deref and add to the value
  var b: ?i32 = 5;
  if (b) |*value| {
    value.* += 1;
  }
  try expect(b.? == 6);
}

// Does not  destroy the sequence
var numbers_left: u32 = 4;
fn eventuallyNullSequence() ?u32 {
  if(numbers_left == 0) return null;
  numbers_left -= 1;
  return numbers_left;
}

test "while null capture" {
  var sum: u32 = 0;
  while(eventuallyNullSequence()) |value| {
    sum += value;
  }
  try expect(sum == 6);
}

// Optional ptrs + slices do not take extra memory compared to  non-optional ones 
// internally they have 0 value of ptr for null 
// null ptrs must be unwrapped to non-optional before deref - stops accidental null ptr derefs

// Forcibly execute at compile time
test "comptime blocks" {
  var x = comptime fib(10);
  _ = x;

  var y = comptime blk: {
    break :blk fib(10);
  };
  _ = y;
}

// Int literals are of type comptime_int = no size, arbitrary precision, coerce to any int that can hold them, coerce to floats, char literals are of same type
test "comptime_int" {
  const a = 12;
  const b = a + 10;

  const c: u4 = a;
  _ = c;
  const d: f32 = b;
  _ = d;
}

// comptime_float = f128, cannot become integers 
test "branching on types" {
  const a = 5;
  const b: if (a < 10) f32 else i32 = 5;
  _ = b;
}

// Gets generic type, width + height, returns a matrix? That's so simple and good
fn Matrix(
  comptime T: type,
  comptime width: comptime_int,
  comptime height: comptime_int,
) type {
  return [height][width]T;
}

test "returning a type" {
  try expect(Matrix(f32, 4, 4) == [4][4]f32);
}

// has generic type
fn addSmallInts(comptime T: type, a: T, b: T) T {
  return switch (@typeInfo(T)) {
    .ComptimeInt => a + b,
    .Int => |info| if (info.bits <= 16)
      a + b
    else
      @compileError("ints too large"),
    else => @compileError("only ints accepted"),
  };
}

test "typeinfo search" {
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

// To return a struct use @This
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

    // initialize struct
    fn init(data: [count]T) Self {
      return Self{.data=data};
    }
  };
}

const eql = @import("std").mem.eql;

test "generic vector" {
  const x = Vec(3, f32).init([_]f32{10, -10, 5});
  const y = x.abs();
  try expect(eql(f32, &y.data, &[_]f32{10,10,5}));
}

fn plusOne(x: anytype) @TypeOf(x) {
  return x + 1;
}

test "inferred function param" {
  try expect(plusOne(@as(u32, 1)) == 2);
}

test "++" {
  const x: [4]u8 = undefined;
  const y = x[0..];

  const a: [6]u8 = undefined;
  const b = a[0..];

  const new = y ++ b; // repeats y b - only at comptime
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

// Below is a series of payload captures
test "optional-if" {
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

test "while optional" {
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
  while(eventuallyErrorSequence()) |value| {
    sum += value;
  } else |err| {
    try expect(err == error.ReachedZero);
  }
}

test "for capture" {
  const x = [_]i8{1,5,120,-5};
  for (x) |v| try expect(@TypeOf(v) == i8);
}

const Info = union(enum) {
  a: u32,
  b: []const u8,
  c,
  d: u32,
};

test "switch capture" {
  var b = Info{.a = 10};
  const x = switch (b) {
    .b => |str| blk: {
      try expect(@TypeOf(str) == []const u8);
      break :blk 1;
    },
    .c => 2,
    .a, .d => |num| blk: {
      try expect(@TypeOf(num) == u32);
      break :blk num * 2;
    },
  };
  try expect(x == 20);
}

test "for w/ ptr capture" {
  var data = [_]u8{1,2,3};
  for (data) |*byte| byte.* += 1;
  try expect(eql(u8, &data, &[_]u8{2,3,4}));
}

// Inline loops are unrolled (speed boost) - while works similarly
test "inline for" {
  const types = [_]type{i32, f32, u8, bool};
  var sum: usize = 0;
  inline for (types) |T| sum += @sizeOf(T);
  try expect(sum == 10);
}



pub fn main() !void {
  std.debug.print("Hello, {s}!\n", .{"World"});
}
