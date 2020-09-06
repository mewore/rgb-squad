extends EnemyState

onready var DURATION: Timer = $Duration

func enter() -> void:
    enemy.start_shooting()
    DURATION.start()

func _on_Duration_timeout():
    enemy.reload()

func _on_Shooter_done_reloading():
    enemy.start_shooting()
    DURATION.start()
