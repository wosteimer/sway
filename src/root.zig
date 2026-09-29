const std = @import("std");
const builtin = @import("builtin");

const CommandResult = struct {
    success: bool,
    parse_error: ?bool = null,
    @"error": ?[]u8 = null,
};

const SubscribeResult = struct {
    success: bool,
};

const Rect = struct {
    x: i64,
    y: i64,
    width: isize,
    height: isize,
};

const Workspace = struct {
    num: i32,
    name: []u8,
    visible: bool,
    focused: bool,
    urgent: bool,
    rect: Rect,
    output: []u8,
};

const Mode = struct {
    width: isize,
    height: isize,
    refresh: isize,
};

const Output = struct {
    name: []u8,
    make: []u8,
    model: []u8,
    serial: []u8,
    active: bool,
    dpms: bool,
    power: bool,
    primary: bool,
    scale: f32,
    subpixel_hinting: []u8,
    transform: []u8,
    current_workspace: ?[]u8,
    modes: []Mode,
    current_mode: Mode,
    rect: Rect,
};

const IdleInhibitor = struct {
    application: []u8,
    user: []u8,
};

const WindowProperties = struct {
    title: ?[]u8 = null,
    class: ?[]u8 = null,
    instance: ?[]u8 = null,
    window_role: ?[]u8 = null,
    window_type: ?[]u8 = null,
    transient_for: ?i32 = null,
};

const Node = struct {
    id: i32,
    name: ?[]u8 = null,
    type: []u8,
    border: []u8,
    current_border_width: i32,
    layout: []u8,
    orientation: []u8,
    percent: ?f32 = null,
    rect: Rect,
    window_rect: Rect,
    deco_rect: Rect,
    geometry: Rect,
    urgent: bool,
    sticky: bool,
    marks: [][]u8,
    focused: bool,
    focus: []i64,
    nodes: []Node,
    floating_nodes: []Node,
    representation: ?[]u8 = null,
    fullscreen_mode: ?i32 = null,
    floating: ?[]u8 = null,
    scratchpad_state: ?[]u8 = null,
    app_id: ?[]u8 = null,
    pid: ?i32 = null,
    foreign_toplevel_identifier: ?[]u8 = null,
    visible: ?bool = null,
    shell: ?[]u8 = null,
    inhibit_idle: ?bool = null,
    idle_inhibitors: ?IdleInhibitor = null,
    sandbox_engine: ?[]u8 = null,
    sandbox_app_id: ?[]u8 = null,
    sandbox_instance_id: ?[]u8 = null,
    window: ?i32 = null,
    window_properties: ?WindowProperties = null,
};

const Colors = struct {
    background: []u8,
    statusline: []u8,
    separator: []u8,
    focused_background: []u8,
    focused_statusline: []u8,
    focused_separator: []u8,
    focused_workspace_text: []u8,
    focused_workspace_bg: []u8,
    focused_workspace_border: []u8,
    active_workspace_text: []u8,
    active_workspace_bg: []u8,
    active_workspace_border: []u8,
    inactive_workspace_text: []u8,
    inactive_workspace_bg: []u8,
    inactive_workspace_border: []u8,
    urgent_workspace_text: []u8,
    urgent_workspace_bg: []u8,
    urgent_workspace_border: []u8,
    binding_mode_text: []u8,
    binding_mode_bg: []u8,
    binding_mode_border: []u8,
};

const Gaps = struct {
    top: i32,
    right: i32,
    bottom: i32,
    left: i32,
};

const BarConfig = struct {
    id: []u8,
    mode: []u8,
    position: []u8,
    status_command: ?[]u8,
    font: []u8,
    workspace_buttons: bool,
    workspace_min_width: i32,
    binding_mode_indicator: bool,
    verbose: bool,
    colors: Colors,
    gaps: Gaps,
    bar_height: i32,
    status_padding: i32,
    status_edge_padding: i32,
};

const Version = struct {
    major: i32,
    minor: i32,
    patch: i32,
    human_readable: []u8,
    loaded_config_file_name: []u8,
};

const GetConfigResult = struct {
    config: []u8,
};

