const std = @import("std");

fn multiples_of_n(limit: i32, n: i32) i32 {
  var val: i32 = 0;
  var sum: i32 = 0;
  while (val < limit) : (val += n) {
    sum += val;
  }
  return sum;
}

fn sum_even_fibs(limit: i32) i32 {
  var one: i32 = 1;
  var two: i32 = 2;
  var ans: i32 = 0;
  while(two < limit) {
    var temp: i32 = two;
    two += one;
    one = temp;
    if (@mod(one, 2) == 0) {
      ans += one;
    }
  }
  return ans;
}

fn sieve_erastothenes(limit: u32) i32 {
  // Initialize a boolean array - seems to not work?
  var sieve = [limit]true;
  // Start w/ first prime
  var i: u32 = 2;
  // Set array to false
  while (i <= limit) : (i += 1) {
    if (sieve[i]) {
      var j: u32 = i * i;
      while (j <= limit) : (j += i) {
        sieve[j] = false;
      }
    }
  }
  // Count the number of trues
  var nPrimes: i32 = 0;
  i = 2;  
  while(i <= limit) : (i += 1) {
    nPrimes += @intCast(i32, @boolToInt(sieve[i]));
  }
  return nPrimes;
}

pub fn main() void {
  const limit: i32 = 1000;
  var m3: i32 = multiples_of_n(limit, 3);
  var m5: i32 = multiples_of_n(limit, 5);
  var m15: i32 = multiples_of_n(limit, 15);
  std.debug.print("Ans:{}\n", .{m3+m5-m15});
  
  var evenFibs: i32 = sum_even_fibs(4_000_000);
  std.debug.print("Ans:{}\n", .{evenFibs});
  
  var sieveOfEra: i32 = sieve_erastothenes(10);
  std.debug.print("Ans:{}\n", .{sieveOfEra});
}
