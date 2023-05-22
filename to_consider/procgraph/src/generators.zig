const std = @import("std");
const pgr = @import("adjgrapg.zig");

// It is better to create interfaces that are
// simular to hardware interfaces, for simplicity,
// reusing exising, and performance reasons.
//


// Number
pub const Number = struct {
    graph: pgr.ProcGraph,
    start: u8,
    end: u8,
};

// Access to array
// Use cases:
// - access to graph implementation
// - access to program memory
// - make storage smaller when graph is not optimized yet


// Access file as array of u8 numbers
pub const FileMap = struct {
    graph: pgr.ProcGraph,
    start: u8,
    end: u8, // May be changed when file resized
    file: std.fs.File,
    // We could get file data in different formats.
    // We don't needed raw graph format, for that
    // other function would be better.
    // Bool array could be one of the simplest format.
    // Struct, multimedia, can be useful too.
    // All of these formats must be
    // described in graph for that first.
    fn getNode(nid: u8) u8{
    }
};
