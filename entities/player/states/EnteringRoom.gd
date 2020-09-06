extends PlayerState

const DISTANCE: float = 100.0
var start_position: Vector2
var target_position: Vector2

onready var MOVING_TIMER: Timer = $MovingTime

func enter() -> void:
    player.moving = true
    var entering_vector: Vector2 = Vector2.RIGHT.rotated(player.shooting_angle)
    target_position = player.position
    start_position = target_position - entering_vector * DISTANCE
    MOVING_TIMER.start()
    yield(MOVING_TIMER, "timeout")
    if self.active:
        set_next_state(PlayerState.WAITING)

func process(_delta: float) -> void:
    var ratio = 1.0 - MOVING_TIMER.time_left / MOVING_TIMER.wait_time
    player.position = start_position.linear_interpolate(target_position, ratio)

func unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("set_red"):
        player.set_colour(Types.RgbColour.RED)
    elif event.is_action_pressed("set_green"):
        player.set_colour(Types.RgbColour.GREEN)
    elif event.is_action_pressed("set_blue"):
        player.set_colour(Types.RgbColour.BLUE)
