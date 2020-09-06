extends Label

func _ready() -> void:
    if Global.cleared_rooms > 0:
        self.text = "Cleared: %d / %d rooms" % [Global.cleared_rooms, Global.DUNGEON_SIZE]
    else:
        self.visible = false
