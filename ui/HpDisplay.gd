extends Label

var LOG: Log = LogManager.get_log(self)

func _ready() -> void:
    update()
    LOG.check_error_code(Global.connect("player_damaged", self, "_on_player_damaged"),
        "Connecting the Global 'player_damaged' signal to '_on_player_damaged'")

func _on_player_damaged(old_player_hp: int, new_player_hp: int) -> void:
    update()

func update() -> void:
    text = "HP: %d/%d" % [Global.player_hp, Global.MAX_PLAYER_HP]
