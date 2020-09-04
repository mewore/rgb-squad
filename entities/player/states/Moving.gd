extends PlayerState

export(float) var MAX_SPEED: float = 120.0
export(float) var FULL_ACCELERATION_TIME: float = 0.06
var ACCELERATION: float = MAX_SPEED / FULL_ACCELERATION_TIME
var motion: Vector2 = Vector2.ZERO

func physics_process(delta: float) -> void:
    var input_x: int = (1 if Input.is_action_pressed("move_right") else 0) - (1 if Input.is_action_pressed("move_left") else 0)
    var input_y: int = (1 if Input.is_action_pressed("move_down") else 0) - (1 if Input.is_action_pressed("move_up") else 0)
    # Not normalizing the target speed vector on purpose
    var target_speed: Vector2 = Vector2(input_x, input_y) * MAX_SPEED
    motion = motion.move_toward(target_speed, ACCELERATION * delta)
    motion = player.move_and_slide(motion)