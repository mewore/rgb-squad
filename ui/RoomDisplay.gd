extends Label

var LOG: Log = LogManager.get_log(self)

func _ready() -> void:
    update_label(Global.cleared_rooms, Global.DUNGEON_SIZE)
    LOG.check_error_code(Global.connect("room_cleared", self, "_on_room_cleared"),
        "Connecting the Global 'player_damaged' signal to '_on_player_damaged'")

func _on_room_cleared(cleared_rooms: int, total_rooms: int) -> void:
    update_label(cleared_rooms, total_rooms)

func update_label(cleared_rooms: int, total_rooms: int) -> void:
    text = "Cleared rooms: %d/%d" % [cleared_rooms, total_rooms]
