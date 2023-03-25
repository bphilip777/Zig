const std = @import("std");

const constant: i32 = 5;
var variable: u32 = 500;

const inferred_constant = @as(i32, 5);
var inferred_variable = @as(u32, 5000);

// Undefined can be coerced to any value
const a: i32 = undefined;
var b: u32 = undefined;

// Arrays
const c = [5]u8{'h','e','l','l','o'};
const d = [_]u8{'w','o','r','l','d'};

const array = [_]u8{'h','e','l','l','o'};
const length = array.len;

const expect = @import("std").testing.expect;

test "If statement" {
  const f = true;
  var x: u16 = 0;
  if (f) {
    x += 1;
  } else {
    x += 2;
  }
  try expect(x == 1);
}

test "if statement expression" {
  const e = true;
  var x: u16 = 0;
  x += if (e) 1 else 2;
  try expect(x == 1);
}

test "while" {
  var i: u8 = 2;
  while(i < 100) {
    i *= 2;
  }
  try expect(i == 128);
}

test "while with continue expression" {
  var sum: u8 = 0;
  var i: u8 = 1;
  while (i <= 10) : (i += 1) {
    sum += i;
  }
  try expect(sum == 55);
}

test "while with continue" {
  var sum: u8 = 0;
  var i: u8 = 0;
  while(i <= 3) : (i += 1) {
    if (i == 2) continue;
    sum += i;
  }
  try expect(sum == 4);
}

test "while with break" {
  var sum: u8 = 0;
  var i: u8 = 0;
  while(i <= 3) : (i+=1) {
    if (i == 2)  break;
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

  for (string) |_, index| {
    _ = index;
  }

  for (string) |_| {}
}

// Fn = Immutable + camelCase
// Variables = snake_case
fn addFive(x: u32) u32 {
  return x + 5;
}


test "function" {
  const y = addFive(0);
  try expect(@TypeOf(y) == u32);
  try expect(y == 5);
}

// Fns can be recursive
fn fibonacci(n: u16) u16 {
  if (n==0 or n==1) return n;
  return fibonacci(n-1) + fibonacci(n-2);
}

test "Recursive functions" {
  const x = fibonacci(10);
  try expect(x == 55);
}

test "Ignoring variables" {
  _ = 10; // only allowed in local not global scope
}

// Defer = execute statements when exiting current block - reverse order of defers = order of executions
test "Defer" {
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

// Error = enums
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

// Error unions
test "Error unions" {
  const maybe_error: AllocationError!u16 = 10;
  const no_error = maybe_error catch 0;

  try expect(@TypeOf(no_error) == u16);
  try expect(no_error == 10);
}

fn failingFunction() error{Oops}!void {
  return error.Oops;
}

test "returning an error" {
  failingFunction() catch |err| {
    try expect(err == error.Oops);
    return;
  };
}

fn failFn() error{Oops}!i32 {
  try failingFunction();
  return 12;
}

test "Try" {
  var v = failFn() catch |err| {
    try expect(err == error.Oops);
    return;
  };
  try expect(v == 12); // never reached
}



// errdefer
var problems: u32 = 98;
fn failFnCounter() error{Oops}!void {
  errdefer problems += 1;
  try failingFunction();
}

test "ErrDefer" {
  failFnCounter() catch |err| {
    try expect(err == error.Oops);
    try expect(problems == 99);
    return;
  };
}

pub fn main() void {
  std.debug.print("Hello, {s}!\n", .{"World"});
}
