extends EnemyState

onready var COOLDOWN: Timer = $Cooldown
onready var DURATION: Timer = $Duration
onready var RELOAD: Timer = $Reload

func enter() -> void:
    COOLDOWN.start()
    DURATION.start()

func exit() -> void:
    COOLDOWN.stop()
    DURATION.stop()
    RELOAD.stop()

func _on_Cooldown_timeout():
    enemy.shoot_at_player()

func _on_Duration_timeout():
    COOLDOWN.stop()
    RELOAD.start()

func _on_Reload_timeout():
    COOLDOWN.start()
    DURATION.start()
