extends CanvasLayer

var LOG: Log = LogManager.get_log(self)
onready var ANIMATION_PLAYER: AnimationPlayer = $AnimationPlayer

func _ready():
    LOG.check_error_code(Global.connect("paused", self, "_on_Global_paused"))
    LOG.check_error_code(Global.connect("unpaused", self, "_on_Global_unpaused"))

func _on_Global_paused() -> void:
    ANIMATION_PLAYER.play("pause_appear")

func _on_Global_unpaused() -> void:
    ANIMATION_PLAYER.play("pause_disappear")
