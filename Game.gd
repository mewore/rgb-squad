extends Node2D

var LOG: Log = LogManager.get_log(self)
onready var ANIMATION_PLAYER: AnimationPlayer = $AnimationPlayer

onready var GAMEPLAY_CONTAINER: Node2D = $Gameplay

func _ready() -> void:
    var room: PackedScene = load(Global.dungeon_layout.current_room.scene_path)
    GAMEPLAY_CONTAINER.add_child(room.instance())
    LOG.check_error_code(Global.connect("player_damaged", self, "_on_player_damaged"),
        "Attaching the Global 'player_damaged' to '_on_player_damaged'")

func _on_player_damaged(_old_hp: int, _new_hp: int) -> void:
    ANIMATION_PLAYER.play("player_hurt")

func freeze() -> void:
    Global.frozen = true

func unfreeze() -> void:
    Global.frozen = false