const GetBarConfigResult = union(enum) {
    const Self = @This();

    ids: [][]u8,
    config: BarConfig,
    @"error": struct {
        success: bool,
        @"error": []u8,
    },

    pub fn jsonParse(
        allocator: std.mem.Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) std.json.ParseError(@TypeOf(source.*))!Self {
        const value = try std.json.innerParse(
            std.json.Value,
            allocator,
            source,
            options,
        );
        return Self.jsonParseFromValue(allocator, value, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        value: std.json.Value,
        options: std.json.ParseOptions,
    ) std.json.ParseFromValueError!Self {
        return blk: switch (value) {
            .array => Self{
                .ids = try std.json.parseFromValueLeaky(
                    [][]u8,
                    allocator,
                    value,
                    options,
                ),
            },
            .object => |obj| {
                if (obj.get("success") != null) {
                    break :blk Self{
                        .@"error" = try std.json.parseFromValueLeaky(
                            @FieldType(Self, "error"),
                            allocator,
                            value,
                            options,
                        ),
                    };
                }
                break :blk Self{
                    .config = try std.json.parseFromValueLeaky(
                        BarConfig,
                        allocator,
                        value,
                        options,
                    ),
                };
            },
            else => error.UnexpectedToken,
        };
    }
};

const SendTickResult = struct {
    success: bool,
};

const GetBindingStateResult = struct {
    name: []u8,
};

const LibInput = struct {
    send_events: ?[]u8 = null,
    tap: ?[]u8 = null,
    tap_button_map: ?[]u8 = null,
    tap_drag: ?[]u8 = null,
    tap_drag_lock: ?[]u8 = null,
    accel_speed: ?f64 = null,
    accel_profile: ?[]u8 = null,
    natural_scroll: ?[]u8 = null,
    left_handed: ?[]u8 = null,
    click_method: ?[]u8 = null,
    click_button_map: ?[]u8 = null,
    middle_emulation: ?[]u8 = null,
    scroll_method: ?[]u8 = null,
    scroll_button: ?i32 = null,
    scroll_button_lock: ?[]u8 = null,
    dwt: ?[]u8 = null,
    dwtp: ?[]u8 = null,
    calibration_matrix: ?[]f32 = null,
};

const Input = struct {
    identifier: []u8,
    name: []u8,
    vendor: i32,
    product: i32,
    type: []u8,
    xkb_active_layout_name: ?[]u8 = null,
    xkb_layout_names: ?[][]u8 = null,
    xkb_active_layout_index: ?i32 = null,
    scroll_factor: ?f32 = null,
    libinput: ?LibInput = null,
};

const Seat = struct {
    name: []u8,
    capabilities: i32,
    focus: i32,
    devices: []Input,
};

pub const WorkspaceEvent = struct {
    change: []u8,
    current: ?Node = null,
    old: ?Node = null,
};

pub const OutputEvent = struct {
    change: []u8,
};

pub const ModeEvent = struct {
    change: []u8,
    pango_markup: bool,
};

pub const WindowEvent = struct {
    change: []u8,
    container: Node,
};

pub const BindingEvent = struct {
    change: []u8,
    binding: struct {
        command: []u8,
        event_state_mask: [][]u8,
        input_code: i32,
        symbol: ?[]u8 = null,
        input_type: []u8,
    },
};

pub const ShutdownEvent = struct {
    change: []u8,
};

pub const TickEvent = struct {
    first: bool,
    payload: []u8,
};

pub const BarStateUpdateEvent = struct {
    id: []u8,
    visible_by_modifier: bool,
};

pub const InputEvent = struct {
    change: []u8,
    input: Input,
};

const MessageType = enum(i32) {
    run_command = 0,
    get_workspaces = 1,
    subscribe = 2,
    get_outputs = 3,
    get_tree = 4,
    get_marks = 5,
    get_bar_config = 6,
    get_version = 7,
    get_binding_modes = 8,
    get_config = 9,
    send_tick = 10,
    sync = 11,
    get_binding_state = 12,
    get_inputs = 100,
    get_seats = 101,
};

pub const EventTag = enum(u32) {
    workspace = 0x80000000,
    output = 0x80000001,
    mode = 0x80000002,
    window = 0x80000003,
    barconfig_update = 0x80000004,
    binding = 0x80000005,
    shutdown = 0x80000006,
    tick = 0x80000007,
    bar_state_update = 0x80000014,
    input = 0x80000015,
};

pub const Event = union(EventTag) {
    workspace: WorkspaceEvent,
    output: OutputEvent,
    mode: ModeEvent,
    window: WindowEvent,
    barconfig_update: BarConfig,
    binding: BindingEvent,
    shutdown: ShutdownEvent,
    tick: TickEvent,
    bar_state_update: BarStateUpdateEvent,
    input: InputEvent,
};

pub fn Result(T: type) type {
    return struct {
        arena: *std.heap.ArenaAllocator,
        value: T,

        pub fn deinit(self: Result(T)) void {
            const allocator = self.arena.child_allocator;
            self.arena.deinit();
            allocator.destroy(self.arena);
        }
    };
}

fn MockInput(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        expect_payload: ?[]const u8 = null,
        expect_message_type: MessageType,
        response: T,
    };
}

