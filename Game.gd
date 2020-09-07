extends Node2D

var LOG: Log = LogManager.get_log(self)
onready var ANIMATION_PLAYER: AnimationPlayer = $AnimationPlayer

onready var GAMEPLAY_CONTAINER: Node2D = $Gameplay

var leave_direction: Vector2

func _ready() -> void:
    var room_scene: PackedScene = load(Global.dungeon_layout.current_room.scene_path)
    var room: Room = room_scene.instance()
    GAMEPLAY_CONTAINER.add_child(room)
    LOG.check_error_code(Global.connect("player_damaged", self, "_on_player_damaged"),
        "Attaching the Global 'player_damaged' to '_on_player_damaged'")
    LOG.check_error_code(room.connect("player_left", self, "_on_player_left"))

func _on_player_left(direction: Vector2) -> void:
    leave_direction = direction
    leave_room()

func _on_player_damaged(_old_hp: int, _new_hp: int) -> void:
    ANIMATION_PLAYER.play("player_hurt")

func freeze() -> void:
    Global.frozen = true

func unfreeze() -> void:
    Global.frozen = false

func leave_room() -> void:
    Global.go_to_room(leave_direction)
