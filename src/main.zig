const std = @import("std");

pub fn main() !void {

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!

    // Загрузить граф

    // Исполнить план парсинга метаданных
        // Например тип, версия, хеш, дата изменения, а размер и тип константы для версии
        // а затем индексы в файле остальных данных у графов
    // Исполнить план парсинга реализаций графов процессов
        // Например задать среди состояний процессора настоящее,
        // в котором есть система, сравнивающая что к чему приведёт и
        // исполняющая то, что позднее всего приведёт к циклу.
        //
        // Можно подумать, что оценить, не перебирая все варианты
        // можно, если перебирать множества вариантов, а затем
        // получать элементы нужного множества. Это иерархический поиск пути?
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