fn Mock(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        reader_buf: []u8,
        reader: std.Io.Reader,
        writer: std.Io.Writer.Allocating,
        expect_payload: ?[]const u8 = null,
        expect_message_type: MessageType,

        pub fn init(input: MockInput(T)) !Self {
            var self: Self = undefined;
            self.allocator = input.allocator;
            var json = std.Io.Writer.Allocating.init(input.allocator);
            defer json.deinit();
            try std.json.fmt(input.response, .{}).format(&json.writer);
            var accum = std.Io.Writer.Allocating.init(input.allocator);
            defer accum.deinit();
            _ = try accum.writer.write("i3-ipc");
            _ = try accum.writer.writeInt(i32, @intCast(json.written().len), builtin.cpu.arch.endian());
            _ = try accum.writer.writeInt(
                i32,
                @intFromEnum(input.expect_message_type),
                builtin.cpu.arch.endian(),
            );
            _ = try accum.writer.write(json.written());
            self.writer = std.Io.Writer.Allocating.init(input.allocator);
            self.reader_buf = try input.allocator.dupe(u8, accum.written());
            self.reader = .fixed(self.reader_buf);
            self.expect_message_type = input.expect_message_type;
            self.expect_payload = input.expect_payload;
            return self;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.reader_buf);
            self.writer.deinit();
        }

        pub fn validate(self: *Self) !void {
            var header = self.writer.written()[0..14];
            const magic_string = header[0..6];
            const message_type: MessageType = @enumFromInt(std.mem.bytesToValue(i32, header[10..14]));
            try std.testing.expectEqualStrings(
                "i3-ipc",
                magic_string,
            );
            try std.testing.expectEqual(
                self.expect_message_type,
                message_type,
            );
            if (self.expect_payload) |expect_payload| {
                const payload = self.writer.written()[14..];
                try std.testing.expectEqualStrings(
                    expect_payload,
                    payload,
                );
            }
        }
    };
}

fn ArrangeResult(comptime T: type) type {
    return struct {
        mock: *Mock(T),
        ipc: Sway,

        pub fn deinit(self: ArrangeResult(T)) void {
            self.mock.deinit();
            std.testing.allocator.destroy(self.mock);
        }
    };
}

fn arrange(
    comptime T: type,
    expect_message_type: MessageType,
    expect_payload: ?[]const u8,
    response: T,
) !ArrangeResult(T) {
    const mock = try std.testing.allocator.create(Mock(T));
    mock.* = try .init(.{
        .allocator = std.testing.allocator,
        .expect_message_type = expect_message_type,
        .expect_payload = expect_payload,
        .response = response,
    });
    return .{
        .ipc = .{ .in = &mock.reader, .out = &mock.writer.writer },
        .mock = mock,
    };
}

pub const Sway = @This();

in: *std.Io.Reader,
out: *std.Io.Writer,

pub fn init(in: *std.Io.Reader, out: *std.Io.Writer) Sway {
    return .{ .in = in, .out = out };
}

pub fn runCommand(self: *const Sway, allocator: std.mem.Allocator, command: []const u8) !Result([]CommandResult) {
    return try self.sendMessage([]CommandResult, allocator, .run_command, command);
}

test "runCommand" {
    // Arrange
    const payload = "workspace number 2";
    var response = [_]CommandResult{.{ .success = true }};
    const arrange_result = try arrange([]CommandResult, .run_command, payload, &response);
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };

    // Act
    const result = try ipc.runCommand(std.testing.allocator, payload);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualSlices(CommandResult, result.value, &response);
}

