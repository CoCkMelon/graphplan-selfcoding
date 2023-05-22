const std = @import("std");
const testing = std.testing;
const AdjMat = @import("adjmat.zig").AdjMat;

test "init and deinit" {
    var allocator = std.testing.allocator;
    var mat = try AdjMat.init(&allocator, 5);
    defer mat.deinit(&allocator);

    try testing.expectEqual(mat.mat.len, 5);
    for (mat.mat) |row| {
        try testing.expectEqual(row.len, 5);
        for (row) |edge| {
            try testing.expectEqual(edge, 0);
        }
    }
}

test "getNode" {
    var allocator = std.heap.page_allocator;
    var mat = try AdjMat.init(&allocator, 5);
    defer mat.deinit(&allocator);

    try testing.expect(mat.getNode(0));
    try testing.expect(mat.getNode(4));
    try testing.expect(!mat.getNode(5));
}

test "getOutEdges and getInEdges" {
    var allocator = std.testing.allocator;
    var mat = try AdjMat.init(&allocator, 5);
    defer mat.deinit(&allocator);

    mat.addEdge(0, 1, 1);
    mat.addEdge(0, 2, 2);
    mat.addEdge(1, 3, 3);
    mat.addEdge(2, 4, 4);

    const out_edges_0 = mat.getOutEdges(0);
    try testing.expectEqual(out_edges_0[0], 0);
    try testing.expectEqual(out_edges_0[1], 1);
    try testing.expectEqual(out_edges_0[2], 2);
    try testing.expectEqual(out_edges_0[3], 0);
    try testing.expectEqual(out_edges_0[4], 0);

    const in_edges_3 = mat.getInEdges(&allocator, 3);
    defer allocator.free(in_edges_3);
    try testing.expectEqual(in_edges_3[0], 0);
    try testing.expectEqual(in_edges_3[1], 3);
    try testing.expectEqual(in_edges_3[2], 0);
    try testing.expectEqual(in_edges_3[3], 0);
    try testing.expectEqual(in_edges_3[4], 0);
}

test "adjacent and neighbors" {
    var allocator = std.heap.page_allocator;
    var mat = try AdjMat.init(&allocator, 5);
    defer mat.deinit(&allocator);

    mat.addEdge(0, 1, 1);
    mat.addEdge(0, 2, 2);
    mat.addEdge(1, 3, 3);
    mat.addEdge(2, 4, 4);

    try testing.expect(mat.adjacent(0, 1));
    try testing.expect(!mat.adjacent(1, 0));
    try testing.expect(!mat.adjacent(3, 4));

    const neighbors_0 = try mat.neighbors(&allocator, 0);
    defer allocator.free(neighbors_0);
    try testing.expectEqual(neighbors_0.len, 2);
    try testing.expectEqual(neighbors_0[0], 1);
    try testing.expectEqual(neighbors_0[1], 2);

}

test "addVertex and removeVertex" {
    var allocator = std.heap.page_allocator;
    var mat = try AdjMat.init(&allocator, 5);
    defer mat.deinit(&allocator);

    try mat.addVertex(&allocator);

    try testing.expectEqual(mat.mat.len, 6);
    
     for (mat.mat) |row| {
        try testing.expectEqual(row.len,6);
        for (row) |edge| {
            try testing.expectEqual(edge,0);
        }
     }

     mat.removeVertex(&allocator,2); 

     try testing.expectEqual(mat.mat.len,5);
     for (mat.mat) |row| {
        try testing.expectEqual(row.len,5);
     }

     // check that the edges are shifted correctly
     mat.addEdge(1,2,1); 
     mat.addEdge(2,3,2); 
     mat.addEdge(3,4,3); 

     const out_edges_1 = mat.getOutEdges(1); 
     const out_edges_2 = mat.getOutEdges(2); 
     const out_edges_3 = mat.getOutEdges(3); 

     try testing.expectEqual(out_edges_1[2],1);
     try testing.expectEqual(out_edges_2[3],2);
     try testing.expectEqual(out_edges_3[4],3);

}

test "swapVertices" {
    var allocator = std.testing.allocator;
    var mat = try AdjMat.init(&allocator, 4);
    defer mat.deinit(&allocator);

    mat.addEdge(0, 1, 1);
    mat.addEdge(0, 3, 2);
    mat.addEdge(1, 2, 3);
    mat.addEdge(1, 0, 4);
    mat.addEdge(2, 0, 5);
    mat.addEdge(3, 1, 6);

    std.debug.print("\nmat{any}\n",.{mat.mat});
    mat.swapVertices(0, 1);
    std.debug.print("mat{any}\n",.{mat.mat});
}

test "benchmark addVertex" {
    var allocator = std.heap.page_allocator;
    var mat = try AdjMat.init(&allocator, 0);
    defer mat.deinit(&allocator);

    var timer = try std.time.Timer.start();

    var count: usize = 0;

    const max_count: usize = 5000;
    while (count <= max_count) {
        mat.addVertex(&allocator) catch |err| switch (err) {
            error.OutOfMemory => {},
            else => unreachable,
        };

        count += 1;
//         if(count%10000 == 0) {
//             std.debug.print("mat.len={d};",.{mat.mat.len});
//         }
    }
    var elapsed = timer.read();
    std.debug.print("\nAdded {} nodes in {} nanoseconds\n", .{ count, elapsed });
    timer.reset();
    while (count > 0) {
        mat.removeVertex(&allocator, mat.mat.len - 1);
        count -= 1;
    }
    elapsed = timer.read();
    std.debug.print("Now {} nodes in {} nanoseconds\n", .{ count, elapsed });
}
