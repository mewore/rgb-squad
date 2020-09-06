extends PlayerState

const DISTANCE: float = 50.0
var start_position: Vector2
var target_position: Vector2

onready var IDLE_TIMER: Timer = $IdleTime

func enter() -> void:
    player.is_active = false
    player.moving = false
    IDLE_TIMER.start()
    yield(IDLE_TIMER, "timeout")
    set_next_state(PlayerState.MOVING)

func unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("set_red"):
        player.set_colour(Types.RgbColour.RED)
    elif event.is_action_pressed("set_green"):
        player.set_colour(Types.RgbColour.GREEN)
    elif event.is_action_pressed("set_blue"):
        player.set_colour(Types.RgbColour.BLUE)
