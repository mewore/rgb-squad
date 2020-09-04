extends Node

signal player_damaged(old_hp, new_hp)

var LOG: Log = LogManager.get_log(self)

const FIRST_LEVEL: int = 1
var current_level: int = 0
var game_won: bool = false

onready var GAME_BEGIN_SCENE = "res://Game.tscn"
onready var GAME_LOST_SCENE = "res://Game.tscn"
onready var GAME_WON_SCENE = "res://Game.tscn"

# Player properties
const MAX_PLAYER_HP: int = 5
var player_hp: int = MAX_PLAYER_HP setget set_player_hp

func set_player_hp(new_player_hp: int) -> void:
    var old_player_hp: int = player_hp
    player_hp = new_player_hp
    if new_player_hp < old_player_hp:
        emit_signal("player_damaged", old_player_hp, new_player_hp)
    if new_player_hp <= 0:
        lose_game()

func _ready():
    LOG.info("Global :: ready")
    self.pause_mode = PAUSE_MODE_PROCESS

func start_game() -> void:
    reset()
    self.change_scene(GAME_BEGIN_SCENE)

func go_to_first_level() -> void:
    set_level(FIRST_LEVEL)

func win_game() -> void:
    LOG.info("[win state]")
    reset()
    change_scene(GAME_WON_SCENE)

func clear_level() -> void:
    LOG.info("[level win state]")
    if has_level(current_level + 1):
        set_level(current_level + 1)
    else:
        win_game()

func set_level(new_level: int) -> void:
    current_level = new_level
    change_scene(get_level_path(current_level))

func has_level(level: int) -> bool:
    return File.new().file_exists(get_level_path(level))

func get_level_path(level: int) -> String:
    return "res://levels/Level%d.tscn" % level

func lose_game() -> void:
    LOG.info("[lose state]")
    reset()
    change_scene(GAME_LOST_SCENE)

func reset() -> void:
    player_hp = MAX_PLAYER_HP

func change_scene(new_scene: String) -> void:
    var result: int = get_tree().change_scene(new_scene)
    get_tree().paused = false
    if result != OK:
        LOG.error("Error [%d] when loading scene %s" % [result, new_scene])

func _input(event: InputEvent):
    if event.is_action_pressed("pause"):
        LOG.info("Pause pressed")
        get_tree().paused = not get_tree().paused

func get_map() -> TileMap:
    var nodes: Array = get_tree().get_nodes_in_group("map")
    if nodes.size() > 1:
        LOG.warn("There is more than one map! Using the first one...")
    return nodes[0]

func get_player() -> Node2D:
    var nodes: Array = get_tree().get_nodes_in_group("player")
    if nodes.size() > 1:
        LOG.warn("There is more than one player! Using the first one...")
    return nodes[0]

func get_boss() -> Node2D:
    var nodes: Array = get_tree().get_nodes_in_group("boss")
    if nodes.size() > 1:
        LOG.warn("There is more than one boss! Using the first one...")
    return nodes[0]

func get_minion_contanier() -> Node2D:
    var nodes: Array = get_tree().get_nodes_in_group("minion_container")
    if nodes.size() > 1:
        LOG.warn("There is more than one minion container! Using the first one...")
    return nodes[0]

func get_bullet_container() -> Node2D:
    var nodes: Array = get_tree().get_nodes_in_group("bullet_container")
    if nodes.size() > 1:
        LOG.warn("There is more than one bullet container! Using the first one...")
    return nodes[0]
