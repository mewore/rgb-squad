extends Node2D

func _ready() -> void:
    var room: PackedScene = load(Global.dungeon_layout.current_room.scene_path)
    add_child(room.instance())
