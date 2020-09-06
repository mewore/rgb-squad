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
        first_room.make_door_to(second_room)
        
    current_room = room_matrix[0][0]

func move(delta_x: int, delta_y: int) -> void:
    assert(current_room.has_door(delta_x, delta_y))
    var new_x: int = current_room.position_x + delta_x
    var new_y: int = current_room.position_y + delta_y
    current_room = room_matrix[new_y][new_x]

func has_neighbour(delta_x: int, delta_y: int) -> bool:
    var new_x: int = current_room.position_x + delta_x
    var new_y: int = current_room.position_y + delta_y
    return new_x >= 0 and new_y >= 0 and new_x < width and new_y < height

func get_neighbour(delta_x: int, delta_y: int) -> RoomNode:
    return room_matrix[current_room.position_y + delta_y][current_room.position_x + delta_x]
