const std = @import("std");

const Graph = struct {
    num_nodes: u32,
    num_edges: u32,
    offsets: []u32,
    indices: []u32,
    //values: []f64,
    fn addNode(self: *Graph, offset: u32, index:u32,
        allocator: std.mem.Allocator) !void{
        self.offsets=try allocator.realloc(
            self.offsets,self.num_nodes+1);
        self.offsets[self.num_nodes]=offset;
        self.indices=try allocator.realloc(
            self.indices,self.num_nodes+1);
        self.indices[self.num_nodes]=index;
        self.num_nodes+=1;
    }
};

fn serializeGraph(writer: anytype, graph: Graph) !void {
    // Write the number of nodes and edges
    try writer.writeIntLittle(u32, graph.num_nodes);
    try writer.writeIntLittle(u32, graph.num_edges);

    // Write the offsets array
    for (graph.offsets) |offset| {
        try writer.writeIntLittle(u32, offset);
    }

    // Write the indices array
    for (graph.indices) |index| {
        try writer.writeIntLittle(u32, index);
    }

    // Write the values array
    //for (graph.values) |value| {
    //  try writer.writeFloatLittle(f64, value);
    //}
}

fn deserializeGraph(reader: anytype, allocator: std.mem.Allocator) !Graph {
    // Read the number of nodes and edges
    const num_nodes = try reader.readIntLittle(u32);
    const num_edges = try reader.readIntLittle(u32);

    // Read the offsets array
    var offsets = try allocator.alloc(u32, num_nodes); //+1
    errdefer allocator.free(offsets);
    for (offsets) |*offset| {
        offset.* = try reader.readIntLittle(u32);
    }

    // Read the indices array
    var indices = try allocator.alloc(u32, num_edges);
    errdefer allocator.free(indices);
    for (indices) |*index| {
        index.* = try reader.readIntLittle(u32);
    }

    // Read the values array
    //var values = try allocator.alloc(f64, num_edges);
    //errdefer allocator.free(values);
    //for (values) |*value| {
    //    value.* = try reader.readLittle(f64);
    //}

    // Return the graph structure
    return Graph{
        .num_nodes = num_nodes,
        .num_edges = num_edges,
        .offsets = offsets,
        .indices = indices,
        //  .values = values,
    };
}

fn useOpengraph() !void {
    var why =  [_]u32{0,1,2};
    var offs: []u32 = why[0..2];
    var graphout = Graph{
        .num_nodes=2,
        .num_edges=2,
        .offsets=offs,
        .indices=offs,
    };
    const file = try std.fs.cwd().createFile("graph.bin", .{});
    defer file.close();
//     const file2 = try std.fs.cwd().openFile("graph.bin", .{.read=true,.write=true});
    const file2 = try std.fs.cwd().openFile("graph.bin", .{.mode=.read_write});
    defer file2.close();
    try serializeGraph(file.writer(), graphout);
    var graph = try deserializeGraph(file2.reader(), std.heap.page_allocator);
    defer std.heap.page_allocator.free(graph.offsets);
    defer std.heap.page_allocator.free(graph.indices);
    //defer std.heap.page_allocator.free(graph.values);
    try graph.addNode(2, 2,std.heap.page_allocator);
    try graph.addNode(4, 3,std.heap.page_allocator);
    try graph.addNode(5, 4,std.heap.page_allocator);
    std.log.debug("{}\n{}",.{graphout,graph});
    var adjmat:[][]bool=undefined;
    csrToAdjacency(graph, &adjmat);
    var y:u8=0;
    var x:u8=0;
    std.log.debug("{any}",.{adjmat});
    while(y<graph.num_nodes) {
        while(x<graph.num_nodes) {
            std.debug.print("{d} ",.{@bitCast(u1, adjmat[x][y])});
            x+=1;
        }
        x=0;
        y+=1;
        std.debug.print("\n",.{});
    }
    var gr3 = adjacencyToCsr(adjmat);

    std.log.debug("{any}",.{gr3});
}

//Alternatively, you can use some existing libraries that provide binary serialization formats and tools for Zig, such as:

