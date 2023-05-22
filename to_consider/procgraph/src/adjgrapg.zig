const std = @import("std");
fn brek() void {}

// This file contains graph that will be
// used to find shortest path on computer.
//
// All algorithms can be defined inside process graph itself.
// HDL can be used for that.
// Zig generates static binary, which can contain/find definition of
// what processor it runs on does to convert itself to process graph.

// Adjacency matrix is used for simplicity. CSR require a lot of
// allocations and memory moves to edit and is more complex.
// We can have up to ~1000 nodes in memory without issues.
// More nodes can be procedural.

// Define a queue struct
// pub const Queue = struct {
//     // The array of bool as a field
//     data: [8]ProcGraph.EType,
//
//     // The front and rear indices
//     front: usize,
//     rear: usize,
//
//     // Create a new queue and initialize the indices to 0
//     pub fn new() Queue {
//         return Queue{
//             .data = [_]usize{0} ** 8,
//             .front = 0,
//             .rear = 0,
//         };
//     }
//
//     // Enqueue a vertex to the queue
//     pub fn enqueue(self: *Queue, vertex: usize) void {
//         self.data[self.rear] = vertex;
//         self.rear = (self.rear + 1) % self.data.len;
//     }
//
//     // Dequeue a vertex from the queue
//     pub fn dequeue(self: *Queue) ?usize {
//         if (self.front == self.rear) return null; // Queue is empty
//         const vertex = self.data[self.front];
//         self.front = (self.front + 1) % self.data.len;
//         return vertex;
//     }
// };

// Procedural generation
// In this file there was just 8 node test, but now big graph tests needed.
// One example is processor states, which I made.
// Another is video sequence.
// To read files we need the procedural nodes.
// Procedural access requires graph getter, (setter, adder, deleter are optional later) methods.
// One way is procedural edge type, which calls procedure attached to
// target that returns node with edges.
//

// Logic functions
// In procgraph everything is a transition between states, so
// logic functions are truth tables here.
// It is possible to merge truth table into one logic function.
// Circuit of these logic elements can be merged into another function and so on.
//
// I forgot what to write here, maybe about conversion of pathfinding to CNF and using SAT to solve it?
//
// Communication among multiple graphs
// There are many ways to implement that.
// One of them is to create a data structure
// inside graph, for example special node
// connections to which are mapped as connections
// to indexes of another graph. In which case
// there can be connections to nothing, like
// in hyperlinks.
// Another way is to copy whole graph.
// This can be done procedurally without
// actual copying.

// Types inside graph
// We can connect nodes to type parser
// that can call procedures for that type.
// This can be used to create a type factory.