pub const EventHandler = struct {
    arena: *std.heap.ArenaAllocator,
    in: *std.Io.Reader,
    out: *std.Io.Writer,

    pub fn deinit(self: *const EventHandler) void {
        const allocator = self.arena.child_allocator;
        self.arena.deinit();
        allocator.destroy(self.arena);
    }

    pub fn next(self: *const EventHandler) !?Event {
        _ = self.arena.reset(.retain_capacity);
        const allocator = self.arena.allocator();
        var header: [14]u8 = undefined;
        self.in.readSliceAll(&header) catch |err| {
            switch (err) {
                error.EndOfStream => return null,
                else => return err,
            }
        };
        const len: i32, const event_tag: EventTag = .{
            std.mem.bytesToValue(i32, header[6..10]),
            @enumFromInt(std.mem.bytesToValue(u32, header[10..])),
        };
        const buf = try allocator.alloc(u8, @intCast(len));
        self.in.readSliceAll(buf) catch |err| {
            switch (err) {
                error.EndOfStream => return null,
                else => return err,
            }
        };
        return switch (event_tag) {
            .workspace => .{ .workspace = try std.json.parseFromSliceLeaky(
                @FieldType(Event, "workspace"),
                allocator,
                buf,
                .{ .ignore_unknown_fields = true },
            ) },
            .output => .{ .output = try std.json.parseFromSliceLeaky(
                @FieldType(Event, "output"),
                allocator,
                buf,
                .{ .ignore_unknown_fields = true },
            ) },
            .mode => .{ .mode = try std.json.parseFromSliceLeaky(
                @FieldType(Event, "mode"),
                allocator,
                buf,
                .{ .ignore_unknown_fields = true },
            ) },
            .window => .{ .window = try std.json.parseFromSliceLeaky(
                @FieldType(Event, "window"),
                allocator,
                buf,
                .{ .ignore_unknown_fields = true },
            ) },
            .barconfig_update => .{ .barconfig_update = try std.json.parseFromSliceLeaky(
                @FieldType(Event, "barconfig_update"),
                allocator,
                buf,
                .{ .ignore_unknown_fields = true },
            ) },
            .binding => .{ .binding = try std.json.parseFromSliceLeaky(
                @FieldType(Event, "binding"),
                allocator,
                buf,
                .{ .ignore_unknown_fields = true },
            ) },
            .shutdown => .{ .shutdown = try std.json.parseFromSliceLeaky(
                @FieldType(Event, "shutdown"),
                allocator,
                buf,
                .{ .ignore_unknown_fields = true },
            ) },
            .tick => .{ .tick = try std.json.parseFromSliceLeaky(
                @FieldType(Event, "tick"),
                allocator,
                buf,
                .{ .ignore_unknown_fields = true },
            ) },
            .bar_state_update => .{ .bar_state_update = try std.json.parseFromSliceLeaky(
                @FieldType(Event, "bar_state_update"),
                allocator,
                buf,
                .{ .ignore_unknown_fields = true },
            ) },
            .input => .{ .input = try std.json.parseFromSliceLeaky(
                @FieldType(Event, "input"),
                allocator,
                buf,
                .{ .ignore_unknown_fields = true },
            ) },
        };
    }
};

pub fn subscribe(self: *const Sway, allocator: std.mem.Allocator, events: []const EventTag) !EventHandler {
    const arena = try allocator.create(std.heap.ArenaAllocator);
    arena.* = .init(allocator);
    errdefer {
        arena.deinit();
        allocator.destroy(arena);
    }
    var fmt = std.json.fmt(events, .{});
    var allocating = std.Io.Writer.Allocating.init(arena.allocator());
    try fmt.format(&allocating.writer);
    try send(self.out, .subscribe, allocating.written());
    const result = try getReply(SubscribeResult, arena.allocator(), self.in);
    if (result.success) {
        return EventHandler{ .arena = arena, .in = self.in, .out = self.out };
    }
    return error.NotSubscribed;
}

// TODO: test subscribe

pub fn getWorkspaces(self: *const Sway, allocator: std.mem.Allocator) !Result([]Workspace) {
    return try self.sendMessage([]Workspace, allocator, .get_workspaces, null);
}

