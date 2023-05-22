const std = @import("std");

const MAX_NODES = 10;

/// In process graph transitions happen in parallel,
/// Parallel transitions can be merged into one and back.
/// Loop of process transitions can be merged into one and back.
/// Outputs of parallel transitions are also parallel.
const PGComptimeAdjmap = struct {
    var adj = [_][_]u8{
        [_]u8{0}**MAX_NODES,
    }**MAX_NODES; // only 0 and 1 are valid
//     pub fn addNode // done at declaration
//     pub fn addEdge // just set value

};
var adj = [_][_]bool{
    [_]bool{0}**MAX_NODES,
}**MAX_NODES; // only 0 and 1 are valid


// A function to find the longest path between two nodes in the graph using an adjacency matrix
pub fn longestPath(matrix: [][]bool, starts: []usize, ends: []usize) ?[]usize {
    var max_path: [MAX_NODES]usize = undefined;
    var max_length: usize = 0;
    for (starts) |start| {
        for (ends) |end| {
            var visited: [MAX_NODES]bool = undefined;
            var path: [MAX_NODES]usize = undefined;
            var path_length: usize = 0;
            if (start < matrix.len and end < matrix.len) {
                longestPathHelper(matrix, start, end, &visited, &path, &path_length, &max_path, &max_length);
            } else {
                std.log.err("bad");
            }
        }
    }
    return max_path[0..max_length];
}

// A helper function to recursively find the longest path using DFS and an adjacency matrix
fn longestPathHelper(matrix: [][]bool, current: usize, end: usize, visited: *[MAX_NODES]bool, path: *[MAX_NODES]usize, path_length: *usize, max_path: *[MAX_NODES]usize, max_length: *usize) void {
    // Mark the current node as visited and add it to the path
    visited[current] = true;
    path[path_length.*] = current;
    path_length.* += 1;

    // If the current node is the end node, compare the path length with the max length and update accordingly
    if (current == end) {
        if (path_length.* > max_length.*) {
            max_length.* = path_length.*;
            std.mem.copy(usize,max_path,path[0..max_length.*]);
        }
    } else {
        // Recur for all the adjacent nodes of the current node
        for (matrix[current]) |edge_exists,i| {
            if (edge_exists and !visited[i]) {
                longestPathHelper(matrix,i,end, visited,path,path_length,max_path,max_length);
            }
        }
    }

    // Backtrack and remove the current node from the path and mark it as unvisited
    path_length.* -= 1;
    visited[current] = false;
}

// Check if matrix is a process graph
fn validateProcessGraph(matrix: [MAX_NODES][MAX_NODES]bool) bool{

//     var visited = [1]bool{0}**MAX_NODES;
    for(matrix) |n, outs| {
        if(matrix[n][n]) {
            // its process
            // May have multiple entrances
            // Can't be connected to other process
            // Shouldn't transit to itself, that is redundancy

        } else {
            // its transition
            // Outputs are parallel
        }
        // No nodes with same inputs and outputs
    }
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
//     std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    adj[1][1] = 1;
    adj[1][2] = 1;
    adj[3][2] = 1;
//     var starts[2] = [2]usize{
    var longest_path = longestPath(adj, );

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