// Define a struct for the graph
pub const ProcGraph = struct {
    // Process graph can be used to find the best
    // edge type system.
    // For example to pack sequence of transitions into 1
    // we could pack it into one edge weight

    // edge type needed to traverse graph back faster
    // may be replaced with 1 out, or in for packing
    //     const EType = bool;
    matrix: [16][16]EType = [1][16]EType{[1]EType{EType.none} ** 16} ** 16,
    //     alloc = std.heap.ArenaAllocator,
    const EType = enum {
        none,
        in,
        out,
        inout, // INOUT or in or out to self means process
        expansion, // possible only in parallel nodes because there is no edge weight
        merge,
    };
    const Edge = struct {
        time: i8 = 0, // 0 is no edge, - is in, + is out.
        type: EType,
    };
    //     const EType = i8;
    // The adjacency matrix as an array of arrays of bools

    // Create a new graph and initialize the matrix to false
    pub fn new() ProcGraph { // TODO: set some parameters from args, like array len, edge type
        var g = ProcGraph{};
        return g;
    }

    // Add an edge from one vertex to another
    pub fn addEdge(self: *ProcGraph, from: usize, to: usize) void {
        //         if(EType == bool) {
        //             self.matrix[from][to] = true;
        //         }
        //         if(EType == EdgeEnum) {
        switch (self.matrix[to][from]) {
            EType.none => self.matrix[to][from] = EType.in,
            EType.in => {},
            EType.out => self.matrix[to][from] = EType.inout,
            EType.inout => {},
            EType.expansion => std.log.err("tried to connect from expansion at {}:{}", .{ to, from }),
            EType.merge => std.log.err("tried to connect from merge at {}:{}", .{ to, from }),
        }
        switch (self.matrix[from][to]) {
            EType.none => self.matrix[from][to] = EType.out,
            EType.in => self.matrix[from][to] = EType.inout,
            EType.out => {},
            EType.inout => {},
            EType.expansion => std.log.err("tried to connect to expansion at {}:{}", .{ to, from }),
            EType.merge => std.log.err("tried to connect to merge at {}:{}", .{ to, from }),
        }
        //         self.matrix[from][to] = EType.out;
        //         }
        //         if(EType == i8) {
        //         }
    }

    // Check if there is an edge from one vertex to another
    pub fn hasEdge(self: ProcGraph, from: usize, to: usize) bool {
        return self.matrix[from][to];
    }

    // Print the graph
    pub fn print(self: ProcGraph) void {
        for (self.matrix, 0..) |row, id| {
            std.debug.print("{}: ", .{id});
            for (row) |cell| {
                //                 std.debug.print("{} ", .{@bitCast(u1, cell)});
                std.debug.print("{} ", .{@enumToInt(cell)});
            }
            std.debug.print("\n", .{});
        }
    }

    // PROBABLY NOT NEEDED, OR MUST BE UPDATED FOR PROCESS GRAPH
    // Perform BFS on the graph starting from a given vertex
    //     pub fn bfs(self: ProcGraph, source: usize) void {
    //         // Create a queue and enqueue the source vertex
    //         var q = Queue.new();
    //         q.enqueue(source);
    //
    //         // Create an array of bools to mark the visited vertices and mark the source as visited
    //         var visited = [_]bool{false} ** 8;
    //         visited[source] = true;
    //
    //         // Create an array of usize to store the distances from the source and initialize them to infinity
    //         var distance = [_]usize{16} ** 8;
    //         distance[source] = 0;
    //
    //         // Loop until the queue is empty
    //         while (q.dequeue()) |vertex| {
    //             // Print the current vertex and its distance
    //             std.debug.print("Vertex {} : Distance {}\n", .{ vertex, distance[vertex] });
    //
    //             // Loop through the adjacent vertices of the current vertex
    //             for (self.matrix[vertex], 0..) |edge, i| {
    //                 // If there is an edge and the vertex is not visited, enqueue it and mark it as visited
    //                 if (edge and !visited[i]) {
    //                     q.enqueue(i);
    //                     visited[i] = true;
    //
    //                     // Update the distance of the vertex as one more than the distance of the current vertex
    //                     distance[i] = distance[vertex] + 1;
    //                 }
    //             }
    //         }
    //     }
    //
    //     // MUST BE UPDATED TO RULES OF PROCESS GRAPH
    //     // Find the shortest path from one vertex to another using BFS
    //     pub fn shortestPath(self: ProcGraph, source: usize, destination: usize) void {
    //         // Create a queue and enqueue the source vertex
    //         var q = Queue.new();
    //         q.enqueue(source);
    //
    //         // Create an array of bools to mark the visited vertices and mark the source as visited
    //         var visited = [_]bool{false} ** 8;
    //         visited[source] = true;
    //
    //         // Create an array of usize to store the predecessors of each vertex and initialize them to null
    //         var predecessor = [_]?usize{null} ** 8;
    //
    //         // Loop until the queue is empty or the destination is found
    //         while (q.dequeue()) |vertex| {
    //             // If the current vertex is the destination, break the loop
    //             if (vertex == destination) break;
    //
    //             // Loop through the adjacent vertices of the current vertex
    //             for (self.matrix[vertex], 0..) |edge, i| {
    //                 // If there is an edge and the vertex is not visited, enqueue it and mark it as visited
    //                 if (edge and !visited[i]) {
    //                     q.enqueue(i);
    //                     visited[i] = true;
    //
    //                     // Update the predecessor of the vertex as the current vertex
    //                     predecessor[i] = vertex;
    //                 }
    //             }
    //         }
    //
    //         // If the destination is not visited, there is no path
    //         if (!visited[destination]) {
    //             std.debug.print("No path from {} to {}\n", .{ source, destination });
    //             return;
    //         }
    //
    //         // Create an array to store the path and initialize it to null
    //         var path = [_]?usize{null} ** 8;
    //
    //         // Set the last element of the path as the destination
    //         path[path.len - 1] = destination;
    //
    //         // Loop backwards from the destination to the source using the predecessor array and fill the path array
    //         var i = path.len - 2;
    //         var j = destination;
    //         while (predecessor[j]) |p| {
    //             path[i] = p;
    //             i -= 1;
    //             j = p;
    //         }
    //
    //         // Print the path by skipping the null elements
    //         std.debug.print("Path from {} to {} : ", .{ source, destination });
    //         for (path) |vertex| {
    //             if (vertex) |v| {
    //                 std.debug.print("{} ", .{v});
    //             }
    //         }
    //         std.debug.print("\n", .{});
    //     }
    // TODO:
    // 1) traverse (nearly done)
    // 2) longest path finding
    // 3) optional alloc
    // 4) shortest path finding
    const PPerr = error{NOT_A_PROCESS_NODE};
    const PresentProcesses = struct {
        nodes: [16]u8 = [1]u8{0} ** 16,
        len: u8 = 0,
        fn append(self: *PresentProcesses, node_id: u8) void {
            // Don't add existing
            for (self.nodes) |tid| {
                if (tid == node_id) {
                    std.log.debug("returned to proc {}", .{node_id});
                    return;
                }
            }
            self.nodes[self.len] = node_id;
            self.len += 1;
        }
        fn check(self: PresentProcesses, pg: ProcGraph) !void {
            for (self.nodes, 0..) |node, i| {
                if (i >= self.len) {
                    break;
                }
                if (pg.matrix[node][node] != EType.out and
                    pg.matrix[node][node] != EType.in and
                    pg.matrix[node][node] != EType.inout)
                {
                    std.log.err("not a process node {d} in   present.nodes[{d}]\n{any}\n{any}\n{any}", .{ node, i, pg.matrix[node], pg.matrix[node][node], self });
                    return PPerr.NOT_A_PROCESS_NODE; // TODO: error set
                }
            }
        }
    };
    const Visited = struct {
        arr: [16]PresentProcesses = [1]PresentProcesses{PresentProcesses{}} ** 16,
        len: u8 = 0,
        fn append(self: *Visited, nodes: PresentProcesses) void {
            self.arr[self.len] = nodes;
            self.len += 1;
        }
    };
    const Transitions = struct {
        arr: [16]u8 = [1]u8{0} ** 16,
        len: u8 = 0,
        fn append(self: *Transitions, node_id: u8) void {
            // Don't add existing
            for (self.arr) |tid| {
                if (tid == node_id) {
                    std.log.debug("transition {} exists", .{node_id});
                    return;
                }
            }
            self.arr[self.len] = node_id;
            self.len += 1;
        }
        fn check(self: PresentProcesses, pg: ProcGraph) void {
            for (self.nodes, 0..) |node, i| {
                if (i >= self.len) {
                    break;
                }
                if (pg.matrix[node][node] == EType.out and
                    pg.matrix[node][node] == EType.in and
                    pg.matrix[node][node] == EType.inout)
                {
                    std.log.err("not a transition node {d} in Transitions.arr[{d}]\n{any}\n{any}\n{any}", .{ node, i, pg.matrix[node], pg.matrix[node][node], self });
                    return; // TODO: error set
                }
            }
        }
    };
    const traverse_err = error{
        wrong_start,
        overlapping_edges,
        transition_not_to_process,
        process_to_other_process,
    };
    // Get path from start processes to max_depth
    fn traverse(self: ProcGraph, start: PresentProcesses, direction: EType, max_depth: u16) !Visited { //[][]usize{

        var present = start;
        var visited = Visited{};
        var transitions = Transitions{};
        present.check(self) catch |err| {
            switch (err) {
                PPerr.NOT_A_PROCESS_NODE => return traverse_err.wrong_start,
                else => return err,
            }
        };

        switch (direction) {
            EType.none => {
                // Traverse unconnected. How?
                // Traverse everything else and negate resulting nodes?
                std.log.info("TODO: traverse EType.none", .{});
            },
            EType.in => {
                // Back in time traverse
                std.log.info("TODO: traverse EType.in", .{});
                // Should be same as EType.out
            },
            EType.out => {
                std.log.info("Traversing forward", .{});
                // Forward in time traverse. Most important.
                //

                // While exact same array of present nodes
                // in visited array not exists.
                var depth: u16 = 0;
                var looped = false;
                while (looped == false) {
                    std.debug.print("{}\n   ", .{depth});
                    if (depth >= max_depth) {
                        std.log.info("max_depth reached", .{});
                        break;
                    }
                    // Add present array to visited array
                    visited.append(present);
                    //                     std.log.debug("{any}", .{visited});

                    // Clear transitions
                    transitions.len = 0;
                    // Get connected transitions.
                    for (present.nodes, 0..) |node_id, l| {
                        if (l >= present.len) {
                            break;
                        }
                        // Iterate over each present node id in graph
                        // to get target id and EType
                        //                         @compileLog("{any}", .{self.matrix[node_id]});
                        //                         for (self.matrix[node_id]) |targets| {
                        //                             for (targets, 0..) |edge, target_id| {
                        //                                 if (edge == EType.out) {
                        //                                     transitions.append(target_id);
                        //                                 }
                        //                             }
                        //                         }
                        // Why it gets single element this way?
                        for (self.matrix[node_id], 0..) |target_edge, tid| {
                            if (target_edge == EType.out or target_edge == EType.inout) {
                                //                                 if(self.matrix[tid][tid] != EType.inout and
                                //                                    self.matrix[tid][tid] != EType.out and
                                //                                    self.matrix[tid][tid] != EType.in) {
                                //                                     std.log.err("from self.matrix[{}][{}] is {any}",.{tid,tid,self.matrix[tid][tid]});
                                //                                     return traverse_err.process_to_other_process;
                                //                                 }
                                // TODO: reason this
                                if (self.matrix[tid][tid] == EType.inout) {
                                    var noout = true;
                                    for (self.matrix[tid], 0..) |etype, eid| {
                                        if (eid == tid) {
                                            continue;
                                        }
                                        if (etype == EType.out or
                                            etype == EType.inout)
                                        {
                                            noout = false;
                                            break;
                                        }
                                    }
                                    if (noout) {
                                        transitions.append(@intCast(u8, tid));
                                    }
                                    continue;
                                }
                                transitions.append(@intCast(u8, tid));
                            }
                        }
                    }
                    std.log.debug("transitions: {any}", .{transitions});
                    // TODO: add transitions to visited

                    // And iterate back
                    // from each to get if it has only present nodes
                    // select transitions that covers most of nodes without overlapping.
                    // Here comes the biggest issue of process graph:
                    // what if there are multiple possible transition sets
                    // that cover the same number of processes?
                    // How to solve that and keep deterministic and ...
                    // Any transitions can be merged, so
                    // selecting one with biggest number of
                    // input nodes is not an option for all cases.
                    //
                    // Just return error in case of
                    // mutally exclusive multiple possible transitions.
                    for (transitions.arr) |transition0| {
                        for (transitions.arr) |transition1| {
                            // Ignoring case of loop to self is wrong, but
                            // here helps
                            if (transition0 == transition1) {
                                continue;
                            }
                            // Get in edges of transitions
                            for (self.matrix[transition0], 0..) |etype0, eid0| {
                                for (self.matrix[transition1], 0..) |etype1, eid1| {
                                    if ((etype0 == EType.in) and
                                        (etype1 == EType.in) and
                                        eid0 == eid1)
                                    {
                                        std.log.err("overlapping edges, don't know which transition to choose:\n{any},{any},e:{d}", .{ transition0, transition1, eid0 });
                                        return traverse_err.overlapping_edges; // TODO: proof this, return struct where errors
                                    }
                                }
                            }
                        }
                    }

                    // After error check, set present array len,
                    // overwrite present array with
                    // all present nodes without transition and
                    // all transition targets.
                    present.len = 0;
                    for (transitions.arr, 0..) |transition, t| {
                        if (t >= transitions.len) {
                            break;
                        }
                        // process transits only to self if not transits
                        // TODO: reason this
                        if (self.matrix[transition][transition] == EType.inout) {
                            var noout = true;
                            for (self.matrix[transition], 0..) |etype, eid| {
                                if (eid == transition) {
                                    continue;
                                }
                                if (etype == EType.out or
                                    etype == EType.inout)
                                {
                                    noout = false;
                                    break;
                                }
                            }
                            if (noout) {
                                present.append(@intCast(u8, transition));
                            }
                            continue;
                        }
                        for (self.matrix[transition], 0..) |etype, eid| {
                            if (etype == EType.out or etype == EType.inout) {
                                if (self.matrix[eid][eid] != EType.out and
                                    self.matrix[eid][eid] != EType.in and
                                    self.matrix[eid][eid] != EType.inout)
                                {
                                    std.log.err("not a process node {d} in transition outs[{d}]\n{any}\n{any}\n{any}", .{ eid, t, self.matrix[eid], self.matrix[eid][eid], transition });
                                    return PPerr.NOT_A_PROCESS_NODE; // TODO: error set
                                }
                                present.append(@intCast(u8, eid));
                            }
                        }
                    }
                    try present.check(self);

                    // Get if full loop was iterated
                    for (visited.arr, 0..) |state, itr| {
                        if (itr >= visited.len) {
                            break;
                        }
                        if (std.mem.eql(u8, &state.nodes, &present.nodes)) {
                            if (looped == true) {
                                std.log.err("multiple visited are same as present {any}\n{any}", .{ present, visited });
                            }
                            looped = true;
                        }
                    }
                    depth += 1;
                    if (present.len == 0) {
                        std.log.err("present not supposed to be empty", .{});
                    }
                }
            },
            EType.inout => {
                // Back and forward in time traverse
                std.log.info("TODO: traverse EType.inout", .{});
                // Should be same as EType.out with EType.in
            },
            EType.expansion => {
                // Show nodes that show what inside nodes
                std.log.info("TODO: traverse EType.expansion", .{});
            },
            EType.merge => {
                // Show nodes that are merge to one node until no more merge
                std.log.info("TODO: traverse EType.merge", .{});
            },
        }
        if (visited.len != 0) {
            for (visited.arr, 0..) |pp, vid| {
                if (vid >= visited.len) {
                    break;
                }
                std.log.debug("path: {any}", .{pp});
            }
            std.log.debug("length: {d}", .{visited.len});
        } else {
            std.log.err("visited nothing, error in code", .{});
        }
        return visited;
    }
    fn check(self: ProcGraph) !void{
        // TODO
        _ = self;
    }
    //     fn traverse_between(self: ProcGraph, start: PresentProcesses, end: PresentProcesses, direction: EType, max_depth: u16) Visited {}

    // Find longest path between any starts and ends
    //     fn longest_path(self: ProcGraph) Visited{
    //     }
    // Find longest path between starts and ends with path containing path
    //     fn longest_path_containing(self: ProcGraph, containing: Visited) Visited {}

    // Shortest paths
    // one present has only one path, so, just like longest paths,
    // it searches among multiple presented.
    // For example, among paths including only one process from array.
};

