// Zig is a general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software. [^1^][1]
// Graphplan is an algorithm for automated planning developed by Avrim Blum and Merrick Furst in 1995. Graphplan takes as input a planning problem expressed in STRIPS and produces, if one is possible, a sequence of operations for reaching a goal state. [^2^][4]

const std = @import("std");

// A planning problem consists of an initial state, a goal state, and a set of actions
const PlanningProblem = struct {
    init: []const bool, // an array of boolean values representing the initial state
    goal: []const bool, // an array of boolean values representing the goal state
    actions: []const Action, // an array of actions that can be applied to change the state
};

// An action consists of a name, a set of preconditions, and a set of effects
const Action = struct {
    name: []const u8, // a string representing the name of the action
    pre: []const bool, // an array of boolean values representing the preconditions of the action
    eff: []const bool, // an array of boolean values representing the effects of the action
};

// A planning graph consists of alternating levels of facts and actions
const PlanningGraph = struct {
    facts: [][]const bool, // an array of arrays of boolean values representing the facts at each level
    actions: [][]const Action, // an array of arrays of actions representing the actions at each level
    mutex: [][]const MutexPair, // an array of arrays of mutex pairs representing the mutually exclusive facts or actions at each level
};

// A mutex pair consists of two indices of facts or actions that are mutually exclusive
const MutexPair = struct {
    i: usize, // the index of the first fact or action
    j: usize, // the index of the second fact or action
};

// A plan consists of a sequence of actions that achieve the goal state from the initial state
const Plan = struct {
    actions: []const Action, // an array of actions representing the plan
};

// A function that creates a planning graph from a planning problem
fn createPlanningGraph(problem: PlanningProblem) PlanningGraph {
    var graph = PlanningGraph{
        .facts = &[_][]const bool{problem.init}, // initialize the first level with the initial state
        .actions = &[_][]const Action{}, // initialize an empty array for actions
        .mutex = &[_][]const MutexPair{}, // initialize an empty array for mutex pairs
    };

    var level = 0; // keep track of the current level

    while (true) {
        // extend the graph by adding a new level of actions and facts
        graph.extend(problem.actions);

        // check if the graph contains all the goal facts and they are not mutex
        if (graph.containsGoal(problem.goal) and !graph.isGoalMutex(problem.goal)) {
            break; // stop if a solution is possible at this level
        }

        // check if the graph has leveled off, meaning no new facts or mutexes are added
        if (graph.hasLeveledOff()) {
            break; // stop if no solution is possible at any level
        }

        level += 1; // increment the level
    }

    return graph; // return the planning graph
}

// A function that extends a planning graph by adding a new level of actions and facts
fn extend(graph: *PlanningGraph, actions: []const Action) void {
    var new_actions = std.ArrayList(Action).init(std.heap.page_allocator); // create a dynamic array for new actions
    var new_facts = std.ArrayList(bool).init(std.heap.page_allocator); // create a dynamic array for new facts

    for (actions) |action| {
        // check if the action is applicable at the current level, meaning its preconditions are satisfied and not mutex
        if (graph.isApplicable(action)) {
            try new_actions.append(action); // add the action to the new actions

            for (action.eff) |effect| {
                // check if the effect is already in the current facts or the new facts
                if (!graph.facts[graph.facts.len - 1][effect] and !new_facts[effect]) {
                    try new_facts.append(effect); // add the effect to the new facts
                }
            }
        }
    }

    // add the new actions and facts to the graph
    try graph.actions.append(new_actions.toOwnedSlice());
    try graph.facts.append(new_facts.toOwnedSlice());

    // compute the mutex pairs for the new actions and facts
    var new_mutex = std.ArrayList(MutexPair).init(std.heap.page_allocator); // create a dynamic array for new mutex pairs

    for (new_actions.toOwnedSlice()) |action1, i| {
        for (new_actions.toOwnedSlice()) |action2, j| {
            // check if the two actions are mutex, meaning they have inconsistent effects or interfere with each other
            if (graph.isMutex(action1, action2)) {
                try new_mutex.append(MutexPair{ .i = i, .j = j }); // add the pair to the new mutex pairs
            }
        }
    }

    // add the new mutex pairs to the graph
    try graph.mutex.append(new_mutex.toOwnedSlice());
}

pub fn main() !void{
    var galloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (galloc.deinit()) {
        debug.panic("GeneralPurposeAllocator had leaks!", .{});
    };
    const allocator = galloc.allocator();
    var prob = PlanningProblem{
        .init = galloc.allocator.alloc(bool,6),
    };
