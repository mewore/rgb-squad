extends Node2D

var LOG: Log = LogManager.get_log(self)

onready var ENEMY_CONTAINER: Node = $Enemies
onready var enemies_left: int = ENEMY_CONTAINER.get_child_count()

onready var COMMON_MAP: TileMap = $CommonMap
onready var DOOR_TILES: PoolVector2Array = PoolVector2Array(
    COMMON_MAP.get_used_cells_by_id(COMMON_MAP.tile_set.find_tile_by_name("door")))

onready var PLAYER: Node2D = $Player
onready var MIN_PLAYER_POS: Vector2 = to_global($PlayerMin.position)
onready var MAX_PLAYER_POS: Vector2 = to_global($PlayerMax.position)

onready var ROOM_CENTER: Vector2 = $RoomCenter.position

var is_open: bool = false

func _ready() -> void:    
    # TODO: Replace this with actual doors instead of walls
    var wall_tile_id: int = COMMON_MAP.tile_set.find_tile_by_name("wall")
    for _tile in DOOR_TILES:
        var tile: Vector2 = _tile
        COMMON_MAP.set_cell(int(tile.x), int(tile.y), wall_tile_id)

    if Global.is_room_cleared():
        open_doors()
    elif enemies_left:
        LOG.info("Enemy count: %d" % [enemies_left])
        for _enemy in ENEMY_CONTAINER.get_children():
            LOG.info("Connecting enemy...")
            var enemy: Enemy = _enemy
            LOG.check_error_code(enemy.connect("dead", self, "_on_enemy_dead"),
                "Connecting an enemy's 'dead' signal to the room's '_on_enemy_dead' method")
        Global.do_room_countdown()
    else:
        open_doors()
        Global.clear_room()

func _process(_delta: float) -> void:
    if is_open:
        var player_pos: Vector2 = PLAYER.to_global(Vector2.ZERO)
        if player_pos.x < MIN_PLAYER_POS.x:
            Global.go_to_room(Vector2.LEFT)
        elif player_pos.y < MIN_PLAYER_POS.y:
            Global.go_to_room(Vector2.UP)
        if player_pos.x > MAX_PLAYER_POS.x:
            Global.go_to_room(Vector2.RIGHT)
        elif player_pos.y > MAX_PLAYER_POS.y:
            Global.go_to_room(Vector2.DOWN)

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

func open_doors() -> void:
    for _cell in DOOR_TILES:
        var cell: Vector2 = _cell
        var cell_position: Vector2 = COMMON_MAP.map_to_world(cell)
        var distance_from_center: Vector2 = cell_position - ROOM_CENTER
        var is_horizontal: bool = abs(distance_from_center.x) > abs(distance_from_center.y)
        var delta_x: int = int(sign(distance_from_center.x)) if is_horizontal else 0
        var delta_y: int = int(sign(distance_from_center.y)) if not is_horizontal else 0
        
        if Global.dungeon_layout.current_room.has_door(delta_x, delta_y):
            COMMON_MAP.set_cell(int(cell.x), int(cell.y), -1)
    is_open = true
