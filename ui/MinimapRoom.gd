extends Polygon2D

class_name MinimapRoom

onready var DOOR_LEFT: Node2D = $Doors/Left
onready var DOOR_RIGHT: Node2D = $Doors/Right
onready var DOOR_UP: Node2D = $Doors/Up
onready var DOOR_DOWN: Node2D = $Doors/Down

export(Color) var DEFAULT_ROOM_COLOUR: Color = Color.gray
export(Color) var CLEARED_ROOM_COLOUR: Color = Color.aquamarine
export(Color) var ENEMY_ROOM_COLOUR: Color = Color.indianred

func _ready() -> void:
    DOOR_LEFT.visible = false
    DOOR_RIGHT.visible = false
    DOOR_UP.visible = false
    DOOR_DOWN.visible = false

func set_colour(room_node: RoomNode, is_current: bool) -> void:
    if room_node.cleared:
        self_modulate = CLEARED_ROOM_COLOUR
    elif is_current:
        self_modulate = ENEMY_ROOM_COLOUR
        yield(room_node, "cleared")
        self_modulate = CLEARED_ROOM_COLOUR
    else:
        self_modulate = DEFAULT_ROOM_COLOUR

func add_connections(room_node: RoomNode) -> void:
    if not DOOR_LEFT:
        yield(self, "ready")
    DOOR_LEFT.visible = room_node.has_door(-1, 0)
    DOOR_RIGHT.visible = room_node.has_door(1, 0)
    DOOR_UP.visible = room_node.has_door(0, -1)
    DOOR_DOWN.visible = room_node.has_door(0, 1)