test "getWorkspaces" {
    // Arrange
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();
    var response = [_]Workspace{.{
        .num = 1,
        .name = try allocator.dupe(u8, "1"),
        .visible = true,
        .focused = true,
        .urgent = false,
        .rect = .{
            .x = 0,
            .y = 23,
            .width = 1920,
            .height = 1057,
        },
        .output = try allocator.dupe(u8, "eDP-1"),
    }};
    const arrange_result = try arrange([]Workspace, .get_workspaces, null, &response);
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };

    // Act
    const result = try ipc.getWorkspaces(std.testing.allocator);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualDeep(&response, result.value);
}

pub fn getOutputs(self: *const Sway, allocator: std.mem.Allocator) !Result([]Output) {
    return try self.sendMessage([]Output, allocator, .get_outputs, null);
}

test "getOutputs" {
    // Arrange
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();
    var response = [_]Output{
        .{
            .name = try allocator.dupe(u8, "HDMI-A-2"),
            .make = try allocator.dupe(u8, "Unknown"),
            .model = try allocator.dupe(u8, "NS-19E310A13"),
            .serial = try allocator.dupe(u8, "0x00000001"),
            .active = true,
            .dpms = true,
            .power = true,
            .primary = false,
            .scale = 1.0,
            .subpixel_hinting = try allocator.dupe(u8, "rgb"),
            .transform = try allocator.dupe(u8, "normal"),
            .current_workspace = try allocator.dupe(u8, "1"),
            .modes = try allocator.dupe(Mode, &[_]Mode{
                .{ .width = 640, .height = 480, .refresh = 59940 },
                .{ .width = 800, .height = 600, .refresh = 60317 },
                .{ .width = 1024, .height = 768, .refresh = 60004 },
                .{ .width = 1920, .height = 1080, .refresh = 60000 },
            }),
            .current_mode = .{ .width = 1920, .height = 1080, .refresh = 60000 },
            .rect = .{
                .x = 0,
                .y = 0,
                .width = 1920,
                .height = 1080,
            },
        },
    };
    const arrange_result = try arrange([]Output, .get_outputs, null, &response);
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };
    // Act
    const result = try ipc.getOutputs(std.testing.allocator);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualDeep(&response, result.value);
}

pub fn getTree(self: *const Sway, allocator: std.mem.Allocator) !Result(Node) {
    return self.sendMessage(Node, allocator, .get_tree, null);
}

// TODO: test getTree

pub fn getMarks(self: *const Sway, allocator: std.mem.Allocator) !Result([][]u8) {
    return try self.sendMessage([][]u8, allocator, .get_marks, null);
}

test "getMarks" {
    // Arrange
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();
    var response = [_][]u8{
        try allocator.dupe(u8, "one"),
        try allocator.dupe(u8, "test"),
    };
    const arrange_result = try arrange([][]u8, .get_marks, null, &response);
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };

    // Act
    const result = try ipc.getMarks(std.testing.allocator);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualDeep(&response, result.value);
}

pub fn getBarConfig(self: *const Sway, allocator: std.mem.Allocator, bar_id: ?[]const u8) !Result(GetBarConfigResult) {
    return try self.sendMessage(GetBarConfigResult, allocator, .get_bar_config, bar_id);
}

test "getBarConfig - without a payload" {
    // Arrange
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();
    var response = [_][]u8{
        try allocator.dupe(u8, "bar-0"),
        try allocator.dupe(u8, "bar-1"),
    };
    const arrange_result = try arrange(
        [][]u8,
        .get_bar_config,
        null,
        &response,
    );
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };

    // Act
    const result = try ipc.getBarConfig(std.testing.allocator, null);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualDeep(&response, result.value.ids);
}

// TODO: test getBarConfig with a payload

pub fn getVersion(self: *const Sway, allocator: std.mem.Allocator) !Result(Version) {
    return try self.sendMessage(Version, allocator, .get_version, null);
}

test "getVersion" {
    // Arrange
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();
    const response = Version{
        .major = 1,
        .minor = 0,
        .patch = 0,
        .human_readable = try allocator.dupe(
            u8,
            "1.0-rc1-117-g2f7247e0 (Feb 24 2019, branch 'master')",
        ),
        .loaded_config_file_name = try allocator.dupe(
            u8,
            "/home/redsoxfan/.config/sway/config",
        ),
    };
    const arrange_result = try arrange(
        Version,
        .get_version,
        null,
        response,
    );
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };

    // Act
    const result = try ipc.getVersion(std.testing.allocator);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualDeep(response, result.value);
}