//- s2s²: A Zig binary serialization format and library that supports converting (nearly) any Zig runtime datatype to binary data and back. It computes a stream signature that prevents deserialization of invalid data.
//- karmem³: A fast binary serialization format that is faster than Google Flatbuffers and optimized for TinyGo and WASM. It supports GEO Spatial

//Source: Conversation with Bing, 04/04/2023(1) GitHub - ziglibs/s2s: A zig binary serialization format.. https://github.com/ziglibs/s2s Accessed 04/04/2023.
//(2) GitHub - inkeliz/karmem: Karmem is a fast binary serialization format .... https://github.com/inkeliz/karmem Accessed 04/04/2023.
//(3) GitHub - qbradley/bincode-zig: A zig binary serializer/deserializer .... https://github.com/qbradley/bincode-zig Accessed 04/04/2023.
//(4) A Survey of JSON-compatible Binary Serialization Specifications. https://arxiv.org/abs/2201.02089 Accessed 04/04/2023.

// A function that converts a CSR graph to an adjacency matrix
fn csrToAdjacency(graph: Graph, matrix:*[][]bool) void{
    // Create a matrix of size num_nodes x num_nodes
    matrix.* = std.heap.page_allocator.alloc([]bool,
        graph.num_nodes+1) catch unreachable;
    //defer std.heap.page_allocator.free(matrix);
    std.debug.print("{any}\n",.{matrix.*[0].len});
    for (matrix.*) |*row| {
        row.* = std.heap.page_allocator.alloc(bool, graph.num_nodes+1) catch unreachable;
        //defer std.heap.page_allocator.free(row.*);
        // Initialize all elements to false
        for (row.*) |*elem| {
            elem.* = false;
        }
    }
    std.debug.print("{any}\n",.{matrix.*[0][0]});

    // Iterate over the offsets array
    var i: usize = 0;
    while (i < graph.num_nodes-1) : (i += 1) {
        // Get the start and end positions of the row
        const start = graph.offsets[i];
        const end = graph.offsets[i + 1];
        // Iterate over the indices and values arrays
        var j: usize = start;
        while (j < end) : (j += 1) {
            // Get the column index and value
            const col = graph.indices[j];
            //const val = graph.values[j];
            // Set the matrix element to true
            std.debug.print("m[{}][{}]",.{i,col});
            matrix.*[i][col] = true;
        }
    }

    // Return the matrix
    //return matrix;
}

// A function that converts an adjacency matrix to a CSR graph
fn adjacencyToCsr(matrix: [][]bool) Graph {
    // Get the number of nodes and edges
    const num_nodes = @intCast(u32, matrix.len);
    var num_edges: u32 = 0;
    for (matrix) |row| {
        for (row) |elem| {
            if (elem) num_edges += 1;
        }
    }

    // Create the offsets, indices, and values arrays
    var offsets = std.heap.page_allocator.alloc(u32, num_nodes + 1) catch unreachable;
    //defer std.heap.page_allocator.free(offsets);
    var indices = std.heap.page_allocator.alloc(u32, num_edges) catch unreachable;
    //defer std.heap.page_allocator.free(indices);
    // var values = std.heap.page_allocator.alloc(f64, num_edges) catch unreachable;
    // defer std.heap.page_allocator.free(values);

    // Initialize the first offset to zero
    offsets[0] = 0;

    // Iterate over the matrix
    var i: u32 = 0;
    var k: u32 = 0;
    while (i < num_nodes) : (i += 1) {
        // Iterate over the row
        var j: u32 = 0;
        while (j < num_nodes) : (j += 1) {
            // Get the element value
            const elem = matrix[i][j];
            // If it is true, append its row and column indices to the indices array
            if (elem) {
                indices[k] = j;
                // Append its weight (which can be 1 or any other value) to the values array
                //values[k] = 1.0;
                // Increment the position in the indices and values arrays
                k += 1;
            }
        }
        // Update the offset for the next row
        offsets[i + 1] = k;
    }

    // Return the graph structure
    return Graph{
        .num_nodes = num_nodes,
        .num_edges = num_edges,
        .offsets = offsets,
        .indices = indices,
        //.values = values,
    };
}

pub fn main() !void {
    try useOpengraph();
}