pub fn main() !void {
    // Create a new graph
    var g = ProcGraph.new();

    // Add some edges
    g.addEdge(0, 1);
    g.addEdge(1, 1);
    g.addEdge(1, 2);
    g.addEdge(2, 3);
    g.addEdge(2, 1);
    g.addEdge(2, 5);
    g.addEdge(3, 0);
    g.addEdge(3, 3);
    g.addEdge(1, 4);
    g.addEdge(4, 5);
    g.addEdge(5, 6);
    g.addEdge(5, 5);
    g.addEdge(6, 7);
    g.addEdge(7, 4);
    g.addEdge(7, 7);
    g.addEdge(8, 6);
    g.addEdge(8, 8);

    // Print the graph
    g.print();

    // Perform BFS on the graph starting from vertex 0
    //     g.bfs(0);

    // Find the shortest path from vertex 0 to vertex 7
    //     g.shortestPath(0, 7);

    // Traverse
    var start = ProcGraph.PresentProcesses{};
    start.len = 1;
    start.nodes[0] = 1;
    var path = try g.traverse(start, ProcGraph.EType.out, 100);
    _ = path;
}

test "allPossibleGraphs" {
    // For each possible graph
    var g = ProcGraph{};
    var m = @ptrCast([64]ProcGraph.EType, &g.matrix);
    var node: u8 = 0;
    var conn: u8 = 0;
    // Array that contains current id and value on adjmat
    //     const CurrentValue = struct {
    //         c: [2]u8,
    //         id: u8,
    //         v: ProcGraph.EType,
    //     };
    //     var cv = CurrentValue{.id=g.matrix.len*g.matrix.len, .v=g.EType.merge};
    //     while(node < g.matrix.len) : (node+=1) {
    //         while (conn < g.matrix.len) : (conn+=1) {
    //             // 2d access test
    //         }
    //     }
    var cv: u8 = m.len - 1;
    while (true) {
        // Generate graph
        if (m[cv] == g.EType.merge) {
            m[cv] = g.EType.none;
            if (cv == 0) {
                break;
            } else {
                cv -= 1;
            }
        } else {
            m[cv] += 1;
            cv = m.len - 1;
        }
        // Validate
        g.check(); // does nothing, yet
        // Traverse
        var p = ProcGraph.PresentProcesses{};
        var parr = @ptrCast([64]u8,&p.nodes);
        // Generate each possible present
        while(true) {
        }
        // Shortest paths
        // Longest paths
    }
}

test "traverse" {
    // Predefine graph
    // Predefine path
    // Comapare traversed with predefined
}

test "sequence to procgraph" {}
