extends KinematicBody2D

class_name Bullet

onready var ANIMATION_PLAYER: AnimationPlayer = $AnimationPlayer
onready var WINDOW_WIDTH: float = ProjectSettings.get_setting("display/window/size/width") 
onready var WINDOW_HEIGHT: float = ProjectSettings.get_setting("display/window/size/height") 
const BORDER_DESTROY_PADDING: float = 100.0
const MIN_X: float = -BORDER_DESTROY_PADDING
const MIN_Y: float = -BORDER_DESTROY_PADDING
onready var MAX_X: float = WINDOW_WIDTH + BORDER_DESTROY_PADDING
onready var MAX_Y: float = WINDOW_HEIGHT + BORDER_DESTROY_PADDING

onready var ATTACK_AREA: Area2D = $Attack

export(bool) var collides_with_walls: bool = false

export(int) var damage: int = 1

export(Vector2) var speed: Vector2 = Vector2.ZERO

export(Types.RgbColour) var colour: int = Types.RgbColour.RED
var COLOUR_MAP: Dictionary = {
    Types.RgbColour.RED: Color.indianred,
    Types.RgbColour.GREEN: Color.aquamarine,
    Types.RgbColour.BLUE: Color.indigo,
}

func _ready() -> void:
    if collides_with_walls:
        self.set_collision_mask_bit(0, true)
    
    modulate = COLOUR_MAP[colour]
    
    # Collide with every colour...
    var full_collision_mask: int = ATTACK_AREA.collision_mask \
        | (ATTACK_AREA.collision_mask << 1) \
        | (ATTACK_AREA.collision_mask << 2)
    # ...except its own
    ATTACK_AREA.collision_mask = full_collision_mask ^ (ATTACK_AREA.collision_mask << colour)

func _physics_process(delta: float):
    var out_of_world: bool = position.x < MIN_X or position.x > MAX_X \
        or position.y < MIN_Y or position.y > MAX_Y
    if out_of_world:
        queue_free()    
    
    if collides_with_walls:
        speed = move_and_slide(speed)
        if get_slide_count() > 0:
            queue_free()
    else:
        self.position += speed * delta

func _on_Attack_area_entered(other_area: Area2D):
    if other_area.owner.has_method("take_damage"):
        other_area.owner.take_damage(damage)
        queue_free()
