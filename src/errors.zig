
// TODO: refactor

const SourceRef = @import("SourceRef.zig");
const Parser    = @import("Parser.zig");
const CodeGen   = @import("CodeGen.zig");

pub fn reportCodeGenError(err: CodeGen.Error, writer: anytype, source: []const u8) !void {

    switch (err) {
        .redeclaration => |e| {

            const ref = try SourceRef.new(
                source,
                e.begin,
                e.end,
            );

            try writer.print("Error on line {d}: ", .{ ref.line, });

            try writer.print("Redeclaration of variable {s}.\n",
                .{
                    source[e.begin..e.end],
                },
            );

            try writer.print("{s}\n", .{ ref.view, });
            for (0..ref.begin) |_| try writer.print(" ", .{});
            for (0..(ref.end - ref.begin)) |_| try writer.print("^", .{});
            try writer.print("\n", .{});
        },

        .undeclared_variable => |e| {

            const ref = try SourceRef.new(
                source,
                e.begin,
                e.end,
            );

            try writer.print("Error on line {d}: ", .{ ref.line, });

            try writer.print("Undeclared variable {s}.\n",
                .{
                    source[e.begin..e.end],
                },
            );

            try writer.print("{s}\n", .{ ref.view, });
            for (0..ref.begin) |_| try writer.print(" ", .{});
            for (0..(ref.end - ref.begin)) |_| try writer.print("^", .{});
            try writer.print("\n", .{});
        },
    }

}

pub fn reportParseError(err: Parser.Error, writer: anytype, source: []const u8) !void {

    const ref = try SourceRef.new(
        source,
        err.begin orelse source.len - 1,
        err.end   orelse source.len,
    );

    try writer.print("Error on line {d}: ", .{ ref.line, });

    switch (err.kind) {
        .expected_token => |e| {
            try writer.print("Expected {s} --- found {s}.\n",
                .{
                    @tagName(e.expected),
                    if (e.found) |found| @tagName(found) else "end of input",
                },
            );
        },
        .expected_token_range => |e| {
            try writer.print("Expected one of ", .{});
            for (e.expected) |expected| {
                try writer.print("{s}, ", .{ @tagName(expected), });
            }
            try writer.print("--- found {s}\n", .{
                if (e.found) |found| @tagName(found) else "end of input",
            });
        },
        .unexpected_eoi => {
            try writer.print("Unexpected end of input\n", .{});
        },
    }

    try writer.print("{s}\n", .{ ref.view, });
    for (0..ref.begin) |_| try writer.print(" ", .{});
    for (0..(ref.end - ref.begin)) |_| try writer.print("^", .{});
    try writer.print("\n", .{});
}
