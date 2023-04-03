const std = @import("std");
const rng = std.rand.DefaultPrng;

pub fn main() !void {
  var rnd = rng.init(0);
  var secret_number = @mod(rnd.random().int(i32), 100);
  std.debug.print("Secret number is {}", .{secret_number});
  var input: i32 = -1;
  while(true) {
    std.debug.print("\nGuess the secret number b/w 0 and 100.", .{});
    input = try ask_user(i32);
    if (input == secret_number) {
      std.debug.print("You guessed correct!!!", .{});
      break;
    } else {
      std.debug.print("Wrong... for now. Try Again!", .{});
    }
  }
}

// We can read any arbitrary number type with number_type
// can swap i32 for type below
fn ask_user(comptime number_type: type) !number_type {
    const stdin = std.io.getStdIn().reader();

    // Adjust the buffer size depending on what length the input
    // will be or use "readUntilDelimiterOrEofAlloc"
    var buffer: [10]u8 = undefined;
    
    std.debug.print("\nGuess number b/w 0 and 100: ", .{});
    
    // Read until the '\n' char and capture the value if there's no error
    if (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |value| {
        // We trim the line's contents to remove any trailing '\r' chars 
        const user_input = std.mem.trimRight(u8, value[0..value.len - 1], "\r");
        return try std.fmt.parseInt(number_type, user_input, 10);
    } else {
        return @as(number_type, -1);
    }
}
