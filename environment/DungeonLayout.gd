class_name DungeonLayout

var LOG: Log = LogManager.get_log(self)

const NONE: int = -1

var room_matrix: Array = []

var width: int
var height: int
var current_room: RoomNode

const ROOM_SCENE_DIRECTORY: String = "res://environment/rooms"
const STARTING_ROOM_SCENE: String = "StartingRoom.tscn"
const BASE_ROOM_SCENE: String = "Room.tscn"

func _init(init_width: int, init_height: int, additional_doors: float) -> void:
    width = init_width
    height = init_height
    
    var room_scenes: Array = []
    
    var directory: Directory = Directory.new()
    LOG.check_error_code(directory.open(ROOM_SCENE_DIRECTORY),
        "Opening '%s'" % ROOM_SCENE_DIRECTORY)
    LOG.check_error_code(directory.list_dir_begin(),
        "Listing the files in '%s'" % ROOM_SCENE_DIRECTORY)
    var file_name: String = directory.get_next()
    while file_name != "":
        if not directory.current_is_dir() and file_name.ends_with(".tscn") \
                and file_name != BASE_ROOM_SCENE and file_name.begins_with("Room"):
            room_scenes.append(ROOM_SCENE_DIRECTORY + "/" + file_name)
        file_name = directory.get_next()
    
    room_scenes.sort()
    
    var random: RandomNumberGenerator = RandomNumberGenerator.new()
    random.randomize()
    var starting_room_x = random.randi_range(0, width - 1)
    var starting_room_y = random.randi_range(0, height - 1)

    for i in range(height):
        var row: Array = []
        for j in range(width):
            var scene_path: String = ROOM_SCENE_DIRECTORY + "/" + STARTING_ROOM_SCENE \
                if (i == starting_room_y and j == starting_room_x) \
                else room_scenes[random.randi_range(0, room_scenes.size() - 1)]
            row.append(RoomNode.new(j, i, scene_path))
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
    
    current_room = room_matrix[starting_room_y][starting_room_x]
    var max_room_distance: int = bfs(current_room)
    for i in range(height):
        for j in range(width):
            var room: RoomNode = room_matrix[i][j]
            var distance: int = room.distance
            if distance > 0:
                room.distance_ratio = float(distance) / float(max_room_distance)
                var scene_index = int(floor(room.distance_ratio * room_scenes.size()))
                room_matrix[i][j].scene_path = room_scenes[scene_index]

func bfs(starting_node: RoomNode) -> int:
    var queue: Array = [starting_node]
    starting_node.distance = 0
    var max_distance: int = 0
    while !queue.empty():
        var next_queue: Array = []
        for _from_node in queue:
            var from_node: RoomNode = _from_node
            for _to_node in from_node.neighbours:
                var to_node: RoomNode = _to_node
                if to_node.distance > from_node.distance + 1:
                    to_node.distance = from_node.distance + 1
                    next_queue.append(to_node)
        queue = next_queue
        max_distance += 1
    return max_distance

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
