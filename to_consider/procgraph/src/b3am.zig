const std = @import("std");

fn AdjMat(comptime EdgeType: type) type {
    return struct {
        const Self = @This();
        mat: [][]EdgeType,

        pub fn init(allocator: *std.mem.Allocator, size: usize) !Self {
            var mat = try allocator.alloc([]EdgeType, size);
            errdefer allocator.free(mat);
            for (mat) |*row| {
                row.* = try allocator.alloc(EdgeType, size);
                errdefer allocator.free(row.*);
            }
            return Self{ .mat = mat };
        }
    };
}

test "AdjMat" {
    var allocator = std.testing.allocator;
    const MyAdjMat = AdjMat(f32);
    var my_mat = try MyAdjMat.init(&allocator, 3);
    defer {
        for (my_mat.mat) |row| {
            allocator.free(row);
        }
        allocator.free(my_mat.mat);
    }
}
