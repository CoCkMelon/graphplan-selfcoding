const std = @import("std");

// Define a function to encode an 8x8 bool matrix into u64
pub fn encode(matrix: [8][8]bool) u64 {
    // Create a u64 variable and initialize it to 0
    var encoded: u64 = 0;

    // Loop through the matrix row by row
    for (matrix, 0..) |row, i| {
        // Loop through the row column by column
        for (row, 0..) |cell, j| {
            // If the cell is true, set the corresponding bit in the encoded variable to 1 using bitwise OR and left shift operations
            if (cell) {
//encoded |= 1 << (i * 8 + j);
                encoded |= @as(u64, 1) << @intCast(u6, i * 8 + j);
            }
        }
    }

    // Return the encoded variable
    return encoded;
}

// Define a function to decode a u64 into an 8x8 bool matrix
pub fn decode(encoded: u64) [8][8]bool {
    // Create an 8x8 bool matrix and initialize it to false
    var matrix: [8][8]bool = undefined;
    for (matrix) |*row| {
        row.* = [_]bool{false} ** 8;
    }

    // Loop through the bits in the encoded variable from right to left
    var i: usize = 0;
    while (i < 64) : (i += 1) {
        // Get the corresponding row and column indices in the matrix using integer division and modulo operations
        const row = i / 8;
        const col = i % 8;

        // Get the bit value using bitwise AND and right shift operations
        //const bit = (encoded >> i) & 1;
        const bit = (encoded >> @intCast(u6, i)) & 1;

        // If the bit is 1, set the corresponding element in the matrix to true
        if (bit == 1) {
            matrix[row][col] = true;
        }
    }

    // Return the matrix
    return matrix;
}

pub fn main() !void {
    // Create an 8x8 bool matrix
    var matrix: [8][8]bool = undefined;
    for (matrix) |*row| {
        row.* = [_]bool{false} ** 8;
    }

    // Set some elements to true
    matrix[0][1] = true;
    matrix[1][2] = true;
    matrix[2][3] = true;
    matrix[3][4] = true;
    matrix[3][0] = true;
    matrix[4][5] = true;
    matrix[5][6] = true;
    matrix[6][7] = true;
    matrix[7][4] = true;
    matrix[4][2] = true;
    matrix[3][7] = true;
    matrix[1][7] = true;
    matrix[5][7] = true;
    matrix[7][7] = true;

    // Print the matrix
    std.debug.print("Matrix:\n", .{});
    for (matrix) |row| {
        for (row) |cell| {
            std.debug.print("{} ", .{@bitCast(u1,cell)});
        }
        std.debug.print("\n", .{});
    }

    // Encode the matrix into u64
    const encoded = encode(matrix);

    // Print the encoded value in binary format
    std.debug.print("Encoded: {b}\n", .{encoded});

    // Decode the u64 into an 8x8 bool matrix
    const decoded = decode(encoded);
    // Print the matrix
    std.debug.print("Matrix:\n", .{});
    for (decoded) |row| {
        for (row) |cell| {
            std.debug.print("{} ", .{@bitCast(u1,cell)});
        }
        std.debug.print("\n", .{});
    }
}
