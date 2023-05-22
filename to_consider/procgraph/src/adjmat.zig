const std = @import("std");


pub const AdjMat = struct {
    mat: [][]EdgeType,
    pub const EdgeType: type = u8;

    pub fn init(allocator: *std.mem.Allocator, size: usize) !AdjMat {
        var mat = try allocator.alloc([]EdgeType, size);
        for (mat) |*row| {
            row.* = try allocator.alloc(EdgeType, size);
            @memset(row.*,0);
        }
        return AdjMat{ .mat = mat };
    }

    pub fn deinit(self: *AdjMat, allocator: *std.mem.Allocator) void {
        for (self.mat) |row| {
            allocator.free(row);
        }
        allocator.free(self.mat);
    }

    pub fn getNode(self: AdjMat, x: usize) bool {
        return x < self.mat.len;
    }

    pub fn getOutEdges(self: AdjMat, x: usize) [] EdgeType {
        return self.mat[x];
    }

    pub fn getInEdges(self: AdjMat, allocator: *std.mem.Allocator, x: usize) []EdgeType {
        var edges = allocator.alloc(EdgeType, self.mat.len) catch {std.log.err("OOM",.{}); unreachable;};
        for (self.mat, 0..) |row, i| {
            edges[i] = row[x];
        }
        return edges;
    }

    pub fn adjacent(self: AdjMat, x: usize, y: usize) bool {
        return self.mat[x][y] != 0;
    }

    pub fn neighbors(self: AdjMat, allocator: *std.mem.Allocator, x: usize) ![]u32 {
        var vneighbors = try allocator.alloc(u32, self.mat.len);
        var count: usize = 0;
        for (self.mat[x], 0..) |edge_weight, i| {
            if (edge_weight != 0) {
                vneighbors[count] = @intCast(u32,i);
                count += 1;
            }
        }
        const result = try allocator.alloc(u32,count);
        std.mem.copy(u32,result,vneighbors[0..count]);
        allocator.free(vneighbors);
        return result;
    }

    pub fn addVertex(self: *AdjMat, allocator: *std.mem.Allocator) !void {
        const old_size = self.mat.len;
        const new_size = old_size + 1;

        self.mat = try allocator.realloc(self.mat,new_size);

        for (self.mat[0..old_size]) |*row| {
            row.* = try allocator.realloc(row.*,new_size);
            row.*[old_size] = 0;
        }

        self.mat[old_size] = try allocator.alloc(EdgeType,new_size);
        @memset(self.mat[old_size],0);
    }

    pub fn insertVertex(self: *AdjMat,x: usize, allocator: *std.mem.Allocator) !void {
        const old_size = self.mat.len;
        const new_size = old_size + 1;

        self.mat = try allocator.realloc(self.mat,new_size);
        for (self.mat[0..x]) |*row| {
            row.* = try allocator.realloc(row.*,new_size);
            row.*[old_size] = 0;
        }
        for (self.mat[x+1..old_size+1]) |*row| {
            row.* = try allocator.realloc(row.*,new_size);
            row.*[old_size] = 0;
            for (row[x+1..old_size+1]) |i| {
                row[i] = row[i-1];
            }
            row[x] = 0;
        }
        self.mat[x] = try allocator.alloc(EdgeType,new_size);
        @memset(self.mat[x],0);
    }

    pub fn removeVertex(self: *AdjMat, allocator: *std.mem.Allocator,x: usize) void {
        if(self.mat.len == 0) {
            std.log.debug("No vert to del", .{});
            return;
        }

        const old_size = self.mat.len;
        const new_size = old_size - 1;

        for (self.mat[0..x]) |*row| {
            std.mem.copy(EdgeType,row.*[x..],row.*[x + 1 ..]);
            row.* = allocator.realloc(row.*,new_size) catch { unreachable;};
        }

        for (self.mat[x + 1 ..]) |*row| {
            std.mem.copy(EdgeType,row.*[x..],row.*[x + 1 ..]);
            row.* = allocator.realloc(row.*,new_size) catch { unreachable;};
        }

        allocator.free(self.mat[x]);

        std.mem.copy([]EdgeType,self.mat[x..],self.mat[x + 1 ..]);

        self.mat = allocator.realloc(self.mat,new_size) catch { unreachable;};
    }
    pub fn swapVertices(self: *AdjMat,v1: usize,v2: usize) void {
        // Swap out edges
        var temp = self.mat[v1];
        self.mat[v1] = self.mat[v2];
        self.mat[v2] = temp;

        // Swap in edges
        for (self.mat, 0..) |_, i| {
            var temp2 = self.mat[i][v1];
            self.mat[i][v1] = self.mat[i][v2];
            self.mat[i][v2] = temp2;
        }
    }


    pub fn addEdge(self: *AdjMat,x: usize,y: usize,z: EdgeType) void {
        self.mat[x][y] = z;
    }

    pub fn removeEdge(self: *AdjMat,x: usize,y: usize) void {
        self.mat[x][y] = 0;
    }
};

pub fn main() !void {
    var galloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (galloc.deinit() == .leak) {
        std.debug.panic("GeneralPurposeAllocator had leaks!", .{});
    };
    var gallocator = galloc.allocator();
    var graph = try AdjMat.init(&gallocator, 3);
    defer graph.deinit(&gallocator);

    graph.addEdge(0, 1, 1);
    graph.addEdge(1, 2, 2);

    var v1hood = try graph.neighbors(&gallocator,0);
    defer gallocator.free(v1hood);
    std.debug.print("Neighbors of vertex 1: {any}\n", .{v1hood});



}
