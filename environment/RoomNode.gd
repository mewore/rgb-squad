class_name RoomNode

signal cleared(room_node)

var parent: RoomNode
var tree_size: int = 1

var doors: Array = [false, false, false, false]

var position_x: int
var position_y: int

var cleared = false setget set_cleared

func _init(initial_position_x: int, initial_position_y: int) -> void:
    position_x = initial_position_x
    position_y = initial_position_y

func get_root() -> RoomNode:
    var result: RoomNode = self
    while result.parent:
        result = result.parent
    return result

func connect_to(other_room: RoomNode, force: bool = false) -> bool:
    var self_root: RoomNode = self.get_root()
    var other_root: RoomNode = other_room.get_root()
    if self_root != other_root:
        if self_root.tree_size < other_root.tree_size:
            self_root.parent = other_root
        else:
            other_root.parent = self_root
            if other_root.tree_size == self_root.tree_size:
                self_root.tree_size += 1
    elif not force:
        return false
    
    add_door(other_room)
    other_room.add_door(self)
    
    return true

func has_door(delta_x: int, delta_y: int) -> bool:
    return doors[delta_to_direction(delta_x, delta_y)]

func add_door(to_room: RoomNode) -> void:
    var delta_x: int = to_room.position_x - position_x
    var delta_y: int = to_room.position_y - position_y
    doors[delta_to_direction(delta_x, delta_y)] = true

func delta_to_direction(delta_x: int, delta_y: int) -> int:
    assert(abs(delta_x) + abs(delta_y) == 1)
    
    if delta_y == 0:
        return Types.Direction.RIGHT if delta_x == 1 else Types.Direction.LEFT
    else:
        return Types.Direction.DOWN if delta_y == 1 else Types.Direction.UP

func set_cleared(new_cleared: int) -> void:
    cleared = new_cleared
    emit_signal("cleared", self)
