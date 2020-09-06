extends Control

export(PackedScene) var MINIMAP_ROOM_SCENE: PackedScene

export(int) var WIDTH: int = 3
export(int) var HEIGHT: int = 3

export(Vector2) var ROOM_PADDING = Vector2.ONE * 4
export(Vector2) var ROOM_MARGIN = Vector2.ONE * 4
export(Vector2) var ROOM_SIZE = Vector2.ONE * 16

var current_room_display: Node2D

func _ready():
    assert(WIDTH % 2 == 1)
    assert(HEIGHT % 2 == 1)
    var center_x = WIDTH / 2
    var center_y = WIDTH / 2
    for x in range(WIDTH):
        for y in range(HEIGHT):
            var dx: int = x - center_x
            var dy: int = y - center_y
            if Global.dungeon_layout.has_neighbour(dx, dy):
                make_room_display(x, y, dx, dy)
                

func make_room_display(x: int, y: int, dx: int, dy: int) -> void:
    var room_node: RoomNode = Global.dungeon_layout.get_neighbour(dx, dy)
    var room_display: MinimapRoom = MINIMAP_ROOM_SCENE.instance()
    
    room_display.position = Vector2(
        ROOM_PADDING.x + (ROOM_MARGIN.x + ROOM_SIZE.x) * x,
        ROOM_PADDING.y + (ROOM_MARGIN.y + ROOM_SIZE.y) * y)
    
    var is_current: bool = not dx and not dy
    room_display.set_colour(room_node, is_current)
    if room_node.cleared or is_current:
        room_display.add_connections(room_node)
    
    add_child(room_display)