pub fn getBindingModes(self: *const Sway, allocator: std.mem.Allocator) !Result([][]u8) {
    return try self.sendMessage([][]u8, allocator, .get_binding_modes, null);
}

test "getBindingModes" {
    // Arrange
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();
    var response = [_][]u8{
        try allocator.dupe(u8, "default"),
        try allocator.dupe(u8, "resize"),
    };
    const arrange_result = try arrange(
        [][]u8,
        .get_binding_modes,
        null,
        &response,
    );
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };

    // Act
    const result = try ipc.getBindingModes(std.testing.allocator);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualDeep(&response, result.value);
}

pub fn getConfig(self: *const Sway, allocator: std.mem.Allocator) !Result(GetConfigResult) {
    return try self.sendMessage(GetConfigResult, allocator, .get_config, null);
}

test "getConfig" {
    // Arrange
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();
    const response = GetConfigResult{
        .config = try allocator.dupe(u8, "set $mod Mod4\nbindsym $mod+q exit\n"),
    };
    const arrange_result = try arrange(
        GetConfigResult,
        .get_config,
        null,
        response,
    );
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };

    // Act
    const result = try ipc.getConfig(allocator);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualDeep(response, result.value);
}

pub fn sendTick(self: *const Sway, allocator: std.mem.Allocator, payload: ?[]const u8) !Result(SendTickResult) {
    return try self.sendMessage(SendTickResult, allocator, .send_tick, payload);
}

test "sendTick - with payload" {
    // Arrange
    const payload = "hello world";
    const response = SendTickResult{
        .success = true,
    };
    const arrange_result = try arrange(
        SendTickResult,
        .send_tick,
        payload,
        response,
    );
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };
    //
    // Act
    const result = try ipc.sendTick(std.testing.allocator, payload);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqual(response, result.value);
}

// TODO: test sendTick - without payload

pub fn getBindingState(self: *const Sway, allocator: std.mem.Allocator) !Result(GetBindingStateResult) {
    return try self.sendMessage(GetBindingStateResult, allocator, .get_binding_state, null);
}

test "getBindingState" {
    // Arrange
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();
    const response = GetBindingStateResult{
        .name = try allocator.dupe(u8, "default"),
    };
    const arrange_result = try arrange(
        GetBindingStateResult,
        .get_binding_state,
        null,
        response,
    );
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };

    // Act
    const result = try ipc.getBindingState(allocator);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualDeep(response, result.value);
}

pub fn getInputs(self: *const Sway, allocator: std.mem.Allocator) !Result([]Input) {
    return try self.sendMessage([]Input, allocator, .get_inputs, null);
}

test "getInputs" {
    // Arrange
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();
    var response = [_]Input{
        .{
            .identifier = try allocator.dupe(
                u8,
                "3034:22494:USB2.0_VGA_UVC_WebCam:_USB2.0_V",
            ),
            .name = try allocator.dupe(u8, "USB2.0 VGA UVC WebCam: USB2.0 V"),
            .vendor = 3034,
            .product = 22494,
            .type = try allocator.dupe(u8, "keyboard"),
            .xkb_active_layout_name = try allocator.dupe(u8, "English (US)"),
            .libinput = .{
                .send_events = try allocator.dupe(u8, "enabled"),
            },
        },
    };
    const arrange_result = try arrange(
        []Input,
        .get_inputs,
        null,
        &response,
    );
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };

    // Act
    const result = try ipc.getInputs(std.testing.allocator);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualDeep(&response, result.value);
}

pub fn getSeats(self: *const Sway, allocator: std.mem.Allocator) !Result([]Seat) {
    return try self.sendMessage([]Seat, allocator, .get_seats, null);
}

