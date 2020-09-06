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
onready var HURTBOX: Area2D = $Hurtbox

export(bool) var collides_with_walls: bool = false
export(bool) var collides_with_other_bullets: bool = false

export(int) var damage: int = 1
export(int) var bullet_pierce: int = 2
export(int) var entity_pierce: int = 1

export(Vector2) var speed: Vector2 = Vector2.ZERO

const WALL_COLLISION_LAYER: int = 0

export(Types.RgbColour) var colour: int = Types.RgbColour.RED
var COLOUR_MAP: Dictionary = {
    Types.RgbColour.RED: Color.indianred,
    Types.RgbColour.GREEN: Color.aquamarine,
    Types.RgbColour.BLUE: Color.mediumslateblue,
}

func _ready() -> void:
    if collides_with_walls:
        self.set_collision_mask_bit(WALL_COLLISION_LAYER, true)
    
    var opacity: float = modulate.a
    modulate = COLOUR_MAP[colour]
    modulate.a = opacity
    
    var red_bullet_collision_mask: int = HURTBOX.collision_layer
    var full_bullet_collision_mask: int = red_bullet_collision_mask \
        | (red_bullet_collision_mask << 1) \
        | (red_bullet_collision_mask << 2)
    HURTBOX.collision_layer <<= colour
    
    # Collide with every colour...
    var red_entity_collision_mask: int = ATTACK_AREA.collision_mask
    var full_collision_mask: int = red_entity_collision_mask \
        | (red_entity_collision_mask << 1) \
        | (red_entity_collision_mask << 2)
    # ...except its own
    ATTACK_AREA.collision_mask = full_collision_mask ^ (red_entity_collision_mask << colour)
    if collides_with_other_bullets:
        ATTACK_AREA.collision_mask ^= \
            full_bullet_collision_mask ^ (red_bullet_collision_mask << colour)
    

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
        if other_area.owner.is_in_group("bullets"):
            bullet_pierce -= 1
            if bullet_pierce <= 0:
                queue_free()
        else:
            entity_pierce -= 1
            if entity_pierce <= 0:
                queue_free()

func take_damage(_damage: int) -> void:
    queue_free()

func disappear() -> void:
    # It would suck if the bullet hit something while disappearing
    ATTACK_AREA.collision_mask = 0
    ANIMATION_PLAYER.play("disappear")
