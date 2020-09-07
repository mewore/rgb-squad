extends Label

export(bool) var SHOW_SPECIFIC_COLOUR: bool = false
export(Types.RgbColour) var COLOUR: int = Types.RgbColour.RED

var LOG: Log = LogManager.get_log(self)

func _ready() -> void:
    update()
    LOG.check_error_code(Global.connect("player_damaged", self, "_on_player_damaged"),
        "Connecting the Global 'player_damaged' signal to '_on_player_damaged'")

func _on_player_damaged(_old_player_hp: int, _new_player_hp: int) -> void:
    update()

func update() -> void:
    var player_hp: int = Global.player_hp_per_colour[COLOUR] if SHOW_SPECIFIC_COLOUR \
        else Global.player_hp
    text = "HP: %d/%d" % [player_hp, Global.MAX_PLAYER_HP]
    if not SHOW_SPECIFIC_COLOUR:
        text = "Room distance: %d (%d%%)" % [Global.dungeon_layout.current_room.distance,
            round(Global.dungeon_layout.current_room.distance_ratio * 100)]
