const std = @import("std");


// // Could have done this.
// const ImplType = enum {
//     StaticAdjmap,
//     AllocAdjmap,
//     AllocCSR,
// };
// const impl_type: comptime ImplType = ImplType.StaticAdjmap;
// switch(impl_type) {

// Chosen to implement separately for shorter code in each struct.
pub const TypedGraphStaticAdjMat = struct {
    comptime graph_len: u8 = 8,
};

pub const TypedGraphAllocAdjmap = struct {
    comptime allocator = std.heap.page_allocator,
    comptime EType = u16,
    matrix: [][]EType,

};
pub const TypedGraphAllocCSR = struct {
};
