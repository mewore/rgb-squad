class_name DungeonLayout

const NONE: int = -1

var room_matrix: Array = []

var width: int
var height: int
var current_room: RoomNode

func _init(init_width: int, init_height: int, additional_doors: float) -> void:
    width = init_width
    height = init_height

    for i in range(height):
        var row: Array = []
        for j in range(width):
            row.append(RoomNode.new(j, i))
        room_matrix.append(row)
    
    var potential_doors: Array = []
    for i in range(height):
        for j in range(width):
            if i > 0:
                potential_doors.append([[i - 1, j], [i, j]])
            if j > 0:
                potential_doors.append([[i, j - 1], [i, j]])
    potential_doors.shuffle()
    
    var skipped_doors: Array = []
    for door in potential_doors:
        var first_room: RoomNode = room_matrix[door[0][0]][door[0][1]]
        var second_room: RoomNode = room_matrix[door[1][0]][door[1][1]]
        if not first_room.connect_to(second_room):
            skipped_doors.append(door)
    var skipped_doors_to_add: int = int(round(skipped_doors.size() * additional_doors))
    for i in range(skipped_doors_to_add):
        var door: Array = skipped_doors[i]
        var first_room: RoomNode = room_matrix[door[0][0]][door[0][1]]
        var second_room: RoomNode = room_matrix[door[1][0]][door[1][1]]
        first_room.connect_to(second_room, true)
        
    current_room = room_matrix[0][0]

func move(delta_x: int, delta_y: int) -> void:
    assert(current_room.has_door(delta_x, delta_y))
    var new_x: int = current_room.position_x + delta_x
    var new_y: int = current_room.position_y + delta_y
    current_room = room_matrix[new_y][new_x]


class RoomNode:
    var LOG: Log = LogManager.get_log(self)

    var parent: RoomNode
    var tree_size: int = 1
    
    var doors: Array = [false, false, false, false]
    
    var position_x: int
    var position_y: int
    
    var cleared = false
    
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