test "getSeats" {
    // Arrange
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();
    var response = [_]Seat{
        .{
            .name = try allocator.dupe(u8, "seat0"),
            .capabilities = 3,
            .focus = 7,
            .devices = try allocator.dupe(Input, &[_]Input{
                .{
                    .identifier = try allocator.dupe(
                        u8,
                        "3034:22494:USB2.0_VGA_UVC_WebCam:_USB2.0_V",
                    ),
                    .name = try allocator.dupe(u8, "USB2.0 VGA UVC WebCam: USB2.0 V"),
                    .vendor = 3034,
                    .product = 22494,
                    .type = try allocator.dupe(u8, "keyboard"),
                    .xkb_active_layout_name = try allocator.dupe(u8, "English (US)"),
                    .libinput = .{
                        .send_events = try allocator.dupe(u8, "enabled"),
                    },
                },
            }),
        },
    };
    const arrange_result = try arrange(
        []Seat,
        .get_seats,
        null,
        &response,
    );
    defer arrange_result.deinit();
    const mock, const ipc = .{ arrange_result.mock, arrange_result.ipc };

    // Act
    const result = try ipc.getSeats(std.testing.allocator);
    defer result.deinit();

    // Assert
    try mock.validate();
    try std.testing.expectEqualDeep(&response, result.value);
}

fn sendMessage(
    self: *const Sway,
    comptime T: type,
    allocator: std.mem.Allocator,
    msg_type: MessageType,
    payload: ?[]const u8,
) !Result(T) {
    const arena = try allocator.create(std.heap.ArenaAllocator);
    arena.* = .init(allocator);
    try send(self.out, msg_type, payload);
    return .{
        .arena = arena,
        .value = try getReply(T, arena.allocator(), self.in),
    };
}

// NOTE: The sway header is 14 bytes long and is separated into three
//       parts:
//          <magic-string><payload-length><message-type>
//       where:
//           magic-string = i3-ipc
//           payload-length = 32-bit integer
//           payload-type = 32-bit integer

fn send(writer: *std.Io.Writer, msg_type: MessageType, payload: ?[]const u8) !void {
    var len: i32 = 0;
    if (payload) |p| {
        len = @intCast(p.len);
    }
    _ = try writer.write("i3-ipc");
    try writer.writeInt(i32, len, builtin.target.cpu.arch.endian());
    try writer.writeInt(i32, @intFromEnum(msg_type), builtin.target.cpu.arch.endian());
    if (payload) |p| {
        _ = try writer.write(p);
    }
    try writer.flush();
}

test "send" {
    var writer = std.Io.Writer.Allocating.init(std.testing.allocator);
    defer writer.deinit();

    const input = "command";
    try send(&writer.writer, .run_command, input);
    try std.testing.expectEqualStrings(writer.written()[0..6], "i3-ipc");
    try std.testing.expectEqual(
        @as(i32, @intCast(input.len)),
        std.mem.bytesToValue(i32, writer.written()[6..10]),
    );
    try std.testing.expectEqual(
        @intFromEnum(MessageType.run_command),
        std.mem.bytesToValue(i32, writer.written()[10..14]),
    );
    try std.testing.expectEqualStrings(input, writer.written()[14..]);
}

fn getReply(comptime T: type, allocator: std.mem.Allocator, reader: *std.Io.Reader) !T {
    var header: [14]u8 = undefined;
    try reader.readSliceAll(&header);
    if (!std.mem.eql(u8, "i3-ipc", header[0..6])) {
        return error.InvalidResponse;
    }
    const buffer_len = @max(std.mem.bytesToValue(i32, header[6..10]), 0);
    const buffer = try allocator.alloc(u8, @intCast(buffer_len));
    _ = try reader.readSliceAll(buffer);
    return try std.json.parseFromSliceLeaky(
        T,
        allocator,
        buffer,
        .{ .ignore_unknown_fields = true },
    );
}

test "getReply" {
    const payload = "[\"payload\"]";
    var tmp = std.Io.Writer.Allocating.init(std.testing.allocator);
    defer tmp.deinit();
    var writer = &tmp.writer;
    _ = try writer.write("i3-ipc");
    try writer.writeInt(i32, @intCast(payload.len), builtin.cpu.arch.endian());
    try writer.writeInt(i32, @intFromEnum(MessageType.run_command), builtin.cpu.arch.endian());
    _ = try writer.write(payload);
    const buf = tmp.written();
    var reader = std.Io.Reader.fixed(buf);
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const result = try getReply([][]const u8, arena.allocator(), &reader);
    try std.testing.expectEqualStrings("payload", result[0]);
}
