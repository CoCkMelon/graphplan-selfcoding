const std = @import("std");

// Here are all variables to connect graph to function execution
// It is possible to create a type factory that is triggered by
// specific vertexes. It is also possible to do the same using
// graphplan, but that is more complex. Structs too, but they
// are longer to access from graph and longer to set new types.
pub const Settings = struct {
    // Usually
    const NodeTriggers = struct {
        nodenone = 0,
        ntype = 3,
        etype = 3,
        rawdatastart,
        nodegraphmetadatastart,
        nodegraphdatastart,
        nodeenum,
        nodeu32,
        nodeu64,
        nodef32,
        nodef64,
        nodechar,
        nodestring,  //
        nodeptrarr,
        nodemov,
        nodejmp,
        nodeje,
        nodejne,
        nodewhile,
        nodeif,
        nodeadd,
        nodesub,
        nodemul,
        nodediv,
        nodeidshifstart,
        nodeskip0,
        nodeskip1,
        nodeskip2,
        nodetype,  // To mark, that node has a type. Also it must have
                   // additional type data including edge count, TODO. Data can
                   // be used by operations by iterating ins and processing outs
                   // from 0.
        nodebit,  // This type has 1 bit of information stored in edge section
                  // as 0 or 1. Other types also store information in out edges.
        nodeopcode,  // This type that node has opcode type. Opcode contain code
                     // number, arguments with specific types. For example
                     // mov_u8 is 0, nodeu8, noderegisteru8.
        nodeu8,
        nodeu32,
        nodearray,
        nodef32,
        // pos type array [2] nodef32
    };
};
