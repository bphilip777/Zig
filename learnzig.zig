const std = @import("std");
const expect = @import("std").testing.expect; // works like assert in other langauges?

const c: u32 = 5;
var variable: u32 = 5000;

const inferred_constant = @as(i32, 5);
var inferred_variable = @as(u32, 5000);

const a: i32 = undefined;
const b: u32 = undefined;

const a1  = [5]u8{"h", "e", "l", "l","o"};
const b2 = [_]u8{"w", "o", "r", "l", "d"};
const length = a1.len;

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

// Errdefer = defer but returns error from inside it's block 
var problems: u32 = 98;
fn failFnCounter() error{Oops}!void {
  errdefer problems += 1;
  try failingFunction();
}

test "errdefer" {
  failingFunction() catch |err| {
    try expect(err == error.Oops);
    try expect(problems == 99);
    return;
  };
}

pub fn main() !void {
  std.debug.print("Hello, {s}!\n", .{"World"});
}
