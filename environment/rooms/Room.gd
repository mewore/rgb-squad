extends Node2D

class_name Room

signal player_left(direction)

var LOG: Log = LogManager.get_log(self)

onready var ENEMY_CONTAINER: Node = $YSort/Enemies
onready var enemies_left: int = ENEMY_CONTAINER.get_child_count()

onready var COMMON_MAP: TileMap = $CommonMap
onready var DOOR_CELLS: PoolVector2Array = PoolVector2Array(
    COMMON_MAP.get_used_cells_by_id(COMMON_MAP.tile_set.find_tile_by_name("door")))

onready var PLAYER: Player = $YSort/Player
onready var MIN_PLAYER_POS: Vector2 = to_global($PlayerMin.position)
onready var MAX_PLAYER_POS: Vector2 = to_global($PlayerMax.position)

onready var ROOM_CENTER: Vector2 = $RoomCenter.position

var PRESENT_DOORS: Array = []
onready var DOOR_LEFT: Node2D = $DoorLeft
onready var DOOR_RIGHT: Node2D = $DoorRight
onready var DOOR_TOP: Node2D = $DoorTop
onready var DOOR_BOTTOM: Node2D = $DoorBottom
onready var DOOR_CLOSE_TIMER: Timer = $DoorClose

var is_open: bool = false

func _ready() -> void:    
    # TODO: Replace this with actual doors instead of walls
    var wall_tile_id: int = COMMON_MAP.tile_set.find_tile_by_name("wall")
    for _cell in DOOR_CELLS:
        var cell: Vector2 = _cell
        var cell_position: Vector2 = COMMON_MAP.map_to_world(cell)
        var distance_from_center: Vector2 = cell_position - ROOM_CENTER
        var is_horizontal: bool = abs(distance_from_center.x) > abs(distance_from_center.y)
        var delta_x: int = int(sign(distance_from_center.x)) if is_horizontal else 0
        var delta_y: int = int(sign(distance_from_center.y)) if not is_horizontal else 0
        
        if not Global.dungeon_layout.current_room.has_door(delta_x, delta_y):
            COMMON_MAP.set_cell(int(cell.x), int(cell.y), wall_tile_id)
    
    if Global.dungeon_layout.current_room.has_door(-1, 0):
        PRESENT_DOORS.append(DOOR_LEFT)
    else:
        DOOR_LEFT.queue_free()
    
    if Global.dungeon_layout.current_room.has_door(1, 0):
        PRESENT_DOORS.append(DOOR_RIGHT)
    else:
        DOOR_RIGHT.queue_free()
    
    if Global.dungeon_layout.current_room.has_door(0, -1):
        PRESENT_DOORS.append(DOOR_TOP)
    else:
        DOOR_TOP.queue_free()
        
    if Global.dungeon_layout.current_room.has_door(0, 1):
        PRESENT_DOORS.append(DOOR_BOTTOM)
    else:
        DOOR_BOTTOM.queue_free()

    if Global.is_room_cleared():
        open_doors()
    elif enemies_left:
        LOG.info("Enemy count: %d" % [enemies_left])
        for _enemy in ENEMY_CONTAINER.get_children():
            LOG.info("Connecting enemy...")
            var enemy: Enemy = _enemy
            LOG.check_error_code(enemy.connect("dead", self, "_on_enemy_dead"),
                "Connecting an enemy's 'dead' signal to the room's '_on_enemy_dead' method")
        
        for _door in PRESENT_DOORS:
            var door: Node2D = _door
            door.visible = false
        DOOR_CLOSE_TIMER.start()
    else:
        open_doors()
        Global.clear_room()

func _process(_delta: float) -> void:
    if is_open and PLAYER.is_active:
        var player_pos: Vector2 = PLAYER.to_global(Vector2.ZERO)
        if player_pos.x < MIN_PLAYER_POS.x:
            emit_signal("player_left", Vector2.LEFT)
        elif player_pos.y < MIN_PLAYER_POS.y:
            emit_signal("player_left", Vector2.UP)
        elif player_pos.x > MAX_PLAYER_POS.x:
            emit_signal("player_left", Vector2.RIGHT)
        elif player_pos.y > MAX_PLAYER_POS.y:
            emit_signal("player_left", Vector2.DOWN)

func _on_enemy_dead() -> void:
    enemies_left -= 1
    LOG.info("Enemy died. Enemies left: %d" % enemies_left)
    if enemies_left <= 0:
        destroy_bullets()
        open_doors()
        Global.clear_room()

func destroy_bullets() -> void:
    for _bullet in get_tree().get_nodes_in_group("enemy_bullets"):
        var bullet: Bullet = _bullet
        bullet.disappear()

func close_doors() -> void:
    for _door in PRESENT_DOORS:
        var door: Node2D = _door
        if door:
            door.visible = true

func open_doors() -> void:
    for _door in PRESENT_DOORS:
        var door: Node2D = _door
        door.queue_free()
    is_open = true

func _on_DoorClose_timeout():
    close_doors()
