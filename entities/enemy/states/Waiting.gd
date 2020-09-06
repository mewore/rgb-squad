extends EnemyState

onready var WAITING_TIMER: Timer = $WaitingTime

func enter() -> void:
    WAITING_TIMER.start()
    yield(WAITING_TIMER, "timeout")
    self.set_next_state(EnemyState.SHOOTING)
